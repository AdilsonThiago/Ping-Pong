extends KinematicBody

#Definindo variáveis

export(bool) var bot_control : bool = false
export(float) var normal_speed : float = 6
export(NodePath) var ball : NodePath
var ballref = null
var speed : float
var stop_delay : float = 0
var ob_barrier : Object = null
export(int) var side : int = 1

#Carregando a cena de barreira usada para o "power up" do coração

onready var packed_barrier = preload("res://Assets/Game/Itens/Barrier.tscn")

func _ready():
	speed = normal_speed
	ballref = get_node(ball)
	pass

func _physics_process(delta):
	#"stop_delay" é uma variável que esta sendo usada para travar a movimentação pelo "power_up" "stop"
	if stop_delay > 0:
		stop_delay -= delta
	else:
		if bot_control:
			var predictpos = ballref._predict()
			var move_vec : Vector3
			if predictpos.x > translation.x + 2:
				move_vec = Vector3(1, 0, 0)
			elif predictpos.x < translation.x - 2:
				move_vec = Vector3(-1, 0, 0)
			if abs(move_vec.x) > 0:
				move_and_collide(move_vec * speed * delta)
		else:
			var move_vec : Vector3
			if Input.is_action_pressed("b_left"):
				move_vec = Vector3(side, 0, 0)
			elif Input.is_action_pressed("b_right"):
				move_vec = Vector3(-side, 0, 0)
			elif Input.is_action_just_pressed("b_escape"):
				get_tree().quit()
			move_and_collide(move_vec * speed * delta)
	pass

func reset():
	#Método de trazer as configurações iniciais da cena
	change_speed(normal_speed, false)
	change_scale(1, false)
	stop(0)
	if not ob_barrier == null:
		#Removendo a barreira de "power up" caso exista
		ob_barrier.queue_free()
	ob_barrier = null
	pass

#A partir daqui todos os métodos abaixos são usados para aplicar os efeitos dos "power ups"

func change_speed(value, relative):
	if relative:
		speed += 3
	else:
		speed = normal_speed
	pass

func change_scale(value, relative):
	if relative:
		$MeshInstance.scale += Vector3(0, 0, 1) * value
		$CollisionShape.shape.height += 5 * value
	else:
		$MeshInstance.scale = Vector3(1, 1, value)
		$CollisionShape.shape.height = 5 * value
	pass

func stop(time):
	stop_delay = time
	pass

func barrier():
	if ob_barrier == null:
		ob_barrier = packed_barrier.instance()
		ob_barrier.translation = Vector3(0, translation.y, translation.z -side * 2.5)
		get_parent().add_child(ob_barrier)
		ob_barrier.player = self
	pass
