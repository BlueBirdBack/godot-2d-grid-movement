## Test script for Grid functionality. Demonstrates grid-to-world coordinate conversion
## and cell movement within grid boundaries.
extends Node2D

## Reference to the Grid resource for testing grid calculations.
@export var grid: Grid

# Current cell being moved and its grid position
var cell = null
var current_grid_pos = Vector2i(5, 5) # Track current grid position

# Initialize test environment and validate grid resource.
func _ready():
	if not grid:
		push_error("Grid resource not assigned!")

	# Create a test cell to visualize grid movement
	cell = ColorRect.new()
	cell.size = grid.cell_size
	cell.color = Color(0, 0.7, 1, 0.6)
	add_child(cell)
	
	# Position cell at grid center for initial test
	move_cell_to_grid(current_grid_pos)
	
	print("Initial grid position:", current_grid_pos)
	print("Initial world position:", grid.grid_to_world(current_grid_pos))

## Moves the test cell to specified grid position if within bounds.
##
## Parameters:
## - `grid_pos`: Target grid position (Vector2i) to move to
## Returns: `true` if move was successful, `false` if position was out of bounds
func move_cell_to_grid(grid_pos):
	print("Attempting to move to: ", grid_pos)
	print("Boundary check result: ", grid.is_cell_in_bounds(grid_pos))
	if grid.is_cell_in_bounds(grid_pos):
		var world_pos = grid.grid_to_world(grid_pos)
		cell.position = world_pos - cell.size / 2
		current_grid_pos = grid_pos # Update current position
		print("Move successful, current position: ", current_grid_pos)
		return true
	print("Move failed, staying at: ", current_grid_pos)
	return false

# Handle keyboard input for grid navigation.
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var new_grid_pos = current_grid_pos
		
		# Calculate new position based on arrow key input
		if event.keycode == KEY_RIGHT:
			new_grid_pos += Vector2i(1, 0)
		elif event.keycode == KEY_LEFT:
			new_grid_pos += Vector2i(-1, 0)
		elif event.keycode == KEY_DOWN:
			new_grid_pos += Vector2i(0, 1)
		elif event.keycode == KEY_UP:
			new_grid_pos += Vector2i(0, -1)
		
		print("Key pressed, calculating new position: ", new_grid_pos)
		print("Current position:   ", current_grid_pos)
		
		# Only move if within bounds
		if grid.is_cell_in_bounds(new_grid_pos):
			move_cell_to_grid(new_grid_pos)
		else:
			print("New position out of bounds, not moving")

func _process(_delta):
	# Add this method to redraw every frame
	queue_redraw()

func _draw():
	# Draw current grid coordinates at the center of the blue square
	if cell:
		_draw_cell_text(current_grid_pos)

## Draws grid coordinates at the center of the current cell.
##
## Parameters:
## - `grid_cell`: The grid cell (Vector2i) to display coordinates for
func _draw_cell_text(grid_cell: Vector2i) -> void:
	var text = str(grid_cell.x) + "," + str(grid_cell.y)
	var text_size = ThemeDB.fallback_font.get_string_size(text)
	var cell_pos = grid.grid_to_world(grid_cell)
	var offset = Vector2(- text_size.x / 2, 5)
	draw_string(ThemeDB.fallback_font, cell_pos + offset, text)
