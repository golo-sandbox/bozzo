module bozzo

import champollion

function getNewMap = -> map[]
function getNewList = -> list[]

# augment generic parser
augment champollion.types.parser { 

    function intoBrackets = |this, li| { # li is a list
        while not this:index():isEnd() {
            let token = this:nextToken()

            if token isnt null {
                if this:isBlockStart(token) {
                    # new leaf : add hashmap to list
                    let hash = getNewMap()
                    li:add(hash)
                    # recursivity
                    this:intoCurlyBraces(
                          hash
                    )
                }

                if token:type():equals("String") or token:type():equals("Number") {
                    li:add(token:value())
                }

                if this:isBracketEnd(token) { break }  
                if this:isBlockEnd(token) { break }  

            } # end if
        } # end wile
    } # end intoBrackets

    function intoCurlyBraces = |this, hm| { # hm is a map
        
        while not this:index():isEnd() {
            let  token = this:nextToken()
            
            if token isnt null {

                let current = token
                let next = this:peekNextToken()

                if (not current:type():equals("Operator")) and ( not next:type():equals("Operator")) {
                    #Pair
                    hm:put(current:value(), next:value())
                    # move next one time
                    this:nextToken()
                } 

                if (not current:type():equals("Operator")) and (this:isBlockStart(next)) {
                    #println("Nested map : " + current + " " + next) 
                    # new leaf : add hashmap to hashmap
                    hm:put(current:value(), getNewMap())
                    # recursivity
                    this:intoCurlyBraces(
                          hm:get(current:value())
                    )
                }

                if (not current:type():equals("Operator")) and (this:isBracketStart(next)) {
                    hm:put(current:value(), getNewList())

                    this:intoBrackets( # ie: "childs":[{"name":"sam"},{"nickname":"john"}]
                          hm:get(current:value()) # this is a list
                    )
                }

                if this:isBracketEnd(token) { break }  
                if this:isBlockEnd(token) { break }  

            } # end if
        } # end while             
    } # end intoCurlyBraces

}

function JsonGrammar = -> grammar()
    :whiteSpaces("\\u0009\\u00A0\\u000A\\u0020\\u000D")     # tabulation, [no break space], [line feed], [space], [carriage feed] */
    :feeds("\\u000A\\u000D")
    :letters("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.!§%€")
    :decimalDigits("0123456789")
    :operators("+-*/(){}[]=.")  # . as operator if this.something for example
    :characters(":;,'.")
    :allowedStartIdentifiers("_$")
    :stringDelimiter("\"")
    :remarkDelimiter("#")
    :keyWords([])


function jsonParse = |jsonSource| {
    # Tokenize source code (with generic grammar of Champollion)
    let lexer = Lexer():grammar(JsonGrammar()):source(jsonSource):tokenize()

    # Cleaning tokens for the parser
    let parser = Parser():tokens(
        lexer:tokens():filter(|tok|-> not tok:value():equals(","))
    )

    let jsonMap = map[]
    let jsonList = list[]

    while not parser:index():isEnd() {

        let token = parser:nextToken()
        
        if token isnt null {

            if parser:isBlockStart(token) { 
                parser:intoCurlyBraces(jsonMap)
            }

            if parser:isBracketStart(token) {
                parser:intoBrackets(jsonList)
            }

            if parser:isBracketEnd(token) { break }  
            if parser:isBlockEnd(token) { break }           
        }

    } # end while 
    
    if jsonList:size() > 0 {
        return jsonList
    } else { return jsonMap }

}

struct dumpHelper = { stringBuffer }

