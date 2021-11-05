tool
extends EditorPlugin


func _enter_tree():
    add_custom_type("DialogNode", "Node", preload("dialog.gd"), preload("dialog_icon.png"))


func _exit_tree():
    remove_custom_type("DialogNode")
