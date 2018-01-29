# FAtiMA-DST
Use [FAtiMA-Toolkit](https://github.com/GAIPS-INESC-ID/FAtiMA-Toolkit) to create agents for [Don't Starve Together](http://store.steampowered.com/app/322330/Dont_Starve_Together/).

This repository aims to provide an integration of FAtiMA-Toolkit with Don't Starve Together (DST), allowing anybody to create agents for DST.

**Notes**:
- Throughout this read me I'll reference game files which are available to whomever owns a copy of the game. I'll always assume as a base directory the **scripts** folder. This folder can be found in *[DST install dir]/data/databundles/scripts.zip* (unzip this file).
- Although not a prerequisite, some knowledge of the game will be helpful.
- DST modding is encouraged and completely accepted by the game developers, however, there is no documentation whatsoever. Luckily, every line of code is available in the game directory. I recommend the use of an editor that supports the *Search in files* functionality. You won't need to make any mod for the game, but you'll eventually need to search the game files to understand the actions and how everything works. Check the Understanding the Actions section.

## Creating an agent

This integration has two components: **FAtiMA-Server** and **FAtiMA-DST**. The former is a C# console application that will run FAtiMA, and the latter is a mod for DST that will control the character. You can think of **FAtiMA-Server** has the brains of the agents and **FAtiMA-DST** has the body.

To create an agent you'll need to follow these general steps.

1. Write a Role Play Character (RPC) using the FAtiMA Authoring Tools (check the FAtiMA-Toolkit page for more information) and place all it's files in the same folder as the **FAtiMA-Server** console application.
2. Get the **FAtiMA-DST** mod from the workshop. (currently the mod is not yet published, copy the FAtiMA-DST folder into the the game's mods folder)
3. Launch **FAtiMA-Server** console application.
4. Launch a game with the **FAtiMA-DST** mod enabled.

## Creating a RPC

FAtiMA-Toolkit provides tools to create agents for any scenarios. For this particular scenario, there are some restrictions you'll need to understand before you can write your agent.

### Beliefs

These represent the information the agent has available when making decisions. They will represent both the state of the agent and the state of the world. These beliefs will be used in the conditions for the actions you'll define.

The values enclosed in square brackets represent variables.

#### Agent's State

These beliefs represent the agent's state, what he is seeing, carrying and using.

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
|`InSight([GUID]) = [bool]`|What the agent (*name*) is currently seeing|
|`InInventory([GUID]) = [bool]`|What the agent (*name*) has in his inventory|
|`IsEquipped([GUID], [slot]) = [bool]`|What the agent (*name*) has equipped in which *slot*|
|`Light([name]) = [value]`|Defines if the agent (*name*) is in the light or darkness. *value* can be 'light' or 'dark'|

#### World's State

These beliefs represent information about the world and should be used in addiction to what the agent is seeing.

|Belief|Description|
|:---|:---|
|`Entity([GUID], [prefab]) = [quantity]`|Defines entities, what they are (*prefab*) and how big is the stack (*quantity*)|
|`ChopWorkable([GUID]) = [bool]`|True if the given entity is workable by an axe|
|`DigWorkable([GUID]) = [bool]`|True if the given entity is workable by a shovel|
|`HammerWorkable([GUID]) = [bool]`|True if the given entity is workable by an hammer|
|`MineWorkable([GUID]) = [bool]`|True if the given entity is workable by a pick|
|`Pickable([GUID]) = [bool]`|True if the given entity is pickable (pick stuff from the ground). *PICKUP* action|
|`Collectable([GUID]) = [bool]`|True if the given entity is pickable (collect natural resources). *PICK* action|
|`Equippable([GUID]) = [bool]`|True if the given entity may be equipped. *EQUIP* action|
|`Fuel([GUID]) = [bool]`|True if the given entity may be used to fuel stuff|
|`Fueled([GUID]) = [bool]`|True if the given entity requires fuel to function|
|`Edible([GUID]) = [type]`|If the item is edible, it represents the food type of the item, else it is false. [type] can be "GENERIC", "MEAT", "WOOD", "VEGGIE", "ELEMENTAL", "GEARS", "HORRIBLE", "INSECT", "SEEDS", "BERRY", "RAW", "ROUGHAGE", "GOODIES"|
|`PosX([GUID]) = [value]`|Defines the X coordinate (*value*) of an entity|
|`PosZ([GUID]) = [value]`|Defines the Z coordinate (*value*) of an entity|
|`World(CurrentSegment) = [value]`|The current segment, ranges between 0 and 15|
|`World(Cycle) = [value]`|Defines how many cycles (days) have passed since the start of the game|
|`World(Phase) = [value]`|Defines the phase of the day. *value* can be: 'day', 'dusk', or 'night'|
|`World(PhaseLenght, [phase]) = [value]`|The current duration of the day *phase* in clock segments. The sum of all segments is always 16|
|`World(IsDay) = [bool]`|True if the phase of the day is 'day'|
|`World(IsDusk) = [bool]`|True if the phase of the day is 'dusk'|
|`World(IsNight) = [bool]`|True if the phase of the day is 'night'|
|`World(Season) = [value]`|Defines the current season. *value* can be: 'spring', 'summer', 'autumn', or 'winter'|
|`World(SeasonProgress) = [value]`|A value between 0 and 1 that defines the progress of the season|
|`World(SpringLength) = [value]`|Defines the current lenght of Spring|
|`World(SummerLength) = [value]`|Defines the current lenght of Summer|
|`World(AutumnLenght) = [value]`|Defines the current lenght of Autumn|
|`World(WinterLenght) = [value]`|Defines the current lenght of Winter|
|`World(IsSpring) = [bool]`|True if the season is Spring|
|`World(IsSummer) = [bool]`|True if the season is Summer|
|`World(IsAutumn) = [bool]`|True if the season is Autumn|
|`World(IsWinter) = [bool]`|True if the season is Winter|
|`World(ElapsedDaysInSeason) = [value]`|How many days ahve passed in the current season|
|`World(RemainingDaysInSeason) = [value]`|How many days are left to the end of the season|
|`World(IsSnowing) = [bool]`|True if it is snowing|
|`World(IsRaining) = [bool]`|True if it is raining|
|`World(MoonPhase) = [value]`|Defines the current moon phase. *value* can be: 'new', 'quarter', 'half', 'threequarter', or 'full'|
|`World(IsFullMoon) = [bool]`|True if there is a full moon|
|`World(IsNewMoon) = [bool]`|True if there is a new moon|

### Events

In addition to the Beliefs, we also provide a way to listen to in-game events and register them in FAtiMA, e.g. whenever something is killed, DST does a 'killed' event which can be listened to and registered as a FAtiMA event by simply enabling it on the mod configurations (by default all event listening is turned off).

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

Even if an action those not requires a specific parameter you must specify it as `-`.

#### Understanding the Actions

Whenever you want to better understand a specific action, you should look for it in the **actions.lua** script and see what it checks and does. Eventually you'll need to dig into the **components** folder and search in those scripts.

The following table presents a list of actions that agents can perform. This list has been slightly curated from the complete list of available actions in DST (these actions were taken from the **actions.lua** script) to exclude actions not available to characters.

For a complete list of actions available in the game check [this](https://gist.github.com/hineios/2160d86d2c3ebd6aa594f4a00d041ca6).

|Actions|Required Params|Restrictions|Description|
|:---:|:---:|:---:|:---|
|ACTIVATE|`{target: GUID}`|target: *activatable*|Interact with some game elements. Useful to investigate *dirtpiles*|
|ADDFUEL|`{target: GUID, invobject: GUID}`|target: *fuel*, invobject: *fueled*|Add fuel to fueled entities (campfire, firesupressor)|
|ATTACK|`{target: GUID}`||Attack other entities.|
|BAIT|`{target: GUID, invobject: GUID}`|target: *trap*|Put bait on traps|
|BUILD|`{recipe:, pos: ,rotation: ,skin: }`||Depending on weather you are crafting an item or placing a structure you'll need to pass a value to the *pos* parameter|
|CASTSPELL|`{target: GUID}`||Use staves. Equiped Hand slot must have the *spellcaster* component|
|CATCH|`{}`||boomerang!|
|CHECKTRAP|`{target: GUID}`|target: *trap*|Harvest trap|
|CHOP|`{target: GUID, invobject: GUID}`|target: *workable*, invobject: can work target |Chop trees|
|COMBINESTACK|`{target: GUID, invobject: GUID}`|target: *stackable*, invobject: same *prefab* as target|Combines invobject into target if it is the same prefab and target is not full|
|COOK|`{target: GUID, invobject: GUID}`|target: *cooker*, invobject: must be ||
|CREATE|`{}`||Needs to be reviewed|
|DEPLOY|`{invobject: GUID, pos: (x, y, z)}`|invobject: *deployable*, pos: valid position|Place ground tile, walls, fences, and gates|
|DIG|`{target: GUID, invobject: GUID}`|target: *workable*, invobject: can work target|Dig grass, twigs, rabbit holes, graves, and others from the ground|
|DROP|`{invobject: GUID, pos: (x, y, z)}`|invobject: must be in inventory, pos: valid position|Drop held item to a spot in the ground|
|DRY|`{target: GUID}`|target: *dryer*, invobject: |Dry meat at racks|
|EAT|`{target: GUID}`|target: *edible*|Eat food|
|EQUIP|`{}`|||
|EXTINGUISH|`{}`||extinguish using object|
|FEED|`{}`|||
|FEEDPLAYER|`{}`|||
|FERTILIZE|`{}`|||
|FILL|`{}`||fill mosquito sack|
|FISH|`{}`|||
|GIVE|`{}`|||
|GIVEALLTOPLAYER|`{}`|||
|GIVETOPLAYER|`{}`|||
|HAMMER|`{target: GUID, invobject: GUID}`|target: *workable*, invobject: can work target|Hammer down built structures|
|HARVEST|`{}`||harvest crops|
|HEAL|`{}`|||
|JUMPIN|`{}`|||
|LIGHT|`{}`|||
|LOOKAT|`{}`|||
|MANUALEXTINGUISH|`{}`||use your hands to try and extinguish fires|
|MINE|`{target: GUID, invobject: GUID}`|target: *workable*, invobject: can work target|Mine rocks, sinkholes, glassiers, and **rock with gold**|
|MOUNT|`{}`|||
|MURDER|`{}`|||
|NET|`{}`||Use nets to catch bugs!|
|PICK|`{}`||pick grass|
|PICKUP|`{}`||pick up backpack|
|PLANT|`{}`|||
|REEL|`{}`|||
|RESETMINE|`{}`|||
|RUMMAGE|`{}`||open container|
|SADDLE|`{}`||saddle rideable|
|SEW|`{}`|||
|SHAVE|`{}`|||
|SLEEPIN|`{}`|||
|SMOTHER|`{}`||put out stuff about to burst into flames |
|STORE|`{}`||store item container|
|TAKEITEM|`{}`||take brid from cage|
|TERRAFORM|`{}`|||
|TURNOFF|`{}`|||
|TURNON|`{}`|||
|UNEQUIP|`{}`|||
|UNPIN|`{}`|||
|UNSADDLE|`{}`|||
|UPGRADE|`{}`|||
|USEITEM|`{}`||hats|
|WALKTO|`{}`|||
