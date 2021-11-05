extends GraphNode
class_name DialogOption

const template_option = {
    "code": "", 
    "next_code": "",
    "conditions": []
}

var data = {
    "type": "dialog",
    "code": "",
    "options":[
        null, null, null, null
    ],
    "character": ""
}

signal answer(node, i)
signal NPC_say(node)

func set_data(d):
    for key in d:
        data[key] = d[key]
    assert(data.code != "")
    $NPC.text = e.translate(e.langs[0], d.code)
    for i in range(4):
        update_name(i)
    if "character" in d:
        $Name.text = d.character
        

func update_name(i):
    if i == -1:
        $NPC.text = e.translate(e.langs[0], data.code)
    elif data.options[i]:
        get_node("Option%d" % i).text = e.translate(e.langs[0], data.options[i].code)

func clear_option(i:int):
    data.options[i] = null
    get_node("Option%d" % i).text  = ""
    e.editor.disconnect_node(self.name, i)

func create_option(i: int):
    var json = template_option.duplicate()
    json.code = e.get_id()
    data.options[i] = json
    get_node("Option%d" % i).text = e.translate(e.langs[0], json.code)
    
    if not json.code in e.codes_used:
        e.codes_used.append(json.code)
    
func update_option_text(i, lang, text):
    if data.options[i]:
        data.options[i].text[lang] = text

func _ready():
    var i = 0
    for ctl in [$Option0,$Option1,$Option2,$Option3]:
        ctl.connect("pressed", self, "answer_pressed", [ctl, i])
        i += 1
    $NPC.connect("pressed", self, "npc_say")
    
func npc_say():
    for ctl in [$Option0,$Option1,$Option2,$Option3]:
        ctl.pressed = false
    emit_signal("NPC_say", self)
    
func answer_pressed(ctl, i):
    for c in [$NPC,$Option0,$Option1,$Option2,$Option3]:
        if c == ctl: continue
        c.pressed = false
        
    emit_signal("answer", self, i)
    
func switch_off():
    for ctl in [$NPC,$Option0,$Option1,$Option2,$Option3]:
        ctl.pressed = false
    
func name_changed(new_text):
    data.character = new_text
