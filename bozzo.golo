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


