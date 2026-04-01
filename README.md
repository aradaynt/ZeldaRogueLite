# The Legend of Zolda

A top-down 2D action-adventure roguelike built in Godot 4. Take control of Lonk as he navigates a procedurally generated dungeon, battling smart enemies and getting stronger as you go. Reach the final room and [REDACTED] the [REDACTED] and get the Fiforce.

## Game Features

- Procedural Dungeon Generation: Every run is unique! The game uses a custom "drunkard's walk" algorithm to generate branching room layouts, ensuring that you never encounter the exact same room back-to-back. The algorithm is paired with a "Shuffle Bag" algorithm, this guarantees a perfectly even distribution of rooms types and ensures the player experiences every unique combat room before ever seeing a duplicate.

- Dynamic Combat System: Weapons aren't just cosmetic; they have unique physical properties. Slice through enemies with the Sword, pick them off with the Gun, or use the heavy Mace to deal massive knockback and stagger crowds.

- Smart Enemy AI: Enemies don't just walk in straight lines. They use Godot's NavigationAgent2D and baked NavMeshes to intelligently pathfind around pillars and obstacles to hunt the player down.

- Persistent Runs: A custom singleton system tracks the player's HP, weapon upgrades, and visited map coordinates across scene changes.

- Full Audio Control: Includes a globally routed Master Volume system using Godot's AudioServer and decibel conversion math

- Pause Menu to pause or restart game.

## Controls

- Movement: `W A S D` or arrow keys

- Attack: `Spacebar` or `E`

- Reload: 'R'

- Continue (Main Menu): `Spacebar`

- Main Menu Selection: `W/S`or up/down arrow keys

- Pause: `Esc`

- Resume: `Esc` or click continue in pause menu

- Restart: `R` while in the pause menu

Note: While the Menu actions are controlled via the keyboard, the Main Menu's and Pause menu's volume slider is controlled via the mouse. The Pause Menu can be fully controlled by a mouse.

## Built With

- Game Engine: Godot Engine 4.5

- Language: GDScript

## Core Mechanics
### Procedural Generation & Mapping
- Drunkard's Walk Algorithm: Generates a randomized, branching grid layout for every new run.

- Shuffle Bag (Deck Draw) Room Selection: Guarantees players see every unique combat room in your pool before encountering a duplicate, ensuring maximum variety.

- Dynamic Minimap: A custom UI drawing system that tracks the player's coordinates in real-time, color-coding the Start Room (yellow), the Current Room (green), and Visited Rooms (gray).

### Combat & Player Mechanics

- Physics-Based Top-Down Movement: Uses CharacterBody2D with custom collision margins so Lonk and enemies smoothly slide off walls and corners instead of getting stuck.

- Weapon Swapping & Variety: Multiple equippable weapons with distinct physical properties (e.g., the Sword for slicing, the Gun for ranged attacks, and the Mace for crowd-control and knockback).

- Persistent Run Stats: A global memory system that tracks player Max HP, current HP, equipped weapons, and weapon upgrade levels across scene transitions.

### Progression & Rewards

- Predictive Door System: Doors query the global map grid to determine what room they lead to and display corresponding loot icons (Hearts, Max HP, Weapon Upgrades) above the door frame.

- Boss Room Detection: The system specifically recognizes the final Boss/Treasure room and changes the door icon to a Skull.

- Cleared Room Memory: Doors remember if a room has already been conquered and actively hide their loot icons if the player is backtracking.

### UI & Quality of Life

- Mouse-Driven Menus: While gameplay uses the keyboard, the Main Menu and Pause Menu correctly hand control back to the mouse cursor.

- Immune Pause State: A structured CanvasLayer pause menu that freezes the game world but remains active to listen for player input.

- Global Audio Control: Synchronized Master Volume sliders in both the Main Menu and Pause Menu that use logarithmic decibel conversion to perfectly scale the game's AudioServer.

## How to Run

### In Godot
1. Clone or download this repository.
2. Open Godot, click `Import` and select `project.godot` file inside folder
3. Press F5 or the Play button in the top right to play the game

### OR Just Run the application

#### Windows

- Run the file called `Zelda_1.x.x.exe`

#### Linux
- Run the file called `Zelda_1.x.x.x86_64`

## Assets

Many of my assets were found online for free

### Audio

- Item Pickup: [Here](https://pixabay.com/sound-effects/film-special-effects-power-up-01a-484722/)
- Menu Selection: [Here](https://pixabay.com/sound-effects/film-special-effects-arcade-ui-29-229501/)
- Main Menu Music: [Here](https://pixabay.com/music/upbeat-game-8-bit-399898/)
- Game Over Sound: [Here](https://pixabay.com/sound-effects/film-special-effects-game-over-38511/)
- Boss Hurt Sound: [Here](https://pixabay.com/sound-effects/musical-hurt-c-08-102842/)
- Boss Fight Music: [Here](https://pixabay.com/music/video-games-chiptune-boss-fight-music-265080/)
- Dungeon Background Theme: [Here](https://pixabay.com/music/video-games-exploration-chiptune-rpg-adventure-theme-336428/)
- Victory Song: [Here](https://pixabay.com/sound-effects/film-special-effects-winning-218995/)
- Enemy Damage Sound: [Here](https://pixabay.com/sound-effects/film-special-effects-slime-impact-352473/)
- Gun Shot: [Here](https://pixabay.com/sound-effects/film-special-effects-086409-retro-gun-shot-81545/)
- Mace Slam Sound: [Here](https://pixabay.com/sound-effects/horror-boulder-impact-487673/)
- Sword Swing Sound: [Here](https://pixabay.com/sound-effects/film-special-effects-sword-slash-and-swing-185432/)
- Lonk Hurt Sound: That was recorded by me.

### Images
- Lonk: Drawn by me
    - Lonk Running Animation: Drawn by me
    - Lonk With Different Weapons: Drawn by me

- Danger Exlamation Mark: Drawn by me

- Final Reward: Drawn by me

- Sword, Gun, Mace: Drawn by me
    - Weapon Animations: Drawn by me

- Max HP Upgrade: Drawn by me

- Enemy: Reused asset from previous game (Generated with Gemini)

- Weapon Upgrade: [Here](https://pixabay.com/illustrations/bulky-hammer-hammer-cartoon-9758173/)

- Heal: [Here](https://www.vecteezy.com/png/12658366-heart-shaped-love-icon-symbol-for-pictogram-app-website-logo-or-graphic-design-element-pixel-art-style-illustration-format-png)

- Boss Room Icon: [Here](https://www.pngegg.com/en/png-bshkl)

- Dungeon Tileset: [Here](https://pixel-poem.itch.io/dungeon-assetpuck?download)

- Boss: [Here](https://darkpixel-kronovi.itch.io/undead-executioner?download)
    - Boss Animations: [Here](https://darkpixel-kronovi.itch.io/undead-executioner?download)

- Menu Background: Generated with Gemini

- Door: [Here](https://zeldawiki.wiki/wiki/Locked_Door)

## Play Tested by

- Hovo [DemonMadd]
- Ali [Cenza]
- Hrag [Widow]
- Krikor [PotatoDragon14]
- Kevin [PkmPowers]
