extends Control

onready var diag = $V/Dialogs

# Stored connections
var dict = {}
var nodes = []
var current_file = ""
func _ready():
    e.editor = self
    diag.get_zoom_hbox().hide()
    # Parse all keys and load translations
    $V/Menu/H/File.get_popup().connect("id_pressed", self, "menu")
    
func menu(idx):
    match idx:
        0:
            for c in nodes:
                c.get_parent().remove_child(c)
                c.free()
            dict = {}
            nodes = []
            current_file = ""
            yield(get_tree(), "idle_frame")
        1:
            $Load.show_modal(true)
            $Load.current_dir = $Load.current_dir

        2:
            save()

        3:
            save("", true)
               
func save(file_name="", force = false):
    if (not file_name and not current_file) or force:
        $SaveAs.show_modal(true)
        $SaveAs.current_dir = $SaveAs.current_dir
        return
    elif current_file and not file_name:
        file_name = current_file
        
    # Save translations
    e.save_translations()
    
    var result = {
        "start_node": "",
        "nodes" : {},
        "extra":{
            
        },
        "extra_connections": []
    }
    # Prepare basic nodes
    for node in get_tree().get_nodes_in_group("save"):
        if not node.data.code:
            continue
        if "options" in node.data:
            for opt in node.data.options:
                if opt:
                    opt.next_code = ""
                    opt.conditions = []
                        
        result.nodes[node.data.code] = node.data
        result.extra[node.data.code] = {"offset" : {"x": node.offset.x, "y": node.offset.y}}

    for node in get_tree().get_nodes_in_group("extra"):
        result.extra[node.name] = {"offset" : {"x": node.offset.x, "y": node.offset.y}, "data": node.data, "id": node.name}

    for connection in diag.get_connection_list():
        var from_node: GraphNode = diag.get_node(connection.from)
        var to_node: GraphNode = diag.get_node(connection.to)
        if not from_node or not to_node:
            continue
        if from_node == $V/Dialogs/Start:
            result.start_node = to_node.data.code
        
        if from_node is DialogOption or from_node is Selector:
            # save connections
            var data = result.nodes[from_node.data.code]
            if data.options[connection.from_port]:
                data.options[connection.from_port].next_code = to_node.data.code
        elif from_node is DialogPhrase or from_node is Action:
            var data = result.nodes[from_node.data.code]
            data.next_code = to_node.data.code
        elif from_node is Condition:
            if to_node.data.options[connection.to_port-1]:
                #If port is good
                var data = result.nodes[to_node.data.code]
                if not "conditions" in data.options[connection.to_port-1]:
                    data.options[connection.to_port-1].conditions = []
                data.options[connection.to_port-1].conditions.append(from_node.data)

    result.extra_connections = diag.get_connection_list()

    var file = File.new()
    file.open(file_name, File.WRITE)
    file.store_string(JSON.print(result, "  "))
    file.close()
    current_file = file_name

func load_dialog(file_name=""):
    for c in nodes:
        c.get_parent().remove_child(c)
        c.free()
    dict = {}
    nodes = []
    yield(get_tree(), "idle_frame")
    

    var file = File.new()
    file.open(file_name, File.READ)
    var res = JSON.parse(file.get_as_text())
    file.close()
    current_file = file_name
    if res.error == OK:
        var data = res.result
        for dt in data.nodes:
            var node = add_some(data.nodes[dt].type, data.nodes[dt].code)
            node.set_data(data.nodes[dt])

        # Create connections from raw (not saved)
        for dt in data.nodes:
            if "next_code" in data.nodes[dt] and diag.has_node(data.nodes[dt].next_code):
                # connect slot 0 - it's  phrase
                diag.connect_node(dt, 0, data.nodes[dt].next_code, 0)
            elif "options" in data.nodes[dt] and not "extra" in data:
                # It's dialog options
                for i in data.nodes[dt].options.size():
                    var option = data.nodes[dt].options[i]
                    if option and option.next_code:
                        diag.connect_node(dt, i, option.next_code, 0)
                    if option and "conditions" in option and option.conditions:
                        for condi in option.conditions:
                            var c = add_some("condition")
                            c.from_data(condi)
                            diag.connect_node(c.name, 0, dt, i+1)
                            
        if "extra" in data:
            for dt in data.extra:
                var node_data = data.extra[dt]
                if "data" in node_data:
                    # Helper node, not exists in data.nodes
                    var node = add_some(node_data.data.type)
                    if  node.has_method("from_data"):
                        node.from_data(node_data.data)
                    node.name = node_data.id
                if "offset" in node_data and diag.has_node(dt):
                    diag.get_node(dt).offset = Vector2(node_data.offset.x, node_data.offset.y)
        if "extra_connections" in data:
            for conn in data.extra_connections:
                diag.connect_node(conn.from, conn.from_port, conn.to, conn.to_port)
                if not conn.from in dict:
                    dict[conn.from] = {}
                    
                dict[conn.from][conn.from_port] = {
                    "to": conn.to, "to_slot": conn.to_port
                }
                
        if "start_node" in data and diag.has_node(data.start_node):
            diag.connect_node("Start", 0, data.start_node, 0)

