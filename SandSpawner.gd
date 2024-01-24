extends Node2D

var cellSize: int = 10
# This is the hardcoded width of the window divided by the cells size
var windowWidth: int = -1
# This is the hardcoded height of the window divided by the cells size
var windowHeight: int = -1

var rng = RandomNumberGenerator.new()

var colors = [Color.WHITE, Color.RED, Color.GREEN, Color.BLUE]

var timeBetween: float = .1
var drawThreshold: float = .04
var instantiatedMeshes = []
var currentSand: Array = []
var index: Array = []
var newSand = []

var temp = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	windowWidth = (480/cellSize)
	windowHeight = (720/cellSize)

	for row in range(windowHeight):
		var sandRow = []
		for column in range(windowWidth):
			sandRow.append(null)
		currentSand.append(sandRow)
	print("Column amount: ", windowWidth)
	print("Row amount: ", windowHeight)
	pass # Replace with function body.
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timeBetween = timeBetween + delta
	if(timeBetween < drawThreshold):
		return
	timeBetween = 0
	temp = temp + 1
	if(temp > 10):
		var t = 0
		while(t<48):
			addSandToIndex(0,t)
			t = t + 1				
		temp = 0	
	for instance in instantiatedMeshes:
		remove_child(instance)
	instantiatedMeshes = []
	currentSand = generateNewSand()

	
	drawSand()
	pass
	
func drawSand():

	for sandParticleRow in currentSand:
		for sandParticle in sandParticleRow:		
			if(sandParticle == null):
				continue
			var meshInstance = MeshInstance2D.new()
			meshInstance.mesh = sandParticle.getMesh()
			meshInstance.translate(Vector2(sandParticle.getPosition().x, sandParticle.getPosition().y))

			meshInstance.self_modulate = sandParticle.getColor() #Color(1, 0, 0)

			add_child(meshInstance)
			# TODO only append sand that is not done moving
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
	var sandParticle = Sand.new(mesh, Vector2(xposition,yposition), colors[rng.randi_range(0,3)])
	currentSand[row][column] = sandParticle

func generateNewSand() -> Array:
	var newSand = currentSand.duplicate(true)
	for row in range(windowHeight):
		for column in range(windowWidth):
			if(sandInIndex(row,column, currentSand)):
				if(sandShouldMoveDown(row,column, currentSand)):
					moveSandDown(row,column,newSand)
	return newSand
					
			
func sandInIndex(row: int, column: int,sandArray) -> bool:
	return sandArray[row][column] != null
	
func sandShouldMoveDown(row: int, column: int,sandArray) -> bool:
	if(row + 1 >= windowHeight):
		return false
	return sandArray[row + 1][column] == null
	
func moveSandDown(row: int, column: int, sandArray) -> void:
	sandArray[row + 1][column] = sandArray[row][column]
	sandArray[row][column] = null
	var xposition = cellSize * column
	var yposition = cellSize * (row + 1)
	sandArray[row + 1][column].updatePosition(Vector2(xposition,yposition))
	