augment bozzo.types.dumpHelper {

    function addToStringBuffer = |this, s| -> this:stringBuffer(this:stringBuffer()+s)

    function isDynamicObject = |this, o| -> o oftype DynamicObject.class
    function isIterable = |this, o| -> o oftype java.util.LinkedList.class
            or o oftype java.util.ArrayList.class
            or o oftype java.util.LinkedHashSet.class

    function isMap = |this, o| -> o oftype java.util.LinkedHashMap.class
    function isArray = |this, o| -> o?:getClass()?:isArray() orIfNull false
    function isTuple = |this,o| -> o oftype gololang.Tuple.class
    function isStructure = |this,o| -> o?:getClass()?:getName()?:contains(".types.") orIfNull false

    function isLong = |this, o| -> o oftype java.lang.Long.class
    function isInteger = |this, o| -> o oftype java.lang.Integer.class
    function isShort = |this, o| -> o oftype java.lang.Short.class
    function isDouble = |this, o| -> o oftype java.lang.Double.class

    function isByte = |this, o| -> o oftype java.lang.Byte.class

    function isString = |this, o| -> o oftype java.lang.String.class

    function isBoolean = |this, o| -> o oftype java.lang.Boolean.class

    function isNumber = |this, o| -> this:isLong(o)
        or this:isInteger(o)
        or this:isShort(o)
        or this:isDouble(o)


    function isPrimitive = |this, o| -> this:isNumber(o) 
        or this:isBoolean(o)
        or this:isByte(o)
        or this:isString(o)

    function trim = |this, s| {
        let regex_tab = """\t(?=([^"]*"[^"]*")*[^"]*$)"""
        let regex_space = """ (?=([^"]*"[^"]*")*[^"]*$)"""
        let regex_return = """\n(?=([^"]*"[^"]*")*[^"]*$)"""
        let str = s
            :replaceAll(regex_tab, "")
            :replaceAll(regex_space, "")
            :replaceAll(regex_return, "")
        return str
    }

    function removeCommaBeforeCurlyBraces = |this, s| {
        let regex_close = """,\}(?=([^"]*"[^"]*")*[^"]*$)"""
        return s:replaceAll(regex_close, "}")
    }

    function removeCommaBeforeBrackets = |this, s| {
        let regex_close = """,\](?=([^"]*"[^"]*")*[^"]*$)"""
        return s:replaceAll(regex_close, "]")
    }

}

local function getMembers = |o, helper| {
    
    #-----------------------------------------------
    if helper:isArray(o) {
        helper:addToStringBuffer("[")
        foreach item in o {
            getMembers(item, helper)    
        }
        helper:addToStringBuffer("],")
    }

    if helper:isIterable(o) {
        helper:addToStringBuffer("[")
        o:each(|item|->getMembers(item, helper)) 
        helper:addToStringBuffer("],")
    }
    #-----------------------------------------------

    if helper:isDynamicObject(o) {
        helper:addToStringBuffer("{")
        let members = o:properties()        
        members:each(|member| {
            let value = member:getValue()
            if helper:isPrimitive(value) {
                #TODO : test if numeric : double, long, integer, ...
                if helper:isNumber(value) or helper:isBoolean(value) {
                    helper:addToStringBuffer("\""+member:getKey()+"\":"+value+",")
                } else {
                    helper:addToStringBuffer("\""+member:getKey()+"\":\""+value+"\",")
                }
            } else {
                helper:addToStringBuffer("\""+member:getKey()+"\":")
            }
            getMembers(value, helper)
        })
        helper:addToStringBuffer("},")
    }

    if helper:isStructure(o) { 
        helper:addToStringBuffer("{")
        let members = o:members()
        members:each(|member| {
            let value = o:get(member)
            if helper:isPrimitive(value) {
                if helper:isNumber(value) or helper:isBoolean(value) {
                    helper:addToStringBuffer("\""+member+"\":"+value+",")
                } else {
                    helper:addToStringBuffer("\""+member+"\":\""+value+"\",")                   
                }               
            } else {
                helper:addToStringBuffer("\""+member+"\":")
            }           
            getMembers(value, helper)
        })  
        helper:addToStringBuffer("},")  
    }

    if helper:isMap(o) {
        helper:addToStringBuffer("{")
        o:each(|key, value| {
            if helper:isPrimitive(value) {
                if helper:isNumber(value) or helper:isBoolean(value) {
                    helper:addToStringBuffer("\""+key+"\":"+value+",")
                } else {
                    helper:addToStringBuffer("\""+key+"\":\""+value+"\",")
                }
            } else {
                helper:addToStringBuffer("\""+key+"\":")
            }
            getMembers(value, helper)
        })
        helper:addToStringBuffer("},")
    }

}

function jsonStringify = |objectToStringify| {
    let helper = dumpHelper():stringBuffer("")
    getMembers(objectToStringify, helper)
    let jsonString = helper:removeCommaBeforeBrackets(
            helper:removeCommaBeforeCurlyBraces(
                helper:stringBuffer()
            )
        )
    return jsonString:substring(0, jsonString:length() - 1 )
}
