extends CanvasLayer

#Definindo algumas variáveis iniciais

export(NodePath) var ballpath : NodePath
var ball : Object = null
var score = [0, 0]
export(NodePath) var player1 : NodePath
export(NodePath) var player2 : NodePath
var players : Array = [null, null]
var itens : Array = []
var multiplayer_running = false
var iten_id_cont = 0

#Carregando as cenas dos "power ups"

var energy = "res://Assets/Game/Itens/Energy.tscn"
var upscal = "res://Assets/Game/Itens/Upscale.tscn"
var stopob = "res://Assets/Game/Itens/Stop.tscn"
var ballsp = "res://Assets/Game/Itens/Ballspeed.tscn"
var barier = "res://Assets/Game/Itens/Liferev.tscn"

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
	if Networking._is_running_multiplayer():
		players[0].set_network_master(Networking.players[0][0])
		players[1].set_network_master(Networking.players[1][0])
		players[1].bot_control = false
		ball.set_network_master(Networking.players[0][0])
		set_network_master(Networking.players[0][0])
		multiplayer_running = Networking._is_running_multiplayer()
		Networking._attach_player_node(0, players[0])
		Networking._attach_player_node(1, players[1])
		if Networking._is_server():
			players[0].get_node("Camera").current = true
		else:
			players[1].get_node("Camera").current = true
			set_process(false)
	else:
		players[0].get_node("Camera").current = true
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
		if multiplayer_running:
			rpc("generate_item", energy, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		else:
			generate_item(energy, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		energydelay = rand_range(8, 8)
	if upscaldelay <= 0:
		if multiplayer_running:
			rpc("generate_item", upscal, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		else:
			generate_item(upscal, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		upscaldelay = rand_range(15, 18)
	if stopobdelay <= 0:
		if multiplayer_running:
			rpc("generate_item", stopob, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		else:
			generate_item(stopob, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		stopobdelay = rand_range(22, 28)
	if ballspdelay <= 0:
		if multiplayer_running:
			rpc("generate_item", ballsp, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		else:
			generate_item(ballsp, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		ballspdelay = rand_range(15, 20)
	if barierdelay <= 0:
		if multiplayer_running:
			rpc("generate_item", barier, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		else:
			generate_item(barier, Vector3(rand_range(-15, 15), -0.5, rand_range(-15, 15)))
		barierdelay = rand_range(26, 35)
	pass

remotesync func generate_item(packed, pos):
	#O evento está condicionado a lista de intens não ter ultrapassado 5 de tamanho.
	if itens.size() < 5:
		var o = load(packed).instance()
		o.translation = pos
		get_parent().add_child(o)
		itens.append(o)
		o.name = str("item") + str(iten_id_cont)
		iten_id_cont += 1
	pass

func remove_item(ref_id):
	#Método usado para remover itens da lista que não existem mais
	for i in range(itens.size()):
		if itens[i] == ref_id:
			itens.remove(i)
			return
	pass

func player_scored(player):
	if multiplayer_running:
		if is_network_master():
			rpc("update_score", player)
	else:
		update_score(player)
	pass

remotesync func update_score(player):
	if player >= 0:
		score[player] += 1
	if not Networking._is_running_multiplayer():
		$Label.text = "Your score: " + str(score[0])
		$Label.text += "\nCpu score: " + str(score[1])
	else:
		if Networking._is_server():
			$Label.text = "Your score: " + str(score[0])
			$Label.text += "\nOponent score: " + str(score[1])
		else:
			$Label.text = "Your score: " + str(score[1])
			$Label.text += "\nOponent score: " + str(score[0])
	#Removendo todos os efeitos dos power ups...
	players[0].reset()
	players[1].reset()
	#Removendo os itens que sobraram no cenário.
	for i in range(itens.size()):
		itens[i].queue_free()
	itens.clear()
	pass

func item(effect, playerside):
	if multiplayer_running:
		if is_network_master():
			rpc("item_effect", effect, playerside)
	else:
		item_effect(effect, playerside)
	pass

remotesync func item_effect(effect, playerside):
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
		#Nesse caso não temos ninguém para aplicar o efeito então pedimos apenas para sair do método
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
