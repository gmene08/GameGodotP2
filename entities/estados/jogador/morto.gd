extends Estado
## Sem vida: para de obedecer, cai de lado e some aos poucos. No fim emite o
## sinal `morreu` do Jogador, para o HUD mostrar o fim de jogo. Não tem saída:
## para jogar de novo a fase é recarregada.

## Segundos entre cair e sumir de vez.
@export var duracao := 1.2

@onready var jogador := owner as Jogador


func entrar() -> void:
	# Fora de todas as camadas: nada mais detecta o minerador (nem os cristais).
	jogador.collision_layer = 0
	jogador.tocar_animacao("parado")
	jogador.sprite.stop()
	jogador.sprite.self_modulate = Color(1.0, 0.45, 0.45)
	var tween := jogador.create_tween()
	tween.tween_property(jogador.sprite, "rotation", PI / 2.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_interval(duracao * 0.4)
	tween.tween_property(jogador.sprite, "modulate:a", 0.0, duracao * 0.6)
	tween.finished.connect(jogador.morreu.emit)


func atualizar_fisica(delta: float) -> void:
	# Termina de frear o empurrão do golpe que matou.
	jogador.mover(Vector2.ZERO, delta)
