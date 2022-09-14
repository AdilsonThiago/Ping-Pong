extends CanvasLayer

#Definindo algumas variáveis iniciais

export(NodePath) var ballpath : NodePath
var ball : Object = null
var score = [0, 0]
export(NodePath) var player1 : NodePath
export(NodePath) var player2 : NodePath
var players : Array = [null, null]
var itens : Array = []

#Carregando as cenas dos "power ups"

onready var energy = preload("res://Assets/Game/Itens/Energy.tscn")
onready var upscal = preload("res://Assets/Game/Itens/Upscale.tscn")
onready var stopob = preload("res://Assets/Game/Itens/Stop.tscn")
onready var ballsp = preload("res://Assets/Game/Itens/Ballspeed.tscn")
onready var barier = preload("res://Assets/Game/Itens/Liferev.tscn")

#Iniciando timers para criação dessas cenas. Optei por fazer por código em vez de usar o node timer.

var energydelay = 5
var upscaldelay = 10
var stopobdelay = 15
var ballspdelay = 10
var barierdelay = 20

func _ready():
	#ballpath, player1 e player2 são variáveis que tiveram seu valor atribuído no inspetor do "HUD".
	ball = get_node(ballpath)
	players[0] = get_node(player1)
	players[1] = get_node(player2)
	ball.connect("score", self, "player_scored")
	player_scored(-1)
	itens.clear()
	pass

func _process(delta):
	randomize()
	
	#Contando os timers de geração de power ups
	energydelay -= delta
	upscaldelay -= delta
	stopobdelay -= delta
	ballspdelay -= delta
	barierdelay -= delta
	
	#Geração dos power ups e resetamento do timer
	if energydelay <= 0:
		generate_item(energy)
		energydelay = rand_range(8, 8)
	if upscaldelay <= 0:
		generate_item(upscal)
		upscaldelay = rand_range(15, 18)
	if stopobdelay <= 0:
		generate_item(stopob)
		stopobdelay = rand_range(22, 28)
	if ballspdelay <= 0:
		generate_item(ballsp)
		ballspdelay = rand_range(15, 20)
	if barierdelay <= 0:
		generate_item(barier)
		barierdelay = rand_range(26, 35)
	pass

func generate_item(packed):
	#O evento está condicionado a lista de intens não ter ultrapassado 5 de tamanho.
	if itens.size() < 5:
		var o = packed.instance()
		o.translation = Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15))
		get_parent().add_child(o)
		itens.append(o)
	pass

func remove_item(ref_id):
	#Método usado para remover itens da lista que não existem mais
	for i in range(itens.size()):
		if itens[i] == ref_id:
			itens.remove(i)
			return
	pass

func player_scored(player):
	#Evento chamado por sinal. O label recebe as novas informações e atualiza.
	if player >= 0:
		score[player] += 1
	$Label.text = "Your score: " + str(score[0])
	$Label.text += "\nCpu score: " + str(score[1])
	#Removendo todos os efeitos dos power ups...
	players[0].reset()
	players[1].reset()
	#Removendo os itens que sobraram no cenário.
	for i in range(itens.size()):
		itens[i].queue_free()
	itens.clear()
	pass

func item(effect, playerside):
	#Método chamado pelo código "Item.gd"
	#Nesse método é aplicado o efeito do "power up" de acordo com quem acertou o item
	var id = 0
	var opid = 0
	if playerside == 1:
		id = 0
		opid = 1
	elif playerside == -1:
		id = 1
		opid = 0
	else:
		#As vezes a bolinha pode ainda não ter batido em nenhum jogador.
		#Nesse caso pedimos apenas para sair do método
		return
	
	if effect == "up_speed":
		players[id].change_speed(2.5, true)
	elif effect == "up_scale":
		players[id].change_scale(0.3, true)
	elif effect == "stop":
		players[opid].stop(0.35)
	elif effect == "ball_speed":
		ball.change_speed(- 5, true)
	elif effect == "life_rev":
		players[id].barrier()
	pass
