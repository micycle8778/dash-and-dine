extends Node

var stack: Array[Input.MouseMode]

func _ready() -> void:
	if OS.has_feature("web"):
		var js_code = """
		document.addEventListener("click", function () {
		document.body.requestPointerLock();});
		"""
		JavaScriptBridge.eval(js_code, true)

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
