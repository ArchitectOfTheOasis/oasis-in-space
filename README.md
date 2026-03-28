# Stardew Valley inspired Game Architecture Study

**Engine:** Godot v4.5

**Language:** GDScript

**Status:** In Development

**Tools:** Notion, ChatGPT, Claude, Gemini, Godot Docs, YouTube, Excalidraw, Procreate, Aseprite

![screenshot](https://github.com/ArchitectOfTheOasis/oasis-in-space/blob/17b2b74eecaeee730b949714321f3f362e0d17b7/oasis-screenshot.jpg)


## ABOUT THE PROJECT

This "game" is a current snapshot of my progress of the last ~6 month learning GameDev from
scratch, without programming background.

It will become a top-down farming simulator set in space, inspired by Stardew Valley. 
A spiritual experience where the player manages resources, 
explores the abandoned planet and interacts with aliens and robots. 
Instead of "days" the time is measured in 'loops'. Each loop will create a new 
save file.

The current build demonstrates the core architecture systems as the game foundation.
Gameplay features are actively being implemented in the next steps.

I created this game as the beginning of a long term Project, so I focused 
on flexible decoupled systems to keep it maintainable. My goal was to really
understand programming and get flexible and independent in the usage.
AI Tools were used consciously either for code reviews or to reflect myself 
during the process.




## TECHNICAL HIGHLIGHTS

### Save System

	• Observer-pattern based save data registry - decouples objects from 'SaveManager'
	  allowing any object to register without direct dependency.
	• Automatic save slot rotation - Three save slots, new saves delete the oldest.
	• Unified PROCESSING_MODE enum - Save and Load share the same initiation pipeline,
	  reducing redundant code

### Inventory 

	• Dynamic slot registry - InventoryUI detects and registers slots at runtime
	  allowing inventory size changes without code modifications.
	• Snapshot based inventory UI updates to avoid rebuilding whole inventory 
	• Backwards iteration at item removal for good game feel.

### Finite State Machine for player behaviour
	
	• ID-based automatic state registration - new states self-register on _ready()
	• Clean state separation - each state owns its own enter/exit/process logic, 
	  the FSM only coordinates transitions.


### Scene Transition System 

	• ID-based spawnpoint registry via EventBus. Decouples scene objects from the 
	  SceneManager.
	• Gate pattern - scene transition only completes when all relevant objects are
	  initialized avoiding race conditions.
	• Inheritance-based trigger and ID system. 'SceneTransitionTrigger' as base class,
	  providing logic throughout multiple scripts.


### Player Animation Manager

	• Automated name mapping - animation names are generated dynamically based on
      direction and state using global enums, avoiding hardcoded string names.
	• SSOT - one system handles all the player animation logic, the player only emits 
      state changes.




## ROADMAP 

### Input Manager

	• Centralized Input manager, to consider UI layers and avoid spread input detection.
	
### World Interaction

	• Displaying the selected tile based on the mouse position
	• Plant growing/harvesting system to make use of the inventory.
		Rudimental Day/Night cycle without Shaders.
	• Mining - Dropped items get now a use case
	• Tree Chopping - Dropped items get now a use case
	
### NPC Interaction

	• Dialogue System
	
### Audio System

	• Centralized audio system - maybe with a centralized audio file database 




## DISCLAIMER

• Earlier systems remain as-is due to prioritizing feature progress 
  over refactoring. 
• Refactor ideas and architectural debt are Documented in
  the Header section.
• Documentation may not be complete.




## WHAT I LEARNED

• Documentation is essential for a maintainable long term project
• Make it work first, then make it clean (Shipping >= Perfection)
• Early exit pattern
• Bool return pattern
• Function Typing (void, bool, etc.)
• Advanced Error handling with 'assert' & 'push_error'
• Data driven design
• File I/O




## SETUP

### Inside the project

1. Download Godot v4.5+ from godotengine.org
2. Clone or download this repository
3. Import project.godot in Godot
4. Run the project (Play button (▶︎) in the top right corner)

### Play the demo

1. Open the .exe or .app @If export available

Tested on: macOS




## DEMO LIMITATIONS

• For demo reasons currently only allows to add/remove the same item until I 
  implement real use world drops. (Key: I = Add item, O = Remove item)
• A different item can be spawned with (Key: Q)
• Due to the Scene Transition System the inventory gets deleted by scene switch.




## CONTROLS

WASD | Movement
Shift | Sneak
Right Mouse | Open Door
Left Mouse | Button Interaction

Enter | Next Loop (Day)
Z | Zoom in
+ | Zoom in
- | Zoom out

E | Toggle inventory
I | Add Item to inventory
O | Remove Item from inventory
Q | Spawn Item
F3 | Debug Menu



## LICENSE

All assets including sprites and artwork are original and not 
licensed for reuse. Code may be used for educational purposes only.
