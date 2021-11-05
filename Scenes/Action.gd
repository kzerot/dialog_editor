extends GraphNode
class_name Action

const actions = [
    # id			Human name		Fields					
    ["give_item", 	"Give item", 	[{"type":"text", 
                                    "variable":"item"}]],
    ["receive_item","Receive item",[{"type":"text", 
                                    "variable":"item"}]],
    ["complete_quest", 	"Complete quest",	[{"type":"text", 
                                    "variable":"quest"}]],
    ["new_quest", 	"Start quest", 	[{"type":"text", 
                                    "variable":"quest"}]],
    ["new_character", 	"Add character", 	[{"type":"text", 
                                    "variable":"character"}]],
    ["scenario", 	"Custom scenario", 	[{"type":"text", 
                                    "variable":"scenario"}]],

]

onready var popup = $Pick.get_popup()

var action = ""
var fields = null

var data setget set_data, get_data

func get_data():
    if not fields: return data
    var args = {}
    for f in fields[2]:
        match f.type:
            "text":
                args[f.variable] = get_node(f.variable).text
    data.action = action
    data.args = args
    data.type = "action"
    return data
    

func set_data(_data):
    if not data: data = {}
    for k in _data:
        data[k] = _data[k]
    
    if not "code" in data: data.code = ""
    if not "action" in data: data.action = ""
    if not "type" in data: data.type = "action"
    if not "args" in data: data.args = []
    if not "next_code" in data: data.next_code = ""
    var i = 0
    
    for o in actions:
        if o[0] == data.action:
            action_selected(i)
            break
        i += 1
    
    if not fields: return
    
    for f in fields[2]:
        match f.type:
            "text":
                get_node(f.variable).text = data.args[f.variable]

func _ready():
    popup.connect("id_pressed", self, "action_selected")
    for i in range(actions.size()):
        popup.add_item(actions[i][1], i)
        
func action_selected(i):
    set_slot(0, false, 0, Color.black, true, 1, Color.green)

    fields = actions[i]
    action = fields[0]
    for c in get_children():
        if c == $Pick: continue
        c.free()
    $Pick.text = fields[1]
    for field in fields[2]:
        match field.type:
            "text":
                var line = LineEdit.new()
                add_child(line)
                line.name = field.variable
                line.placeholder_text = field.variable
    
    rect_size.y = 0
    self.set_slot(0, true, 0, Color.wheat, true, 0, Color.wheat)
    
    
