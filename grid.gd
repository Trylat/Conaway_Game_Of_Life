extends TileMap

const TILE_SIZE = 64

@export var width : int
@export var height : int
var I_screen_size = DisplayServer.screen_get_size()
var I_view_port
var screen_size :Vector2 = Vector2(1.0,1.0)
var view_port : Vector2 = Vector2(1.0,1.0)

var is_playing : bool = false
var temp_field

func _ready():
	ajust_cam()
	temp_field = []
	for x in range(width):
		var temp = []
		for y in range(height):
			set_cell(0,-Vector2i(x,y),5,Vector2i(0,0),0)
			temp.append(0)
			#print(x,", ",y)
		temp_field.append(temp)


func _process(delta):
	ajust_cam()
	if is_playing:
		update_field()

func _input(event):
	if event.is_action_pressed("play"):
		is_playing = !is_playing 
		
	if event.is_action_pressed("click"):
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		var alter = get_cell_alternative_tile(0,pos)
		set_cell(0,pos,5,Vector2i(0,0),1-alter) #quick change alternative ID between 0 and 1 (1-0 = 1, 1-1 = 0)


func update_field():
	#update temp field based on number of living neigbur cells
	for x in range(width):
		for y in range(height):
			#print("Pos: ", x,", ",y)
			var neighbor_alive = 0
			for x_off in [-1,0,1]:
				for y_off in [-1, 0, 1]:
					#print("Offset: ", x_off, ", ", y_off)
					if x_off != y_off or x_off != 0:
						if get_cell_alternative_tile(0, -Vector2i(x+x_off, y+y_off)) == 1:
							neighbor_alive += 1  # Chcek all 9 surrouding cells and add those who are alive
					
			if get_cell_alternative_tile(0, -Vector2i(x,y)) == 1:
				if neighbor_alive in [2, 3]:
					temp_field[x][y] = 1
				else:
					temp_field[x][y] = 0
			else:
				if neighbor_alive == 3:
					temp_field[x][y] = 1
				else:
					temp_field[x][y] = 0
	# Update the grid
	for x in range(width):
		for y in range(height):
			set_cell(0,-Vector2i(x,y),5,Vector2(0,0),temp_field[x][y])

func ajust_cam():
	I_view_port = DisplayServer.screen_get_size()
	I_screen_size = DisplayServer.window_get_size_with_decorations()
	screen_size = I_screen_size
	view_port = I_view_port
	var ratio =  screen_size / view_port
	#print(ratio)
	var width_px = (width-1) * TILE_SIZE
	var heigth_px = (height-1) * TILE_SIZE
	var cam = $Camera2D
	cam.position = -(Vector2(width_px,heigth_px)/2)
	cam.zoom = screen_size/ Vector2(width_px,heigth_px)
	#print(cam.zoom)
