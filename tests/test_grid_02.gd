## Test script for Grid visualization. 
## Demonstrates grid drawing, mouse interaction, and cell coordinate display.
extends Node2D

## Reference to the Grid resource, to be set in the scene.
## Exposed via @export for easier debugging and configuration.
@export var grid: Grid

func _ready():
	if not grid:
		push_error("Grid resource not assigned!")

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not grid:
		return
		
	# Draw grid lines
	for x in range(grid.grid_size.x + 1):
		var start_pos = Vector2(x * grid.cell_size.x, 0)
		var end_pos = Vector2(x * grid.cell_size.x, grid.grid_size.y * grid.cell_size.y)
		draw_line(start_pos, end_pos, Color.DARK_GRAY, 1.0)
	
	for y in range(grid.grid_size.y + 1):
		var start_pos = Vector2(0, y * grid.cell_size.y)
		var end_pos = Vector2(grid.grid_size.x * grid.cell_size.x, y * grid.cell_size.y)
		draw_line(start_pos, end_pos, Color.DARK_GRAY, 1.0)
	
	# Highlight the cell under the mouse cursor
	var mouse_pos = get_viewport().get_mouse_position()
	var current_cell = grid.world_to_grid(mouse_pos)
	
	if grid.is_cell_in_bounds(current_cell):
		var cell_pos = grid.grid_to_world(current_cell) - grid._cell_center_offset
		draw_rect(Rect2(cell_pos, grid.cell_size), Color(1, 0, 0, 0.3))
		_draw_cell_text(current_cell)

	# Draw indices for all grid cells
	# TODO: Consider adding a toggle to control index display for better performance
	for x in range(grid.grid_size.x):
		for y in range(grid.grid_size.y):
			_draw_cell_text(Vector2i(x, y))

## Draws text within a specified grid cell.
##
## Used to display cell coordinate information like "0,0" or "1,2".
##
## Parameters:
## - `cell`: The cell coordinates (Vector2i) where text should be drawn
## Note: Text is automatically centered within the cell
func _draw_cell_text(cell: Vector2i) -> void:
	var text = str(cell.x) + "," + str(cell.y)
	var text_size = ThemeDB.fallback_font.get_string_size(text)
	var cell_pos = grid.grid_to_world(cell)
	var offset = Vector2(- text_size.x / 2, 5)
	draw_string(ThemeDB.fallback_font, cell_pos + offset, text)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_cell = grid.world_to_grid(event.position)
		if grid.is_cell_in_bounds(grid_cell):
			print("Selected cell: ", grid_cell)
			print("World position: ", grid.grid_to_world(grid_cell))