func add_answer_node(vec=null, code=null):
    var node = add_node("DialogOption", vec)
    node.connect("NPC_say", self, "open_dialog", [-1])
    node.connect("answer", self, "open_dialog")
    
    if not code:
        node.set_data({"code": e.get_id()})
    else:
        node.set_data({"code": code})
        
    if not node.data.code in e.codes_used:
        e.codes_used.append(node.data.code)
        
    node.title = node.data.code
    node.name = node.data.code
    return node
    
func add_phrase_node(vec=null, code=null):
    var node = add_node("DialogPhrase", vec)
    node.connect("NPC_say", self, "open_dialog", [-1])
    
    if not code:
        node.set_data({"code": e.get_id()})
    else:
        node.set_data({"code": code})
        
    if not node.data.code in e.codes_used:
        e.codes_used.append(node.data.code)
        
    node.title = node.data.code
    node.name = node.data.code
    return node
    
func add_selector_node(vec=null, code=null):
    var node = add_node("Selector", vec)
    
    if not code:
        node.set_data({"code": e.get_id("Selector")})
    else:
        node.set_data({"code": code})
        
    if not node.data.code in e.codes_used:
        e.codes_used.append(node.data.code)

    node.name = node.data.code
    return node	
    
func add_action_node(vec=null, code=null):
    var node = add_node("Action", vec)
    
    if not code:
        node.set_data({"code": e.get_id("Action")})
    else:
        node.set_data({"code": code})
        
    if not node.data.code in e.codes_used:
        e.codes_used.append(node.data.code)

    node.name = node.data.code
    return node

func add_condition(vec=null):
    return add_node("Condition", vec)
    
func add_node(type, vec=null):
    var node = load("res://Scenes/%s.tscn"%type).instance()
    if vec == null:
        vec = get_global_mouse_position()
        vec += diag.scroll_offset

    node.offset = vec - node.rect_size/2

    nodes.append(node)
    diag.add_child(node)
    return node
    
func disconnect_node(from, from_slot):
    if from in dict:
        if from_slot in dict[from]:
            diag.disconnect_node(from, from_slot, dict[from][from_slot].to,
                                 dict[from][from_slot].to_slot)
            dict[from].erase(from_slot)

    var from_node: GraphNode = diag.get_node(from)
    if from_node is DialogOption:
        if from_node.data.options[from_slot]:
            from_node.data.options[from_slot].next_code = null
            
func connection_to_empty(from, from_slot, _release_position):
    var from_node: GraphNode = diag.get_node(from)
    if not from_node is ExtraNode:
        disconnect_node(from, from_slot)

func disconnection_request(from, from_slot, _to, _to_slot):
    var from_node: GraphNode = diag.get_node(from)
#	if not from_node is ExtraNode:
    diag.disconnect_node(from, from_slot, _to,_to_slot)
    
func connection_request(from, from_slot, to, to_slot):
    var from_node: GraphNode = diag.get_node(from)
    var to_node: GraphNode = diag.get_node(to)
    
    if from in dict:
        if from_slot in dict[from]:
            if not from_node is ExtraNode:
                diag.disconnect_node(from, from_slot, dict[from][from_slot].to,
                                     dict[from][from_slot].to_slot)
                dict[from].erase(from_slot)
            
    diag.connect_node(from, from_slot, to, to_slot)
    if not from in dict:
        dict[from] = {}
        
    dict[from][from_slot] = {
        "to": to, "to_slot": to_slot
    }

func add_some(menu,code=null):
    match menu:
        "dialog":
            return add_answer_node(null, code)
        "phrase":
            return add_phrase_node(null, code)
        "selector":
            return add_selector_node(null, code)
        "action":
            return add_action_node(null, code)
        "condition":
            return add_condition()
            
func open_dialog(ctl, ans=-1):
    for node in nodes:
        if node != ctl and node.has_method("switch_off"):
            node.switch_off()
    $Answer.show_me()
    $Answer.set_data(ctl, ans)
    
func hide_answer():
    for node in nodes:
        if node.has_method("switch_off"):
            node.switch_off()
    $Answer.hide_me()

func dialogs_gui_input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
            and event.pressed:
        hide_answer()
        var popup = preload("res://Scenes/RMBPopu.tscn").instance()
        add_child(popup)
        popup.rect_global_position = get_global_mouse_position()
        popup.connect("selected", self, "add_some")
        popup.show_modal()
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
            and event.pressed:
        hide_answer()
    elif event is InputEventKey and event.scancode == KEY_DELETE and event.pressed:
        for node in diag.get_children():
            if node is GraphNode and node.selected and not node == diag.get_node("Start"):
                nodes.erase(node)
                for dt in diag.get_connection_list():
                    if dt.from == node.name or dt.to == node.name:
                        diag.disconnect_node(dt.from, dt.from_port, dt.to, dt.to_port)
                        if dt.from in dict:
                            dict[dt.from].erase(dt.from_port)
                diag.remove_child(node)
                node.free()


func play():
    save()
    $TestDialog.show()
    $TestDialog.clean()


func save_dialog(file_name):
    save(file_name)
