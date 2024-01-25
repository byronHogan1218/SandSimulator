extends Node2D

var cellSize: int = 8
# This is the hardcoded width of the window divided by the cells size
var windowWidth: int = -1
# This is the hardcoded height of the window divided by the cells size
var windowHeight: int = -1

var rng = RandomNumberGenerator.new()

var instantiatedMeshes = []
var currentSand: Array = []

var directions: Array[int] = [-1,1]
var colorIndex: int = 0
var colors = [Color.WHITE, Color.RED, Color.GREEN, Color.BLUE]

# Called when the node enters the scene tree for the first time.
func _ready():
	windowWidth = (480/cellSize)
	windowHeight = (720/cellSize)

	for row in range(windowHeight):
		var sandRow = []
		var sandRowMeshes = []
		for column in range(windowWidth):
			sandRow.append(null)
			var meshInstance = MeshInstance2D.new()
			sandRowMeshes.append(meshInstance)

		currentSand.append(sandRow)
	print("Column amount: ", windowWidth)
	print("Row amount: ", windowHeight)
	pass

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left"):
		colorIndex = (colorIndex + 1) % (colors.size())
	if Input.is_action_pressed("left"):
		var mouse_position: Vector2 = get_global_mouse_position()
		coordinatesToSand(mouse_position)
	for instance in instantiatedMeshes:
		remove_child(instance)
	instantiatedMeshes = []
	generateNewSand()
	drawSand()
	pass
	
func drawSand():
	for row in range(windowHeight):
		var sandParticleRow = currentSand[row]
		for column in range(windowWidth):		
			var sandParticle = sandParticleRow[column]
			if(sandParticle == null):
				continue
			var meshInstance = MeshInstance2D.new()			

			meshInstance.mesh = sandParticle.getMesh()
			meshInstance.translate(Vector2(sandParticle.getPosition().x, sandParticle.getPosition().y))

			meshInstance.self_modulate = sandParticle.getColor()

			add_child(meshInstance)
			instantiatedMeshes.append(meshInstance)

func addSandToIndex(row: int, column: int) -> void:
	if(sandInIndex(row,column,currentSand)):
		return
	var surfaceTool = SurfaceTool.new()
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var halfCellSize = cellSize/2
				
	# Creates a triangle like the following
	#  *
	#  | \
	#  *--*
	surfaceTool.add_vertex(Vector3(-1 * halfCellSize, -1* halfCellSize, 0))  # Z-value remains 0
	surfaceTool.add_vertex(Vector3(-1* halfCellSize, 1* halfCellSize, 0))
	surfaceTool.add_vertex(Vector3(1* halfCellSize, -1* halfCellSize, 0))

	# Creates a triangle like the following
	#  *--*
	#   \ |
	#     *
	surfaceTool.add_vertex(Vector3(-1 * halfCellSize, 1 * halfCellSize, 0))  # Z-value remains 0
	surfaceTool.add_vertex(Vector3(1* halfCellSize, 1 * halfCellSize, 0))
	surfaceTool.add_vertex(Vector3(1* halfCellSize, -1 * halfCellSize, 0))

	# Commit to a mesh.
	var mesh = surfaceTool.commit()

	var xposition = cellSize * column
	var yposition = cellSize * row
	var sandParticle = Sand.new(mesh, Vector2(xposition,yposition), colors[colorIndex],row,column)
	currentSand[row][column] = sandParticle

func generateNewSand() -> void:
	var sandToMoveDown = []
	for row in range(windowHeight):
		for column in range(windowWidth):
			if(sandInIndex(row,column, currentSand)):
				if(sandShouldMoveDown(row,column, currentSand)):
					sandToMoveDown.append(currentSand[row][column])
				else:
					currentSand[row][column].incrementIterationCount()
	for sand in sandToMoveDown:
		sand.resetIterationCount()
		moveSandDown(sand.getRow(),sand.getColumn(),currentSand)
					

func coordinatesToSand(location: Vector2):
	var row = int(location.y/cellSize)
	var column = int(location.x/cellSize)
	addSandToIndex(row,getClampedColumn(column))

			
func sandInIndex(row: int, column: int,sandArray) -> bool:
	return sandArray[row][column] != null
	
func sandShouldMoveDown(row: int, column: int,sandArray) -> bool:
	if(sandArray[row][column].isDoneMoving()):
		return false
	# Cannot move below the screen
	if(row + 1 >= windowHeight):
		return false
	# Is the space below the sand available	
	if(sandArray[row + 1][column] == null):
		return true
	# Cannot move to the left so only check to move to the right		
	if(column - 1 < 0):
		return sandArray[row + 1][column + 1] == null
	# Cannot move to the right so only check to move to the left			
	if(column + 1 >= windowWidth):
		return sandArray[row + 1][column - 1] == null
	# Will determine if we can move to the left or the right
	return sandArray[row + 1][column + 1] == null || sandArray[row + 1][column - 1] == null
	
func moveSandDown(row: int, column: int, sandArray) -> void:
	# The sand moves to the side
	if (sandInIndex(row +1 , column, sandArray)):
		var direction = directions[rng.randi_range(0,1)]
		if (column + direction > windowWidth -1):
			direction = direction * -1
		elif (column + direction < 0):
			direction = direction * -1
		elif (sandInIndex(row + 1 , column + direction, sandArray)):
			direction = direction * -1
			# We need to make sure the direction does not go out of bounds
			if(column + direction > windowWidth - 1):
				direction = direction * -1		
		sandArray[row + 1][column + direction] = sandArray[row][column]
		sandArray[row][column] = null
		var xposition = cellSize * (column + direction)
		var yposition = cellSize * (row + 1)
		sandArray[row + 1][column + direction].updatePosition(Vector2(xposition,yposition),row+1,column + direction)
		return
	# The sand moves down
	sandArray[row + 1][column] = sandArray[row][column]
	sandArray[row][column] = null
	var xposition = cellSize * column
	var yposition = cellSize * (row + 1)
	sandArray[row + 1][column].updatePosition(Vector2(xposition,yposition),row+1,column)
	
func getClampedColumn(column: int) -> int:
	return clampi(column, 0, windowWidth -1)
	
