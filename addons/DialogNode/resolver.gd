extends Object

var character = {
    "name": "You"
}
var inventory = ["apple", "sword", "2323"]
var quests = ["quest01"]
var quests_completed = ["quest00"]
var party = ["Hime-sama"]


func has_character(data):
    return data.character in party
    
func no_quest(data):
    return not has_quest(data)

func quest_completed(data):
    return data.quest in quests_completed
    
func has_quest(data):
    return data.quest in quests 

func has_item(data):
    return data.item in inventory

func new_character(data):
    party.append(data.character)
    
func complete_quest(data):
    if data.quest in quests:
        quests.erase(data.quest)
    quests_completed.append(data.quest)
    
func new_quest(data):
    quests.append(data.quest)
    
func give_item(data):
    if data.item in inventory:
        inventory.erase(data.item)
    
func receive_item(data):
    inventory.append(data.item)
    
