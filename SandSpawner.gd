extends Node2D

var cellSize: int = 8
# This is the hardcoded width of the window divided by the cells size
var windowWidth: int = -1
# This is the hardcoded height of the window divided by the cells size
var windowHeight: int = -1

var rng = RandomNumberGenerator.new()

var colors = [Color.WHITE, Color.RED, Color.GREEN, Color.BLUE]

var timeBetween: float = 0
var drawThreshold: float = .001
var instantiatedMeshes = []
var finishedParticles = []
var currentSand: Array = []
var index: Array = []

var rowsComplete: Array[bool] = []
var meshInstances: Array = []

var newSandTest = []

var temp = 0
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
		meshInstances.append(sandRowMeshes)
		currentSand.append(sandRow)
		newSandTest.append(sandRow)
	print("Column amount: ", windowWidth)
	print("Row amount: ", windowHeight)
	pass

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("left"):
		var mouse_position: Vector2 = get_global_mouse_position()
		coordinatesToSand(mouse_position)
	timeBetween = timeBetween + delta
	#if(timeBetween < drawThreshold):
		#return
	timeBetween = 0
	#temp = temp + 1
	#if(temp > 10):
		#var t = 0
		#while(t<windowWidth):
			#addSandToIndex(0,t)
			#t = t + 1				
		#temp = 0	
	for instance in instantiatedMeshes:
		remove_child(instance)
	instantiatedMeshes = []
	generateNewSand()
	drawSand()
	pass
	
func drawSand():
	#for finishedSand in finishedParticles:
		#add_child(finishedSand)
	for row in range(windowHeight):
	#for sandParticleRow in currentSand:
		var sandParticleRow = currentSand[row]
		for column in range(windowWidth):		
		#for sandParticle in sandParticleRow:
			var sandParticle = sandParticleRow[column]
			if(sandParticle == null || sandParticle.isMeshSaved() && sandParticle.isFinalDestinationReached()):
				continue
			var meshInstance = MeshInstance2D.new()			

			meshInstance.mesh = sandParticle.getMesh()
			meshInstance.translate(Vector2(sandParticle.getPosition().x, sandParticle.getPosition().y))

			meshInstance.self_modulate = sandParticle.getColor()

			add_child(meshInstance)
			instantiatedMeshes.append(meshInstance)
			
			#if(!sandParticle.isFinalDestinationReached()):
				#instantiatedMeshes.append(meshInstance)
			#else:
				#print("adding to finished")
				#sandParticle.setMeshSaved()
				#finishedParticles.append(meshInstance)

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
	var sandParticle = Sand.new(mesh, Vector2(xposition,yposition), colors[rng.randi_range(0,colors.size()-1)],row,column)
	currentSand[row][column] = sandParticle

func generateNewSand() -> void:
	var sandToMoveDown = []
	for row in range(windowHeight):
		if (!isRowComplete(currentSand[row])):
			for column in range(windowWidth):
				if(sandInIndex(row,column, currentSand)):
					if(sandShouldMoveDown(row,column, currentSand)):
						sandToMoveDown.append(currentSand[row][column])
					else:
						newSandTest[row][column].setFinalDestinationReached()
	for sand in sandToMoveDown:
		moveSandDown(sand.getRow(),sand.getColumn(),currentSand)
					
			
func isRowComplete(sandArray: Array) -> bool:
	return sandArray.reduce(func(accum, sand): return accum && (sand == null || sand.isFinalDestinationReached()), false)


func coordinatesToSand(location: Vector2):
	var row = int(location.y/cellSize)
	var column = int(location.x/cellSize)
	addSandToIndex(row,column)

			
func sandInIndex(row: int, column: int,sandArray) -> bool:
	# TODO add logic here to block leaving the window trying to make sand
	return sandArray[row][column] != null
	
func sandShouldMoveDown(row: int, column: int,sandArray) -> bool:
	if(row + 1 > windowHeight-1):
		return false
	return sandArray[row + 1][column] == null || sandArray[row + 1][column +1] == null || sandArray[row + 1][column -1] ==null
	
func moveSandDown(row: int, column: int, sandArray) -> void:
	if (sandInIndex(row +1 , column, sandArray)):
		var direction = rng.randi_range(0,1)
		if(direction == 0):
			direction = -1
		if (sandInIndex(row +1 , column + direction, sandArray)):
			direction = direction * -1
		sandArray[row + 1][column + direction] = sandArray[row][column]
		sandArray[row][column] = null
		var xposition = cellSize * (column + direction)
		var yposition = cellSize * (row + 1)
		print("direction: ", direction)
		print("col ",column," new column: ", column + direction, sandArray[row + 1][column + direction])
		sandArray[row + 1][column + direction].updatePosition(Vector2(xposition,yposition),row+1,column + direction)
		return
		
	sandArray[row + 1][column] = sandArray[row][column]
	sandArray[row][column] = null
	var xposition = cellSize * column
	var yposition = cellSize * (row + 1)
	sandArray[row + 1][column].updatePosition(Vector2(xposition,yposition),row+1,column)
	
