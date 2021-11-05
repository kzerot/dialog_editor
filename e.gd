extends Node

const translation_file = "Data/Dialogs.csv"
const langs = ["en", "ru"]
const id_template = "phrase_"

var editor
# For id's
var codes_used = []
# Translations
var translations = {}
var current_id = 0


func get_id(n=""):
    if not n: n = id_template
    current_id += 1
    while has_code(n + str(current_id)):
        current_id += 1
    return n + str(current_id)

func get_translations():
    var result = [["code"] + langs]
    for code in translations[langs[0]].get_message_list():
        var line = [code]
        for l in langs:
            line.append(translate(l, code))
        result.append(line)
    return result
        

func translate(lang, text):
    var res = translations[lang].get_message(text)
    return res if res else text

func add_translation(lang, code, text):
    
    if code != translate(lang, code):
        # replace translation
        translations[lang].erase_message(code)
    translations[lang].add_message(code, text)

func has_code(code):
    return code in codes_used
    

func save_translations():
    var file = File.new()
    file.open(translation_file, File.WRITE)
    for line in get_translations():
        file.store_csv_line(line)
    file.close()
        
func load_translations():
    var file = File.new()
    var err = file.open(translation_file, File.READ)
    
    for lang in langs:
        var trans = Translation.new()
        trans.locale = lang
        translations[lang] = trans

    if err == OK:
        while not file.eof_reached():
            var line = file.get_csv_line()
            if line.size() > langs.size():
                # we need line with code and all languages
                var i = 1
                for l in langs:
                    translations[l].add_message(line[0], line[i])
                    i += 1
                codes_used.append(line[0])
                
    for l in translations.values():
        TranslationServer.add_translation(l)
        
func _ready():
    load_translations()
