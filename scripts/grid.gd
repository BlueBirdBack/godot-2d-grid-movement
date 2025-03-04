# Grid represents a 2D grid system with utility functions for coordinate conversions
# and boundary management. It's designed to be shared among game objects that need
# access to grid properties and calculations.
class_name Grid
extends Resource

## Grid size in columns and rows.
@export var grid_size := Vector2i(20, 12):
	set(value):
		grid_size = value
		_update_cached_values()

## Cell size in pixels (width, height).
@export var cell_size := Vector2(64.0, 64.0):
	set(value):
		cell_size = value
		_update_cached_values()

## Cached value representing half of the cell size, used to calculate cell center positions.
## This optimization reduces repeated calculations in grid-to-world coordinate conversions.
var _cell_center_offset: Vector2

## Called when the resource is first initialized.
func _init() -> void:
	_update_cached_values()

## Updates cached values when properties change.
func _update_cached_values() -> void:
	_cell_center_offset = cell_size / 2.0

## Converts grid cell indices to world position in pixels, returning the cell's center.
## This is essential for aligning game objects precisely within grid cells.
##
## Parameters:
## - `grid_cell`: The grid cell indices (Vector2i) to convert
## Returns: The world position (Vector2) at the center of the specified cell
## Note: If the grid cell is out of bounds, a warning will be logged but the
##       conversion will still be performed.
func grid_to_world(grid_cell: Vector2i) -> Vector2:
	var original_cell = grid_cell
	
	if not is_cell_in_bounds(grid_cell):
		grid_cell = clamp_grid(grid_cell)
		push_warning("Grid cell out of bounds: %s, clamped to %s" % [original_cell, grid_cell])
	
	var world_position = Vector2(grid_cell) * cell_size + _cell_center_offset
	return world_position

## Converts world position in pixels to grid cell indices.
## This is used to determine which grid cell contains a given world position.
##
## Parameters:
## - `world_position`: The world position (Vector2) in pixels to convert
## Returns: The grid cell indices (Vector2i) containing the specified position
## Note: Negative world positions are handled by adjusting the cell indices accordingly.
func world_to_grid(world_position: Vector2) -> Vector2i:
	var grid_cell = Vector2i(world_position / cell_size)
	grid_cell = clamp_grid(grid_cell)
	return grid_cell

## Clamps grid cell indices to ensure they are within the grid's valid range.
## This prevents accessing cells outside the grid's defined size.
##
## Parameters:
## - `grid_cell`: The grid cell indices (Vector2i) to clamp
## Returns: The clamped grid cell indices (Vector2i) within valid bounds
## Note: The valid range is from (0, 0) to (grid_size.x - 1, grid_size.y - 1).
func clamp_grid(grid_cell: Vector2i) -> Vector2i:
	return grid_cell.clamp(Vector2i.ZERO, grid_size - Vector2i.ONE)

## Calculates the total size of the grid in world coordinates (pixels).
## This is useful for determining the physical dimensions of the grid in the game world.
##
## Returns: The total size of the grid as a `Vector2` in pixels.
## Note: The size is calculated by multiplying the grid's dimensions (`grid_size`) 
##       by the size of each cell (`cell_size`).
func get_world_size() -> Vector2:
	return Vector2(grid_size) * cell_size

## Checks if the given grid cell indices are within the grid's valid boundaries.
## This is essential for preventing out-of-bounds access to grid cells.
##
## Parameters:
## - `grid_cell`: The grid cell indices (Vector2i) to check
## Returns: `true` if the cell is within bounds, `false` otherwise
## Note: The valid range is from (0, 0) to (grid_size.x - 1, grid_size.y - 1).
func is_cell_in_bounds(grid_cell: Vector2i) -> bool:
	return (
		grid_cell.x >= 0 and grid_cell.x < grid_size.x
		and grid_cell.y >= 0 and grid_cell.y < grid_size.y
	)

## Checks if a world position (in pixels) is within the grid's valid boundaries.
## This is useful for determining if a point in the game world falls within the grid.
##
## Parameters:
## - `world_position`: The world position (Vector2) in pixels to check
## Returns: `true` if the position is within bounds, `false` otherwise
## Note: The check is performed by converting the world position to grid cell indices
##       and then verifying if those indices are within bounds.
func is_position_in_bounds(world_position: Vector2) -> bool:
	var world_size = get_world_size()
	return (
		world_position.x >= 0.0 and world_position.x < world_size.x
		and world_position.y >= 0.0 and world_position.y < world_size.y
	)
