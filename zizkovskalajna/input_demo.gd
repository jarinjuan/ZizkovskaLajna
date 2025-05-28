extends Node2D

var data = Save_Data.new()

func loadPressed():
	Save_Load.load_data()


func savePressed():
	Save_Load.save_data(data)


func showPresssed() -> void:
	pass # Replace with function body.


func hidePressed() -> void:
	pass # Replace with function body.
