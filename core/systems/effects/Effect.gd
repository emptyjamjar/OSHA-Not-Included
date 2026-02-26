extends Node
class_name Effect

# Signals
signal started() # this effect has started
signal ended() # this effect has ended

# Attributes
enum Type
{
	NONE, # placeholder type or can mean no effect
	STRUCTURAL, # Affects buildings, walls, doors, or physical structures (like the level itself)
	OBJECT, # Affects items, props, or movable objects
	ATMOSPHERE, # changes weather, fog, lighting, or ambient mood
	BIOLOGICAL, # Affects living things (health, stamina, sanity, etc.)
	AUDIO, # Plays sounds, music, or voice lines
	VISUAL, # Changes colors, overlays, screen effects, or particle systems
	SIGNAGE, # Shows text, signs, or UI messages
	TEMPORAL, # Alters time (slow-mo, fast-forward, time stop), or time based stuff
	BUFF, # Positive effect (e.g., +speed, +health)
	DEBUFF, # Negative effect (e.g., -vision, -stamina)
	ENVIRONMENTAL, # Affects the world (gravity, wind, temperature, etc.)
	HAZARD # Dangerous effect (fire, poison, radiation, etc.)
}
