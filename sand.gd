class_name Sand

var _mesh: Mesh = null
var _position: Vector2 = Vector2.ZERO
var _color: Color = Color.WHITE
var _finalDestinationReached = false
var _meshSaved = false
var _row = -1
var _column = -1
var _iterationsSinceLastMove = 0


func _init(mesh,position,color,row,column):
	_mesh = mesh
	_position = position
	_color = color
	_row = row
	_column = column
	
func getMesh() -> Mesh:
	return _mesh
func getRow() -> int:
	return _row
func getColumn() -> int:
	return _column
func getPosition() -> Vector2:
	return _position
func getColor() -> Color:
	return _color
	
func updatePosition(newPosition: Vector2, row: int, column: int) -> void:
	_row = row
	_column = column
	_position = newPosition
	
func setFinalDestinationReached() -> void:
	_finalDestinationReached = true

func isFinalDestinationReached() -> bool:
	return _finalDestinationReached
	
func setMeshSaved() -> void:
	_meshSaved = true

func isMeshSaved() -> bool:
	return _meshSaved
	
func incrementIterationCount() -> void:
	_iterationsSinceLastMove = _iterationsSinceLastMove + 1
func resetIterationCount() -> void:
	_iterationsSinceLastMove = 0
func isDoneMoving() -> bool:
	return _iterationsSinceLastMove > 4

func toString() -> String:
	return "Row: " + str(_row) + ",Column: " + str(_column)
