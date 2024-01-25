extends Node2D

# The lower this is set, the tiner the sand. It will get pretty hard to run though
var cellSize: int = 6
# This is the hardcoded width of the window divided by the cells size
var windowWidth: int = -1
# This is the hardcoded height of the window divided by the cells size
var windowHeight: int = -1
# The current state of the sand in the simulation
var currentSand: Array = []
# Holds the meshes that will be used to visualize the sand simulation
var meshInstances: Array[Variant] = []
# Holds the directions that the sand can go in
var directions: Array[int] = [-1, 1]
# What color to pick from the colors array
var colorIndex: int = -1
# The colors in order in which they will be displayed
var colors: Array[Variant] = []

var colorSchemes: Array[Variant] = [
	["#a8e0ff", "#8ee3f5", "#70cad1", "#3e517a", "#b08ea2"],
	["#dce0d9", "#31081f", "#6b0f1a", "#595959", "#808f85"],
	["#247ba0", "#70c1b3", "#b2dbbf", "#f3ffbd", "#ff1654"],
	["#644536", "#b2675e", "#c4a381", "#bbd686", "#eef1bd"],
	["#453823", "#561f37", "#39a2ae", "#55dbcb", "#75e4b3"],
	["#f9e7e7", "#ded6d6", "#d2cbcb", "#ada0a6", "#7d938a"],
	["#48acf0", "#594236", "#6f584b", "#93a3bc", "#ccdde2"],
	["#fa8334", "#fffd77", "#ffe882", "#388697", "#271033"],
	["#ebd4cb", "#da9f93", "#b6465f", "#890620", "#2c0703"],
	["#01baef", "#0cbaba", "#380036", "#26081c", "#150811"],
	["#c9f2c7", "#aceca1", "#96be8c", "#629460", "#243119"],
]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready():
	colors = colorSchemes[rng.randi_range(0, colorSchemes.size()-1)]
	windowWidth = (480/cellSize)
	windowHeight = (720/cellSize)

	for row in range(windowHeight):
		var sandRow: Array[Variant] = []
		var sandRowMeshes: Array[Variant] = []
		for column in range(windowWidth):
			sandRow.append(null)
			var surfaceTool: SurfaceTool = SurfaceTool.new()
			surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
			var halfCellSize: int = cellSize/2

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
			var mesh: ArrayMesh = surfaceTool.commit()

			var xposition = cellSize * column
			var yposition = cellSize * row
			var meshInstance: MeshInstance2D = MeshInstance2D.new()
			meshInstance.hide()

			meshInstance.mesh = mesh as Mesh
			meshInstance.translate(Vector2(xposition, yposition))

			add_child(meshInstance)
			sandRowMeshes.append(meshInstance)
		meshInstances.append(sandRowMeshes)
		currentSand.append(sandRow)
	print("Column amount: ", windowWidth)
	print("Row amount: ", windowHeight)
	pass


func _process(delta):
	if Input.is_action_just_pressed("reset"):
		resetSimulation()
	if Input.is_action_just_pressed("left"):
		colorIndex = (colorIndex + 1) % (colors.size())
	if Input.is_action_pressed("left"):
		var mousePosition: Vector2 = get_global_mouse_position()
		coordinatesToSand(mousePosition)
	generateNewSand()
	drawSand()
	pass


func drawSand():
	for row in range(windowHeight):
		var sandParticleRow = currentSand[row]
		for column in range(windowWidth):
			var sandParticle = sandParticleRow[column]
			if(sandParticle == null):
				meshInstances[row][column].hide()
				continue
			meshInstances[row][column].self_modulate = sandParticle.getColor()
			meshInstances[row][column].show()


func addSandToIndex(row: int, column: int) -> void:
	if(sandInIndex(row, column, currentSand)):
		return
	var sandParticle = Sand.new(colors[colorIndex], row, column)
	currentSand[row][column] = sandParticle


func generateNewSand() -> void:
	var sandToMoveDown: Array[Variant] = []
	# Look through every location to see if the sand should move down
	for row in range(windowHeight):
		for column in range(windowWidth):
			if(sandInIndex(row, column, currentSand) && !currentSand[row][column].isDoneMoving()):
				if(sandShouldMoveDown(row, column, currentSand)):
					sandToMoveDown.append(currentSand[row][column])
				else:
					currentSand[row][column].incrementIterationCount()
					# Move all the sand down that we need to
	for sand in sandToMoveDown:
		sand.resetIterationCount()
		moveSandDown(sand.getRow(), sand.getColumn(), currentSand)


func coordinatesToSand(location: Vector2):
	var row: int = int(location.y/cellSize)
	var column: int = int(location.x/cellSize)
	addSandToIndex(getClampedRow(row), getClampedColumn(column))


func sandInIndex(row: int, column: int, sandArray) -> bool:
	return sandArray[row][column] != null


func sandShouldMoveDown(row: int, column: int, sandArray) -> bool:
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
	if (sandInIndex(row + 1, column, sandArray)):
		var direction: int = directions[rng.randi_range(0, 1)]
		if (column + direction > windowWidth -1):
			direction = direction * -1
		elif (column + direction < 0):
			direction = direction * -1
		elif (sandInIndex(row + 1, column + direction, sandArray)):
			direction = direction * -1
			# We need to make sure the direction does not go out of bounds
			if(column + direction > windowWidth - 1):
				direction = direction * -1
		sandArray[row + 1][column + direction] = sandArray[row][column]
		sandArray[row][column] = null
		sandArray[row + 1][column + direction].updatePosition(row + 1, column + direction)
		return
		# The sand moves down
	sandArray[row + 1][column] = sandArray[row][column]
	sandArray[row][column] = null
	sandArray[row + 1][column].updatePosition(row + 1, column)


func getClampedColumn(column: int) -> int:
	return clampi(column, 0, windowWidth - 1)


func getClampedRow(row: int) -> int:
	return clampi(row, 0, windowHeight - 1)


func resetSimulation() -> void:
	if Input.is_action_pressed("left"):
		colorIndex = 0
	else:
		colorIndex = -1
	colors = colorSchemes[rng.randi_range(0, colorSchemes.size()-1)]
	currentSand = []
	for row in range(windowHeight):
	var sandRow: Array[Variant] = []
		for column in range(windowWidth):
			sandRow.append(null)
		currentSand.append(sandRow)
	print("Column amount: ", windowWidth)
	print("Row amount: ", windowHeight)
	drawSand()
	
