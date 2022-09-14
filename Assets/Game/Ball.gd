extends RigidBody

#Definições de variáveis

var speed : float = 8
var reset : bool = false
var delay : float = 0
var side = 0
export(float) var acum_speed = 2
signal score

func _ready():
	#Inicio de jogo, lançar a bolinha
	trown()
	pass

func _process(delta):
	if delay > 0:
		#Contador usado por conta de ser demorado a atualização de posição pelo método "_integrate_forces"
		delay -= delta
	elif abs(translation.z) > 25:
		if not reset:
			if translation.z > 0:
				emit_signal("score", 0)
			else:
				emit_signal("score", 1)
			delay = 1
			side = 0
		reset = true
		trown()
	pass

func trown():
	#Comando de relançar a bolinha (chamado no início do jogo)
	linear_velocity = Vector3(rand_range(3, 5), 0, rand_range(4, 7))
	if floor(rand_range(0, 2)) == 1:
		linear_velocity.z = - linear_velocity.z
	if floor(rand_range(0, 2)) == 1:
		linear_velocity.x = - linear_velocity.x
	change_speed(8, false)
	pass

func _on_RigidBody_body_entered(body):
	if body.is_in_group("player"):
		#Foi verificado uma colisão da bolinha com o jogador.
		#Para dificultar o jogo aplico uma aceleração pequena nesse evento.
		change_speed(acum_speed, true)
		side = body.side
	pass

func change_speed(value, relative):
	#Método usado para resetar ou fazer alteração relativa da velocidade de movimentação
	if relative:
		speed += value
		linear_velocity = linear_velocity.normalized() * speed
	else:
		speed = value
		linear_velocity = linear_velocity.normalized() * speed
	pass

func _predict() -> Vector3:
	#Predicção de movimentação básica para o "BOT" tentar jogar de forma inteligente.
	if linear_velocity.z > 0:
		var p1 : Vector3 = translation
		var p2 : Vector3
		var p : Vector3 = p1
		var time = (40 - (20 + p1.z)) / linear_velocity.z
		p2 = translation + Vector3(time * linear_velocity.x, 0, time * linear_velocity.z)
		if abs(p2.x) > 18:
			var offset = (abs(p2.x) - 18) * -sign(p2.x)
			p2.x = sign(p2.x) * 18 + offset
		return p2
	return Vector3(0, 0, 0)
	pass

func _integrate_forces(state):
	#Os nodes de física não permitem alterar a posição. Ao invéz disso nós usamos esse método
	if reset:
		var xy = state.get_transform()
		xy.origin = Vector3(0, -1, 0)
		state.set_transform(xy)
		reset = false
	pass
