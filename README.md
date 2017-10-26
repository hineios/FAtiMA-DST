# FAtiMA-DST
Use [FAtiMA-Toolkit](https://github.com/GAIPS-INESC-ID/FAtiMA-Toolkit) to create agents for [Don't Starve Together](http://store.steampowered.com/app/322330/Dont_Starve_Together/).

This repository aims to provide an integration of FAtiMA-Toolkit with Don't Starve Together (DST), allowing anybody to create agents for DST.

**Notes**:
- Throughout this read me I'll reference game files which are available to whomever owns a copy of the game. I'll always assume as a base directory the **scripts** folder. This folder can be found in *[DST install dir]/data/scripts*.
- Although not a prerequisite, some knowledge of the game will be helpful.
- DST modding is encouraged and completely accepted by the game developers, however, there is no documentation whatsoever. Luckily, every line of code is available in the game directory. I recommend the use of an editor that supports the *Search in files* functionality. You won't need to make any mod for the game, but you'll eventually need to search the game files to understand the actions and how everything works. Check the Understanding the Actions section.

### Creating an agent

This integration has two components: **FAtiMA-Server** and **FAtiMA-DST**. The first is a C# console application that will run FAtiMA, and the latter is a mod for DST that will control the character. You can think of **FAtiMA-Server** has the brains of the agents and **FAtiMA-DST** has the body.

1. Write a Role Play Character file using the FAtiMA Authoring Tools.
2. Get the **FAtiMA-DST** mod from the workshop.
3. Launch **FAtiMA-Server** console application.
4. Launch a game with the **FAtiMA-DST** mod enabled.

### Actions

The following table presents a list of actions that agents can perform. This list has been curated from the complete list of available actions in DST (these actions were taken from the **actions.lua** script).

For a complete list of actions available in the game check [this](https://gist.github.com/hineios/2160d86d2c3ebd6aa594f4a00d041ca6).

|Actions			|Description			|
|:-----------------:|:----------------------|
|ACTIVATE			|						|
|ADDFUEL			|						|
|ATTACK				|						|
|BAIT				|						|
|BUILD				|						|
|CASTSPELL			|use staves				|
|CATCH				|						|
|CHECKTRAP			|						|
|CHOP				|						|
|COMBINESTACK		|						|
|COOK				|						|
|CREATE				|						|
|DEPLOY				|						|
|DIG				|						|
|DROP				|						|
|DRY				|						|
|EAT				|						|
|EQUIP				|						|
|EXTINGUISH			|extinguish using object|
|FEED				|						|
|FEEDPLAYER			|						|
|FERTILIZE			|						|
|FILL				|fill mosquito sack		|
|FISH				|						|
|GIVE				|						|
|GIVEALLTOPLAYER	|						|
|GIVETOPLAYER		|						|
|HAMMER				|						|
|HARVEST			|harvest crops			|
|HEAL				|						|
|JUMPIN				|						|
|LIGHT				|						|
|LOOKAT				|						|
|MANUALEXTINGUISH	|						|
|MINE				|						|
|MOUNT				|						|
|MURDER				|						|
|NET				|						|
|PICK				|pick grass				|
|PICKUP				|pick up backpack		|
|PLANT				|						|
|PLAY				|						|
|REEL				|						|
|RESETMINE			|						|
|RUMMAGE			|open container			|
|SADDLE				|saddle rideable		|
|SEW				|						|
|SHAVE				|						|
|SLEEPIN			|						|
|SMOTHER			|						|
|STORE				|						|
|TAKEITEM			|take brid from cage	|
|TERRAFORM			|						|
|TURNOFF			|						|
|TURNON				|						|
|UNEQUIP			|						|
|UNPIN				|						|
|UNSADDLE			|						|
|UPGRADE			|						|
|USEITEM			|hats					|
|WALKTO				|						|

###Understanding the Actions
