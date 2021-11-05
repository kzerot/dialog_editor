extends PanelContainer

var lang0 = "en"
var lang1 = "ru"

var text0 = "" setget set_t0
var text1 = "" setget set_t1

var current_node = null
var current_i = -1


func set_t0(txt):
    text0 = txt
    $V/Translations/TR0.text = txt

func set_t1(txt):
    text1 = txt
    $V/Translations/TR1.text = txt

func show_me():
    $Tween.remove_all()
    $Tween.interpolate_property(self, "rect_position:y", self.rect_position.y,
            get_viewport().size.y-self.rect_size.y, 0.2)
    $Tween.start()
    
func set_data(node, i):
    current_node = node
    current_i = i
    if i == -1:
        # it's npc says
        set_t0(translate(lang0, node.data.code))
        set_t1(translate(lang1, node.data.code))
        $V/Buttons/Code.text = node.data.code
    else:
        if not node.data.options[i]:
            node.create_option(i)
        set_t0(translate(lang0, node.data.options[i].code))
        set_t1(translate(lang1, node.data.options[i].code))
        $V/Buttons/Code.text = node.data.options[i].code
    
    
func translate(lang, code):
    return e.translate(lang, code)

func hide_me():
    $Tween.remove_all()
    $Tween.interpolate_property(self, "rect_position:y", self.rect_position.y,
            get_viewport().size.y, 0.2)
    $Tween.start()
    


func _on_Clear_pressed():
    if current_node:
        if current_i == -1:
            pass
        else:
            current_node.clear_option(current_i)
            e.editor.hide_answer()



func code_changed(new_text):
    if not e.has_code(new_text):
        if current_i == -1:
            e.codes_used.erase(current_node.data.code)
            current_node.data.code = new_text
            current_node.name = new_text
            current_node.title = new_text
        elif current_node.data.options[current_i]:
            if current_node.data.options[current_i].code:
                e.codes_used.erase(current_node.data.options[current_i].code)
            current_node.data.options[current_i].code = new_text
    if current_node.has_method("update_name"):
        current_node.update_name(current_i)
        
func text_entered(new_text):
    if  e.has_code(new_text):
        if current_i == -1:
            $"../Confirm".showme("Replace code?")
            if yield($"../Confirm", "result"):
                e.codes_used.erase(current_node.data.code)
                current_node.data.code = new_text
                current_node.name = new_text
                current_node.title = new_text
                $V/Translations/TR0.text = translate(lang0, new_text)
                $V/Translations/TR1.text = translate(lang1, new_text)
            else:
                $V/Buttons/Code.text = current_node.data.code
    if current_node.has_method("update_name"):
        current_node.update_name(current_i)
        
func text0_changed():
    if current_i == -1:
        e.add_translation(lang0, current_node.data.code, $V/Translations/TR0.text)
        if current_node.has_method("update_name"):
            current_node.update_name(current_i)
    elif current_node.data.options[current_i] and \
            current_node.data.options[current_i].code:
        e.add_translation(lang0, current_node.data.options[current_i].code, $V/Translations/TR0.text)
        if current_node.has_method("update_name"):
            current_node.update_name(current_i)

func text1_changed():
    if current_i == -1:
        e.add_translation(lang1, current_node.data.code, $V/Translations/TR1.text)
    elif current_node.data.options[current_i] and \
            current_node.data.options[current_i].code:
        e.add_translation(lang1, current_node.data.options[current_i].code, $V/Translations/TR1.text)


