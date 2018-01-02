-- This information tells other players more about the mod
name = "FAtiMA-DST"
description = "Build your agents using FAtiMA and play with them in the Don't Starve Together World."
author = "Fábio Almeida (hineios)"
version = "0.2"
--version_compatible = "1.7"

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

---- Can specify a custom icon for this mod!
--icon_atlas = "modicon.xml"
--icon = "modicon.tex"

--This lets the clients know that they need to download the mod before they can join a server that is using it.
all_clients_require_mod = true

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
server_filter_tags = {"ai"}



 configuration_options =
 {
     {
         name = "Killed",
         label = "'killed'",
         options = 
         {
             {description = "False", data = false},
			 {description = "True", data = true}
             
         },
         default = false,
     },
	 {
         name = "Death",
         label = "'death'",
         options = 
         {
             {description = "False", data = false},
			 {description = "True", data = true}
             
         },
         default = false,
     },
	 {
         name = "Attacked",
         label = "'attacked'",
         options = 
         {
             {description = "False", data = false},
			 {description = "True", data = true}
             
         },
         default = false,
     },
	 {
         name = "MissOther",
         label = "'onmissother'",
         options = 
         {
             {description = "False", data = false},
			 {description = "True", data = true}
             
         },
         default = false,
     },
	 {
         name = "HitOther",
         label = "'onhitother'",
         options = 
         {
             {description = "False", data = false},
			 {description = "True", data = true}
             
         },
         default = false,
     }
}