The Folder PROJ0 Contains a single Quartus project file to be considered our submission
This Project meets the design specifications of the base game, as well as the bonus 
features described by Bonus B3, namely the left facing ship and ship exhaust.

The left facing ship implements both the visual aspect, so if the board is turned to the 
left, the ship will be a left-facing right triangle. Additionally, when the ship is 
facing left, any torpedos fired will travel from right to left on the screen.

The ship exhaust serves as a visual indicator of the ships speed level. Our ship has 4 
total speed levels for both the x and y axis. To look more realistic, the exhaust is 
only determined by motion in the x direction.
 1. No Movement/No Exhaust : This occurs when the board is held flat in the x direction
 2. Lowest Speed (60 pixels/sec)/ Smallest exhaust
 3. Medium Speed (180 pixels/sec) / Medium exhaust
 4. High Speed (300 pixels/sec) / Large exhaust
 
Game Setup is as follows:
1. Connect a Piezo Speaker to Arduino12 and GND
2. Connect a VGA Cable to the DE10 Lite and a VGA Capable Monitor
3. Connect the DE10 Lite Board using the USB Blaster and Program it using the Quartus Project
4. Press PB0 to Start the Game
 
The game controls are as follows:
-Movement: Controlled by tilting the board in the desired direction (both x and y)
-Game Start: Pressing PB0 when the start screen (no enemies) is displayed
-Pause/Unpause: Pressing PB1
-Firing Torpedos: Pressing PB0 during gameplay (The fire rate of torpedos is limited by design)

Gameplay is as follows:
Like the original Defender game, gameplay consists of flying the ship to avoid enemies and firing 
torpedos at enemies to score points. The player's score is displayed in the top righ corner of the
screen. The player starts with the Maximum number of lives (3), which are displayed in the top left 
corner. Colliding with an enemy causes a life to be lost. At this point, the player will be made
invincible for a short time. During the invincibility period, the ship will blink. Lives can be 
gained by successfully destroying the smallest enemy. 

Points are gained by destroying enemies with torpedos. Scoring for each enemy is listed below. For 
each 5000 points gained, the game difficulty increases (the player is alerted by the game's audio) 
until 25000 points is reached, resulting in the hardest difficulty. For 5000, 10000, and 15000 points,
the enemy speed and spawn rate increases. For 20000 and 25000 only the speed increases.

When the final life is lost, the game screen will freeze allowing the player to see their score. At 
this point, pressing PB0 will start a new game. This resets the score, enemies, and torpedos and 
places the player in the start position. 