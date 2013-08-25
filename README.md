#Bozzo

**Bozzo** is a json parser written in **[Golo](http://golo-lang.org/)** thanks to the **[Champollion](https://github.com/k33g/champollion)** lexer.

##How ?

**Bozzo** waits for a json string and parses it to hashmap (`map[]`) for a single object or to linkedlist (`list[]`).

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
            "childs":[
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


