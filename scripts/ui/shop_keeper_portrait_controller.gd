extends PanelContainer
class_name ShopKeeperPortraitController

@onready var name_label: Label = $MarginContainer/HBox/KeeperArea/NameLabel
@onready var portrait: AnimatedSprite2D = $MarginContainer/HBox/KeeperArea/PortraitContainer/Portrait
@onready var emotion_indicator: Label = $MarginContainer/HBox/KeeperArea/PortraitContainer/EmotionIndicator
@onready var dialogue_label: RichTextLabel = $MarginContainer/HBox/SpeechArea/SpeechBubble/SpeechMargin/DialogueLabel
@onready var mood_label: Label = $MarginContainer/HBox/SpeechArea/MoodContainer/MoodLabel
@onready var animation_timer: Timer = $AnimationTimer

var shop_keeper_data: ShopKeeperData
var current_emotion: String = ""
var idle_animations: Array[String] = ["idle", "blink", "gesture"]

func _ready():
	shop_keeper_data = ShopKeeperData.new()
	_setup_keeper()
	_show_greeting()

func _setup_keeper():
	name_label.text = shop_keeper_data.name
	mood_label.text = "Mood: " + shop_keeper_data.get_mood_modifier().capitalize()
	emotion_indicator.visible = false

	# Setup basic portrait (placeholder since we don't have sprites yet)
	portrait.visible = false  # Hide until we have actual sprites

func _show_greeting():
	var greeting_text = shop_keeper_data.get_dialogue("greeting")
	_display_dialogue(greeting_text)
	_show_emotion("!")

func show_dialogue(context: String):
	var dialogue_text = shop_keeper_data.get_dialogue(context)
	_display_dialogue(dialogue_text)

	match context:
		"purchase_success":
			_show_emotion("♪")
			shop_keeper_data.set_mood("happy")
		"insufficient_funds":
			_show_emotion("?")
			shop_keeper_data.set_mood("neutral")
		"special_deal":
			_show_emotion("!")
			shop_keeper_data.set_mood("happy")
		"browse":
			_show_emotion("")
		"farewell":
			_show_emotion("~")

func _display_dialogue(text: String):
	var mood_style = ""
	match shop_keeper_data.mood:
		"happy":
			mood_style = "[color=green]"
		"annoyed":
			mood_style = "[color=red]"
		_:
			mood_style = "[color=white]"

	dialogue_label.text = "[center]" + mood_style + text + "[/color][/center]"
	mood_label.text = "Mood: " + shop_keeper_data.get_mood_modifier().capitalize()

func _show_emotion(emotion: String):
	current_emotion = emotion
	if emotion.is_empty():
		emotion_indicator.visible = false
	else:
		emotion_indicator.text = emotion
		emotion_indicator.visible = true

		# Create a simple bounce effect
		var tween = create_tween()
		tween.set_loops(2)
		emotion_indicator.scale = Vector2.ONE
		tween.tween_property(emotion_indicator, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(emotion_indicator, "scale", Vector2.ONE, 0.2)

func _on_animation_timer_timeout():
	# Cycle through idle animations
	if portrait.visible and not idle_animations.is_empty():
		var anim = idle_animations[randi() % idle_animations.size()]
		# This would play the animation if we had sprite frames set up
		# portrait.play(anim)

	# Occasionally show random browse dialogue
	if randf() < 0.3:  # 30% chance
		show_dialogue("browse")

func set_keeper_mood(mood: String):
	shop_keeper_data.set_mood(mood)
	mood_label.text = "Mood: " + shop_keeper_data.get_mood_modifier().capitalize()

func simulate_purchase_success():
	show_dialogue("purchase_success")

func simulate_insufficient_funds():
	show_dialogue("insufficient_funds")

func simulate_special_deal():
	show_dialogue("special_deal")

func show_farewell():
	show_dialogue("farewell")