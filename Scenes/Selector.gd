extends GraphNode
class_name Selector

var data = {
    "type": "selector",
    "code": "",
    "options":[
        {
            "code": "", 
            "next_code": "",
            "conditions": []
        },
        {
            "code": "", 
            "next_code": "",
            "conditions": []
        },
        {
            "code": "", 
            "next_code": "",
            "conditions": []
        },
        {
            "code": "", 
            "next_code": "",
            "conditions": []
        },
    ]
}

func set_data(d):
    for key in d:
        data[key] = d[key]
    assert(data.code != "")
