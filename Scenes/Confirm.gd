extends Control

signal result

func _ready():
    $P/Yes.connect("pressed", self, "yes")
    $P/No.connect("pressed", self, "no")
    self.hide()
    
func showme(text):
    self.show()
    $P/Text.text = text
    
func no():
    emit_signal("result", false)
    hide()
func yes():
    emit_signal("result", true)
    hide()
