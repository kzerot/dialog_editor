extends PopupMenu


signal selected

const options = [
    ["dialog", "Dialog"],
    ["phrase", "Phrase"],
    ["action", "Action"],
    ["condition", "Condition"],
    ["selector", "Selector"],
]

func _ready():
    self.rect_size = Vector2()
    var i = 0
    for opt in options:
        self.add_item(opt[1], i)
        i += 1
        
func _modal_closed():
    if not is_queued_for_deletion():
        self.queue_free()


func _id_pressed(id):
    emit_signal("selected", options[id][0])


    self.queue_free()


