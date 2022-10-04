extends Area

var active : bool = true
export(String) var effect : String
var HUD : Object

func _ready():
	HUD = get_parent().get_node("HUD")
	pass

func _on_Energy_body_entered(body):
	#Os itens não são deletados instântaneamente por conta de sua animação
	#Para evitar a repedição da animação de objeto pego, ou até duplicar o efeito, a variável "active" controla
	#a execução uma única vez
	if body.is_in_group("ball") and active:
		HUD.item(effect, body.side)
		HUD.remove_item(self)
		$AnimationPlayer.play("get")
		active = false
	$AudioStreamPlayer3D.play()
	pass
