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



