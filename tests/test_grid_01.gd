extends Node2D

## Reference to the Grid resource, to be set in the scene
@export var grid: Grid

func _ready():
	if grid:
		run_tests()
	else:
		push_error("Grid resource not assigned!")

func run_tests():
	print("Running Grid tests...")
	
	# Test grid_to_world conversion
	var test_cell = Vector2i(3, 4)
	var expected_world = Vector2(3 * grid.cell_size.x, 4 * grid.cell_size.y) + grid._cell_center_offset
	var actual_world = grid.grid_to_world(test_cell)
	print("Test grid_to_world (3,4): ", actual_world == expected_world)
	
	# Test world_to_grid conversion
	var test_world = Vector2(250.0, 300.0)
	var expected_cell = Vector2i(3, 4)
	var actual_cell = grid.world_to_grid(test_world)
	print("Test world_to_grid (250.0,300.0): ", actual_cell == expected_cell)
	
	# Test is_cell_in_bounds
	print("Test is_cell_in_bounds (in bounds): ", grid.is_cell_in_bounds(Vector2i(5, 5)))
	print("Test is_cell_in_bounds (out of bounds): ", !grid.is_cell_in_bounds(Vector2i(20, 20)))
	
	# Test clamp_grid
	var out_of_bounds = Vector2i(30, 30)
	var clamped = grid.clamp_grid(out_of_bounds)
	print("Test clamp_grid (out of bounds): ", clamped == Vector2i(19, 11))

	# Test is_position_in_bounds
	print("Test is_position_in_bounds (in bounds): ", grid.is_position_in_bounds(Vector2(100.0, 100.0)))
	print("Test is_position_in_bounds (out of bounds): ", !grid.is_position_in_bounds(Vector2(2000.0, 2000.0)))
	
	# Test boundary conditions
	test_boundary_conditions()

func test_boundary_conditions():
	# Test grid_to_world with boundary values
	var zero_cell = Vector2i.ZERO
	var expected_zero_world = grid._cell_center_offset
	print("Test grid_to_world (0,0): ", grid.grid_to_world(zero_cell) == expected_zero_world)
	
	var max_cell = grid.grid_size - Vector2i.ONE
	var expected_max_world = Vector2((grid.grid_size.x - 1) * grid.cell_size.x, (grid.grid_size.y - 1) * grid.cell_size.y) + grid._cell_center_offset
	print("Test grid_to_world (19,11): ", grid.grid_to_world(max_cell) == expected_max_world)

	# Test grid_to_world with out of bounds cell
	var edge_cell = grid.grid_size
	var expected_edge_world = Vector2((grid.grid_size.x - 1) * grid.cell_size.x, (grid.grid_size.y - 1) * grid.cell_size.y) + grid._cell_center_offset
	print("Test grid_to_world (20,12): ",
		grid.grid_to_world(edge_cell) == expected_edge_world,
		" (expected: ", expected_edge_world,
		", got: ", grid.grid_to_world(edge_cell),
		") - Cell should be clamped to (19,11)")

	var out_of_bounds_cell = Vector2i(-2, -2)
	var expected_out_of_bounds_world = Vector2.ZERO + grid._cell_center_offset
	print("Test grid_to_world (-2,-2): ",
		grid.grid_to_world(out_of_bounds_cell) == expected_out_of_bounds_world,
		" (expected: ", expected_out_of_bounds_world,
		", got: ", grid.grid_to_world(out_of_bounds_cell),
		") - Cell should be clamped to (0,0)")

	# Test world_to_grid with boundary values
	var zero_world = Vector2.ZERO
	print("Test world_to_grid (0.0,0.0): ", grid.world_to_grid(zero_world) == Vector2i.ZERO)
	
	var edge_world = Vector2(63.9, 63.9)
	print("Test world_to_grid (63.9,63.9): ", grid.world_to_grid(edge_world) == Vector2i.ZERO)
	
	# Test negative coordinates
	var negative_world = Vector2(-10.0, -10.0)
	print("Test world_to_grid (negative): ", grid.world_to_grid(negative_world) == Vector2i.ZERO)

	# Test clamp_grid with negative values
	var negative_cell = Vector2i(-5, -5)
	print("Test clamp_grid (negative): ", grid.clamp_grid(negative_cell) == Vector2i.ZERO)
	
	# Test get_world_size
	var expected_size = Vector2(grid.grid_size.x * grid.cell_size.x, grid.grid_size.y * grid.cell_size.y)
	print("Test get_world_size: ", grid.get_world_size() == expected_size)

	# Test is_cell_in_bounds with boundary values
	print("Test is_cell_in_bounds (0,0): ", grid.is_cell_in_bounds(Vector2i.ZERO))
	print("Test is_cell_in_bounds (19,11): ", grid.is_cell_in_bounds(grid.grid_size - Vector2i.ONE))
	print("Test is_cell_in_bounds (negative): ", !grid.is_cell_in_bounds(Vector2i(-1, -1)))
	
	# Test is_position_in_bounds with boundary values
	print("Test is_position_in_bounds (0.0,0.0): ", grid.is_position_in_bounds(Vector2.ZERO))
	var max_world = grid.get_world_size() - Vector2.ONE
	print("Test is_position_in_bounds (max): ", grid.is_position_in_bounds(max_world))
	print("Test is_position_in_bounds (negative): ", !grid.is_position_in_bounds(Vector2(-10.0, -10.0)))