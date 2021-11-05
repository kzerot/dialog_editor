extends ExtraNode
class_name Condition

const conditions = [
    # id			Human name		Fields					
    ["has_quest", 	"Has quest", 	[{"type":"text", 
                                    "variable":"quest"}]],
    ["quest_completed","Quest completed",[{"type":"text", 
                                    "variable":"quest"}]],
    ["not_quest_completed","Quest not completed",[{"type":"text", 
                                    "variable":"quest"}]],
    ["no_quest", 	"Has no quest",	[{"type":"text", 
                                    "variable":"quest"}]],
    ["has_item", 	"Has item", 	[{"type":"text", 
                                    "variable":"item"}]],
    ["has_no_item", 	"Doesn't have item", 	[{"type":"text", 
                                    "variable":"item"}]],
    ["has_character","Has character",[{"type":"text", 
                                    "variable":"character"}]],
    ["reputation","Reputation", [{"type":"text", 
                                    "variable":"faction"},
                                {"type":"text", 
                                    "variable":"value"}]]
]

onready var popup = $Pick.get_popup()

var condition = ""
var fields = null

func get_data():
    if not fields: return {}
    var options = {}
    for f in fields[2]:
        match f.type:
            "text":
                options[f.variable] = get_node(f.variable).text
    
    return {
        "condition": condition,
        "options": options,
        "type": "condition"
    }

func from_data(data):
    var i = 0
    
    for o in conditions:
        if o[0] == data.condition:
            condi_selected(i)
            break
        i += 1
    
    if not fields: return
    
    for f in fields[2]:
        match f.type:
            "text":
                get_node(f.variable).text = data.options[f.variable]
            
    
    

func _ready():
    popup.connect("id_pressed", self, "condi_selected")
    for i in range(conditions.size()):
        popup.add_item(conditions[i][1], i)
        
func condi_selected(i):
    set_slot(0, false, 0, Color.black, true, 1, Color.green)

    fields = conditions[i]
    condition = fields[0]
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
