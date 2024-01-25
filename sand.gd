class_name Sand

var _color: Color = Color.WHITE
var _row = -1
var _column = -1
var _iterationsSinceLastMove = 0

func _init(color,row,column):
	_color = color
	_row = row
	_column = column
	
func getRow() -> int:
	return _row
func getColumn() -> int:
	return _column
func getColor() -> Color:
	return _color
	
func updatePosition(row: int, column: int) -> void:
	_row = row
	_column = column
	
func incrementIterationCount() -> void:
	if(isDoneMoving()):
		return
	_iterationsSinceLastMove = _iterationsSinceLastMove + 1
func resetIterationCount() -> void:
	_iterationsSinceLastMove = 0
func isDoneMoving() -> bool:
	return _iterationsSinceLastMove > 4

func toString() -> String:
	return "Row: " + str(_row) + ",Column: " + str(_column)
