extends GraphNode
class_name DialogPhrase


var data = {
    "code": "",
    "next_code": "",
    "type": "phrase",
    "character": ""
}

signal NPC_say(node)

func set_data(d):
    for key in d:
        data[key] = d[key]
    assert(data.code != "")
    $NPC.text = e.translate(e.langs[0], d.code)
    if "character" in d:
        $Name.text = d.character

func _ready():
    $NPC.connect("pressed", self, "npc_say")
    
func npc_say():
    emit_signal("NPC_say", self)

func switch_off():
    for ctl in [$NPC]:
        ctl.pressed = false

func name_changed(new_text):
    data.character = new_text

func update_name(i):
    if i == -1:
        $NPC.text = e.translate(e.langs[0], data.code)
