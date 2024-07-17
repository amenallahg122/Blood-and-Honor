extends ProgressBar

var parent
var max_val
var min_val

func _ready():
	parent = get_parent()
	max_val = get_parent().max_health
	min_val = get_parent().min_health

func _process(_delta):
	self.value = parent.health

