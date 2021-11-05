extends Control

func _ready():
    var resolver = preload("res://addons/DialogNode/resolver.gd").new()
    $DialogNode.init(resolver)
    $Info/v/Inventory/LineEdit.text = PoolStringArray(resolver.inventory).join(", ")
    $Info/v/Quests/LineEdit.text = PoolStringArray(resolver.quests).join(", ")
    $Info/v/QuestsComplete/LineEdit.text = PoolStringArray(resolver.quests_completed).join(", ")
    $Info/v/Characters/LineEdit.text = PoolStringArray(resolver.party).join(", ")	
    
    $Info/v/Inventory/LineEdit.connect("text_changed", self, "changed", ["inventory"])
    $Info/v/Quests/LineEdit.connect("text_changed", self, "changed", ["quests"])
    $Info/v/QuestsComplete/LineEdit.connect("text_changed", self, "changed", ["quests_completed"])
    $Info/v/Characters/LineEdit.connect("text_changed", self, "changed", ["party"])

func clean():
    $Panel/V/MainText.bbcode_text = ""
    for i in 4:
        get_node("Panel/V/Option%d"%i).text = ""
        get_node("Panel/V/Option%d"%i).hide()

func changed(text: String, what: String):
    var arr = Array(text.split(","))
    for i in arr.size():
        arr[i] = arr[i].strip_edges()
    $DialogNode.resolver.set(what, arr)

func run():
    clean()
    $DialogNode.start()

func opt(i):
    $DialogNode.answer_pressed(i)


func show_text(text, options):
    $Panel/V/MainText.text = text
    for i in 4:
        if options.size() >  i and options[i]:
            get_node("Panel/V/Option%d"%i).text = options[i]
            get_node("Panel/V/Option%d"%i).visible = true
        else:
            get_node("Panel/V/Option%d"%i).visible = false


func start():
    run()


func close():
    self.hide()

func action(action, args):
    $Info/v/Inventory/LineEdit.text = \
        PoolStringArray($DialogNode.resolver.inventory).join(", ")
    $Info/v/Quests/LineEdit.text = \
        PoolStringArray($DialogNode.resolver.quests).join(", ")
    $Info/v/QuestsComplete/LineEdit.text = \
        PoolStringArray($DialogNode.resolver.quests_completed).join(", ")
    $Info/v/Characters/LineEdit.text = \
        PoolStringArray($DialogNode.resolver.party).join(", ")	


func end():
    clean()
