#Bozzo

**Bozzo** is a json parser written in **[Golo](http://golo-lang.org/)** thanks to the **[Champollion](https://github.com/k33g/champollion)** lexer.

##How ?

###Cast json string to hashmap or linkedlist

**Bozzo** `jsonParse(s)` method waits for a json string and parses it to hashmap (`map[]`) for a single object or to linkedlist (`list[]`).

See `sample.golo` :

```coffeescript
module sample

import bozzo

function main = |args| {

	let src = """
	[
        {
    		"firstName" : "Al", 
    		"lastName" :"Bundy",
    		"friend": {
                "name" : "Jefferson" 
            }, 
            "age" :45,
            "wife" : {
                "firstName":"Peggy", 
                "lastName":"Bundy"
            },
            "children":[
                {"firstName":"Kelly","lastName":"Bundy"},
                {"firstName":"Bud","lastName":"Bundy"}
            ]
    	},
        {"name":"Jefferson", wife : {"name":"Marcy"}}
    ]
	"""
    
    println(jsonParse(src)) # result is a list[]

    println(jsonParse(""" 
		{
    		"firstName" : "Bob", 
    		"lastName" : "Morane",
    		"friend": {
                "firstName" : "Bill", 
                "lastName":"Ballantine"
            }
            ,
	         "tools":[
	                "Gun","Riffle"
	            ]
        }
    """)) # result is a hashmap

}

```

**Run it :** `golo golo --files champollion/champollion.golo bozzo.golo sample.golo`

###Cast objects or objects lists to json string

**Bozzo** `jsonStringify(o)` method waits for objects () or objects list and cast it to json string.

See `sample2.golo` :

```coffeescript
module sample2

import bozzo

struct human = { firstName, lastName }

function main = |args| {

    let Al = DynamicObject()
        :firstName("Al"):lastName("Bundy")
        :friend(map[["name","Jefferson"]])
        :age(45)
        :wife(human():firstName("Peggy"):lastName("Bundy"))
        :children(array[
              human():firstName("Kelly"):lastName("Bundy")
            , human():firstName("Bud"):lastName("Bundy")
        ])

    let jsonString = bozzo.jsonStringify(Al)

    println(jsonString)

    # Result :
    # {
    #     "lastName":"Bundy"
    #    ,"wife":{"firstName":"Peggy","lastName":"Bundy"}
    #    ,"age":45
    #    ,"children":[{"firstName":"Kelly","lastName":"Bundy"},{"firstName":"Bud","lastName":"Bundy"}]
    #    ,"firstName":"Al"
    #   ,"friend":{"name":"Jefferson"}
    # }

}
```

**Run it :** `golo golo --files champollion/champollion.golo bozzo.golo sample2.golo`
