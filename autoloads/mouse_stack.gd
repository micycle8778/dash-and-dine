extends Node

var stack: Array[Input.MouseMode]

func _input(event: InputEvent) -> void:
	if not OS.has_feature("web"): return
	if stack.is_empty(): return
	if event is InputEventMouseButton and stack[-1] == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Puts a mouse mode onto the stack, effectively setting the mouse mode
func push(mode: Input.MouseMode) -> void:
	stack.push_back(mode)
	Input.mouse_mode = mode

## Removes the most recent mouse mode from the stack
func pop(mode: Input.MouseMode) -> void:
	stack.pop_at(stack.rfind(mode))
	if stack.is_empty():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = stack.back()

## Clears the stack and pushes a mouse mode
func override(mode: Input.MouseMode) -> void:
	stack = [mode]
	Input.mouse_mode = mode
