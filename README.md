# FAtiMA-DST
Use [FAtiMA-Toolkit](https://github.com/GAIPS-INESC-ID/FAtiMA-Toolkit) to create agents for [Don't Starve Together](http://store.steampowered.com/app/322330/Dont_Starve_Together/).
This repository contains the source code for the Steam's Workshop mod [FAtiMA-DST](http://steamcommunity.com/sharedfiles/filedetails/?id=1339264854).
This repository aims to provide an integration of FAtiMA-Toolkit with Don't Starve Together (DST), allowing anybody to create agents for DST.

**Notes**:
- Throughout this read me I'll reference game files which are available to whomever owns a copy of the game. I'll always assume as a base directory the **scripts** folder. This folder can be found in *[DST install dir]/data/databundles/scripts.zip* (unzip this file).
- Although not a prerequisite, some knowledge of the game will be helpful.
- DST modding is encouraged and completely accepted by the game developers, however, there is no documentation whatsoever. Luckily, every line of code is available in the game directory. I recommend the use of an editor that supports the *Search in files* functionality. You won't need to make any mod for the game, but you'll eventually need to search the game files to understand the actions and how everything works. Check the Understanding the Actions section.

## Running the mod

This integration has two components: **FAtiMA-Server** and **FAtiMA-DST**. The former is a C# console application that will run FAtiMA, and the latter is a mod for DST that will control the character. You can think of **FAtiMA-Server** has the brains of the agents and **FAtiMA-DST** has the body.

To launch an agent you'll need to follow these general steps.

1. Subscribe to the **FAtiMA-DST** mod from the [workshop](http://steamcommunity.com/sharedfiles/filedetails/?id=1339264854).
2. Download and launch **FAtiMA-Server** [console application](https://github.com/hineios/FAtiMA-DST/releases).
3. Launch a game with the **FAtiMA-DST** mod enabled.

## Creating an Agent

FAtiMA-Toolkit provides tools to create agents for any scenario. For this particular scenario, there are some restrictions you'll need to understand and that I will introduce bellow.

Currently, if you want to create an Agent for Don't Starve Together, you have to write a Role Play Character (RPC) using the FAtiMA Authoring Tools (check the FAtiMA-Toolkit page for more information) and place all it's files (.rpc, .edm, etc...) in the folder **Example Character**, under **FAtiMA-Server** console application.
Ensure that the *.rpc* file is named **walter.rpc**, this is **crucial!** (and a limitation, future versions will provide ways to specify the RPC you want to use).
I encourage you to check out the example character available in this repository.
For now, if you want to run your own character you'll have to ovewrite the existing one under the *Example Character* folder (just rename the existing files and create your ones with the original name).

### Beliefs

These represent the information the agent has available when making decisions. They will represent both the state of the agent and the state of the world. These beliefs will be used in the conditions for the actions you'll define.

The values enclosed in square brackets represent variables.

#### Agent's State

These beliefs represent the agent's state, what he is seeing, carrying and has equipped.

|Belief|Description|
|:---|:---|
|`Health([name]) = [value]`|Describes the agent's (*name*) health|
|`Hunger([name]) = [value]`|Describes the agent's (*name*) hunger|
|`Sanity([name]) = [value]`|Describes the agent's (*name*) sanity|
|`Moisture([name]) = [value]`|Describes the agent's (*name*) moisture level|
|`Temperature([name]) = [value]`|Describes the agent's (*name*) temperature|
|`IsFreezing([name]) = [bool]`|Describes if the agent (*name*) is taking damage from extreme cold|
|`IsOverheating([name]) = [bool]`|Describes if the agent (*name*) is taking damage from extreme hot|
|`IsBusy([name]) = [bool]`|Describes if the agent (*name*) is currently executing any action|
|`PosX([name]) = [value]`|The agent's (*name*) current X position|
|`PosZ([name]) = [value]`|The agent's (*name*) current Y position|
|`InLight([name]) = [bool]`|Defines if the agent (*name*) is in the light or darkness|
|`InSight([GUID]) = [bool]`|What the agent (*name*) is currently seeing|
|`InInventory([GUID]) = [bool]`|What the agent (*name*) has in his inventory|
|`IsEquipped([GUID]) = [bool]`|What the agent (*name*) has equipped|

#### World's State

These beliefs represent information about the world and should be used in addiction to what the agent is seeing.

|Belief|Description|
|:---|:---|
|`Entity([GUID]) = [prefab]`|Defines an entity what they are (*prefab*)|
|`Quantity([GUID]) = [quantity]`|Defines how big is the stack (*quantity*) of a given entity|
|`IsCollectable([GUID]) = [bool]`|True if the given entity is pickable (collect natural resources). *PICK* action|
|`IsCooker([GUID]) = [bool]`|True if the given entity can cook other entities. *COOK* action|
|`IsCookable([GUID]) = [bool]`|True if the given entity can be cooked. *COOK* action|
|`IsEdible([GUID]) = [true]`|True if the entity may be eaten by the curent character (it takes into account the character's diet). *EAT* action|
|`IsEquippable([GUID]) = [bool]`|True if the given entity may be equipped. *EQUIP* action|
|`IsFuel([GUID]) = [bool]`|True if the given entity may be used to fuel stuff. *FUEL* action|
|`IsFueled([GUID]) = [bool]`|True if the given entity requires fuel to function. *FUEL* action|
|`IsGrower([GUID]) = [bool]`|True if the given entity can be used to grow seeds. *PLANT* action|
|`IsHarvestable([GUID]) = [bool]`|True if the given entity is ready to be harvested. *HARVEST* action|
|`IsPickable([GUID]) = [bool]`|True if the given entity is pickable (pick stuff from the ground). *PICKUP* action|
|`IsStewer([GUID])= [bool]`|True if the given entity can take other entities to cook recipes|
|`IsChoppable([GUID]) = [bool]`|True if the given entity is workable by an axe. *CHOP* action|
|`IsDiggable([GUID]) = [bool]`|True if the given entity is workable by a shovel. *DIG* action|
|`IsHammerable([GUID]) = [bool]`|True if the given entity is workable by an hammer. *HAMMER* action|
|`IsMineable([GUID]) = [bool]`|True if the given entity is workable by a pick. *MINE* action|
|`PosX([GUID]) = [value]`|Defines the X coordinate (*value*) of an entity|
|`PosZ([GUID]) = [value]`|Defines the Z coordinate (*value*) of an entity|
|`World(CurrentSegment) = [value]`|The current segment, ranges between 0 and 15|
|`World(Cycle) = [value]`|Defines how many cycles (days) have passed since the start of the game|
|`World(Phase) = [value]`|Defines the phase of the day. *value* can be: 'day', 'dusk', or 'night'|
|`World(PhaseLenght, [phase]) = [value]`|The current duration of the day *phase* in clock segments. The sum of all segments is always 16|
|`World(Season) = [value]`|Defines the current season. *value* can be: 'spring', 'summer', 'autumn', or 'winter'|
|`World(SeasonProgress) = [value]`|A value between 0 and 1 that defines the progress of the season|
|`World(ElapsedDaysInSeason) = [value]`|How many days have passed in the current season|
|`World(RemainingDaysInSeason) = [value]`|How many days are left to the end of the season|
|`World(SpringLength) = [value]`|Defines the current lenght of Spring|
|`World(SummerLength) = [value]`|Defines the current lenght of Summer|
|`World(AutumnLenght) = [value]`|Defines the current lenght of Autumn|
|`World(WinterLenght) = [value]`|Defines the current lenght of Winter|
|`World(IsSnowing) = [bool]`|True if it is snowing|
|`World(IsRaining) = [bool]`|True if it is raining|
|`World(MoonPhase) = [value]`|Defines the current moon phase. *value* can be: 'new', 'quarter', 'half', 'threequarter', or 'full'|

### Events

In addition to the Beliefs, there are also in-game events that the agent listens to, e.g. whenever something is killed, DST does a 'killed' event which is registered as a FAtiMA event.
These are the currently supported events.

|Event|Description|
|:----:|:---|
|`Event(Action-End, [subject], Attacked, [target])`|Represents an attack made on the *target* by the *subject*|
|`Event(Action-End, [subject], Killed, [target])`|Represents the killing of the *target* by the hand of the *subject*|
|`Event(Action-End, [subject], Death, [target])`|Represents the death of the *subject* by the hand of the *target*|
|`Event(Action-End, [subject], HitOther, [target])`|Represents attacks the *subject* made against the *target*|
|`Event(Action-End, [subject], MissOther, [target])`|Represents attacks the *subject* missed against the *target*|


### Actions

**It's imperative that all actions have the following structure**

`Action([action], [invobject], [posx], [posz], [recipe]) = [target]`

Even if an action does not requires a specific parameter you must specify it as `-`.

#### Understanding the Actions

Whenever you want to better understand a specific action, you should look for it in the **actions.lua** script and see what it checks and does. Eventually you'll need to dig into the **components** folder and search in those scripts.

The following table presents a list of actions that agents can perform. This list has been slightly curated from the complete list of available actions in DST (these actions were taken from the **actions.lua** script) to exclude actions not available to characters.
For a complete list of actions available in the game check [this](https://gist.github.com/hineios/2160d86d2c3ebd6aa594f4a00d041ca6).

|Actions|Restrictions|Description|
|:---:|:---:|:---|
|`Action(ACTIVATE, -, -, -, -) = [target]`|`{target: GUID}`|Interact with some game elements|
|`Action(ADDFUEL, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Add fuel to fueled entities (campfire, firesupressor)|
|`Action(ATTACK, -, -, -, -) = [target]`|`{target: GUID}`|Attack other entities|
|`Action(BAIT, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Put bait on traps|
|`Action(BUILD, -, [x], [z], [recipe]) = `|`{([x], [z]): position, recipe: recipe's name}`|Depending on weather you are crafting an item or placing a structure you'll need to pass a value to the *(x, z)* parameters|
|`Action(CASTSPELL, [invobject], -, -, -) = [target]`|`{invobject:GUID, target: GUID}`|Cast magic item at *target*. If *invobject* is not specified, the equipped item is used.|
|`Action(CHECKTRAP, -, -, -, -) = [target]`|`{target: GUID}`|Check if the given trap has caught anything|
|`Action(CHOP, -, -, -, -) = [target]`|`{target: GUID}`|Chop trees, an axe must be equipped in order to use|
|`Action(COMBINESTACK, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Combines the given *invobject* into *target* if it is the same prefab and target is not full|
|`Action(COOK, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Cook *invobject* at the specified *target*|
|`Action(DEPLOY, [invobject], [x], [z], -) = -`|`{invobject: GUID, ([x], [z]): position}`|Place ground tile, walls, fences, and gates|
|`Action(DIG, -, -, -, -) = [target]`|`{target: GUID}`|Dig grass, twigs, rabbit holes, graves, and others from the ground|
|`Action(DROP, [invobject], [x], [Z], -) = -`|`{invobject: GUID, ([x], [z]): position}`|Drop held item to a spot in the ground|
|`Action(DRY, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Dry meat at racks|
|`Action(EAT, -, -, -, -) = [target]`|`{target: GUID}`|Eat food|
|`Action(EQUIP, [invobject], -, -, -) = -`|`{invobject: GUID}`|Equip an item that is in the character's inventory|
|`Action(EXTINGUISH, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Use the *invobject* to extinguish the burning *target*|
|`Action(FEED, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Feed the *invobject* to the *target*|
|`Action(FEEDPLAYER, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Feed the player (*target*) with *invobject* (might work the same has the above)|
|`Action(FERTILIZE, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Use *invobject* to Fertilize the *target*|
|`Action(FILL, [invobject], -, -, -) = [target]`|`{invobject: GUID}, target:GUID`|Fill the mosquito sack (*invobject*) at a pond (*target*)|
|`Action(FISH, -, -, -, -) = [target]`|`{target: GUID}`|Use a fishing rod (must be equipped) to fish in a pond (*target*)|
|`Action(GIVE, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Give *invobject* to *target*|
|`Action(GIVEALLTOPLAYER, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Give all of *invobject* to player (*target*)|
|`Action(GIVETOPLAYER, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Give *invobject* to player (*target*) (Not sure on the difference of these three actions)|
|`Action(HAMMER, -, -, -, -) = [target]`|`{target: GUID}`|Hammer down built structures (*target*)|
|`Action(HARVEST, -, -, -, -) = [target]`|`{target: GUID}`|Harvest crops and cookpots|
|`Action(HEAL, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Use *invobject* to heal the *target*|
|`Action(JUMPIN, -, -, -, -) = [target]`|`{target: GUID}`|Jump into wormhole (*target*)|
|`Action(LIGHT, -, -, -, -) = [target]`|`{target: GUID}`|Set the *target* on fire (must have a torch equipped)|
|`Action(LOOKAT, -, -, -, -) = [target]`|`{target: GUID}`|Face the *target*|
|`Action(MANUALEXTINGUISH, -, -, -, -) = [target]`|`{target: GUID}`|Use your hands to try and extinguish fires|
|`Action(MINE, -, -, -, -) = [target]`|`{target: GUID}`|Mine rocks, sinkholes, glassiers, etc (must have a pickaxe equipped)|
|`Action(MOUNT, -, -, -, -) = [target]`|`{target: GUID}`|Mount a saddled mount (*target*)|
|`Action(MURDER, -, -, -, -) = [target]`|`{target: GUID}`|Murder targeted inocent creature (e.g. rabbits) while in inventory|
|`Action(NET, -, -, -, -) = [target]`|`{target: GUID}`|Use nets to catch bugs (*target*)|
|`Action(PICK, -, -, -, -) = [target]`|`{target: GUID}`|Pick the targeted resource (e.g. grass, saplings, berry bushes, etc)|
|`Action(PICKUP, -, -, -, -) = [target]`|`{target: GUID}`|Pick up items from the ground (e.g. rocks, twigs, cutgrass, etc.)|
|`Action(PLANT, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Plant *invobject* (seeds) into *target*|
|`Action(REEL, -, -, -, -) = [target]`|`{target: GUID}`|Reel in the fish while fishing (the target is the pond)|
|`Action(RESETMINE, -, -, -, -) = [target]`|`{target: GUID}`|Reset mines like the tooth trap|
|`Action(RUMMAGE, -, -, -, -) = [target]`|`{target: GUID}`|Rummage about in a container|
|`Action(SADDLE, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`| Use *invobject* to saddle up the *target*|
|`Action(SEW, [invobject], -, -, -) = [target]`|`{invobject: GUID}, target: GUID`|Use *invobject* to sew the *target*|
|`Action(SHAVE, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Use the *invobject* to shave the *target*|
|`Action(SLEEPIN, -, -, -, -) = [target]`|`{target: GUID}`|Sleep in the *target* (tent or sleeping bag)|
|`Action(SMOTHER, -, -, -, -) = [target]`|`{target: GUID}`|Smother the smoking *target* (stuff about to burst into flames)|
|`Action(STORE, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Store the *invobject* into the *target*|
|`Action(TAKEITEM, [], -, -, -) = [target]`|`{}`||take brid from cage|
|`Action(TERRAFORM, [invobject], [x], [z], -) = -`|`{invobject: GUID, ([x], [z]): position}`|Use the *invobject* to terraform the *position*|
|`Action(TURNOFF, -, -, -, -) = [target]`|`{target: GUID}`|Turn the *target* off (e.g. firesupressor)|
|`Action(TURNON, -, -, -, -) = [target]`|`{target: GUID}`|Turn the *target* on|
|`Action(UNEQUIP, -, -, -, -) = [target]`|`{target: GUID}`|Unequip *target*|
|`Action(UNSADDLE, -, -, -, -) = [target]`|`{target: GUID}`|Remove the saddle from the *target*|
|`Action(UPGRADE, [invobject], -, -, -) = [target]`|`{invobject: GUID, target: GUID}`|Use *invobject to upgrade the *target* (e.g. upgrade a wall)|
|`Action(WANDER, -, -, -, -) = -`|`{}`|This is a the behaviour of wandering about the world, not really an action|
|`Action(WALKTO, -, -, -, -) = [target]`|`{target: GUID}`|Walk up to the *target*|

## Limitations and Considerations

The current beliefs used to represent the agent's state and the world are the necessary to develop simple behaviour and have some limitations.
The interaction with containers (fridges and chests), for example, isn't the easiest to achieve using the current set of beliefs.
However, the addition of new beliefs should be simple to achieve, should you read the current source code.

Nonetheless, this work represents a starting point for enpowering characters with autonomous behaviour in the world of Don't Starve Together using state of the art artificial intelligence technologies such as the FAtiMA Toolkit.
Ideally, such a system would be a part of the game itself, but due to limitiations on importing of external ddl's into the game, I've chosen to take this approach of using HTTP communication (which is less than ideal).

Taking this into account, be free to develop you own agents using this project and, if you wish to, fork this project to do whatever you want.
I also encourage you to look at the [work](https://github.com/KingofTown/DS-AI) from KingOfTown, which uses the built in Behaviour Trees to give autonomous behaviour to the game's characters.
