extends Node

export (String) var dialog_file = "Saved.json"
# Some object who can tell us is condition completed
var resolver
var data : Dictionary
# Current node 
var node

signal show_text(text, options)
signal action(action, args)
signal end()

func init(resolver):
    self.resolver = resolver

func start(dialog=""):
    if not resolver:
        return
    if not dialog:
        dialog = dialog_file
    var f = File.new()
    if f.open(dialog, File.READ) == OK:
        var res = JSON.parse(f.get_as_text())
        f.close()
        if res.error == OK:
            data = res.result
    
    assert("start_node" in data)
    if data and data.start_node:
        process_node(data.start_node)
        
func process_node(code: String):
    assert(code in data.nodes)
    node = data.nodes[code]
    match node.type:
        "dialog":
            var text = tr(code).format(resolver.character)
            var options = []
            for opt in node.options:
                if opt and (not opt.conditions or pass_conditions(opt.conditions)):
                    options.append(tr(opt.code).format(resolver.character))
                else:
                    options.append(null)
            emit_signal("show_text", text, options)
        "selector":
            for opt in  node.options:
                if opt:
                    if (not opt.conditions or pass_conditions(opt.conditions)) and\
                            opt.next_code:
                        process_node(opt.next_code)
                        break
        "action":
            if resolver.has_method(node.action):
                resolver.call(node.action, node.args)
            emit_signal("action", node.action, node.args)
            process_node(node.next_code)
        "phrase":
            emit_signal("show_text", tr(code).format(resolver.character), [tr("continue")])

func pass_conditions(conditions):
    for condi in conditions:
        if not resolver.has_method(condi.condition) or\
                 not resolver.call(condi.condition, condi.options):
            return false
    return true
    
func answer_pressed(i: int):
    if "options" in node:
        if node.options[i] and node.options[i].next_code:
            process_node(node.options[i].next_code)
        else:
            end()
    elif "next_code" in node and node.next_code:
        process_node(node.next_code)
    else:
        end()
        
func end():
    emit_signal("end")
        
