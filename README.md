COMP 4501 Project

Game Controls:
left click to singly select a unit
left click drag to select units
right click once units are selected to have them move to that location or interact with the object
w, a, s, d strafe the camera
scrolling in and out on the mouse wheel will zoom the camera

Requirements
1. 3D rendering based on an isometric view using appropriate illumination and shadows.
	This is done in the setup of how our games lighting and camera interact with the world. A omni directional light sources casts light and shadows that are occluded by objects. The camera code is made in such a way that it keeps an isometric camera angle like other real time strategy games.

2. 3D models for terrain, static and dynamic units and items that the player can collect.
	We used a Terrian3D asset library to craft the game world to give a realistic feel. Our allied and enemy units are also given complex 3d models, Our item resources do not yet however. The models have their own textures to match their size and shape.

3. Collision detection between objects and terrain.
	This is done with a combination of _on_body_enter and other radius detection with collisionShape3D uses to make sure that all objects interact in a natural way with no clipping through each other or terrain.

4. A few instances of each type of unit and collectible are created at game start.
	one of each dragon class and enemy class exists when the game starts. The collectibles that the enemies drop exist once defeated

5. Implementation of player unit actions.
	The player units are controlled with a point and click/select and place system, akin to League of Legends, Club Penguin, or Lobotomy Corporation. Having units selected to move to a given position will move them there over time with a changeable speed value per unit class. When interacting with an enemy the player will currently destroy them in one hit and the enemy will drop a collectible. Reselecting the player unit and right clicking on collectible will have the player unit it move to the collectible and retrieve it back to a base using a pathfinding navigation agent. At current the models do not move dynamically with the direction the units are moving towards.

6. Camera movement.
	As specified in 1, the camera has a fixed view for an isometric feel, the user can move with keyboard hotkeys and scroll with the mouse scroll wheel.
