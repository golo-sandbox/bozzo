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


