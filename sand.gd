class_name Sand

var _mesh: Mesh = null
var _position: Vector2 = Vector2.ZERO
var _color: Color = Color.WHITE

func _init(mesh,position,color = Color.WHITE):
	_mesh = mesh
	_position = position
	_color = color
	
func getMesh() -> Mesh:
	return _mesh
func getPosition() -> Vector2:
	return _position
func getColor() -> Color:
	return _color
	
func updatePosition(newPosition: Vector2) -> void:
	_position = newPosition
	

	
	

