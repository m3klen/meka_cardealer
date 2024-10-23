<div align="center">
   <img src="	https://cdn.discordapp.com/attachments/1294682930593005578/1298712719985217606/logo.png?ex=671a8ff9&is=67193e79&hm=f8fb5c9a7d7b123340e138a9eee10ab0779d260ca4f83335830e6048fe843c3d&" width="150px" alt="Project Logo" />
    <h1>MEKA STORE</h1>
</div>

# Meka Cardealer V1.0.0 - ESX ONLY

Meka Cardealer is a free cardealer job script made by the team Meka, this script has support for Sanders MC and the classic cardealer. MLO is not included and to change language you must do so inside the code itself, locales is disabled.

## Features

- **Low Resmon**
- **Easy configuration**

## Installation

1. Download the latest stabel release of our ressource.
2. Import the SQL.
3. Setup the config to your liking.
4. That it!

## Configuration
The most important configuration is displayed here!

```lua
Config = {}

-- Sproget scriptet kører på.
Config.Locale = 'da'

-- Plate config
Config.PlateUseSpace = false
Config.PlateLetters = 2
Config.PlateNumbers = 5

-- Hvor mange procent skal sælgeren have af prisen?
Config.SellerPercentage = 0.03 -- 20%

Config.Computers = {
    [1] = vector3(-32.4081, -1099.3763, 27.3869),
    [2] = vector3(-31.6408, -1097.4822, 27.3869),
    [3] = vector3(-31.1002, -1095.8093, 27.3869)
}

Config.Previews = {
    [1] = {
        MenuLoc = vector3(-38.9581, -1100.2860, 27.7429),
        CarLoc = vector4(-42.1492, -1101.1991, 27.3023, 209.5454)
    },
    [2] = {
        MenuLoc = vector3(-40.2918, -1094.5646, 27.7429),
        CarLoc = vector4(-36.9874, -1093.1456, 27.3023, 155.0089),
    },
    [3] = {
        MenuLoc = vector3(-46.9100, -1095.4263, 27.7429),
        CarLoc = vector4(-47.8659, -1091.8647, 27.3023, 261.8384),
    },
    [4] = {
        MenuLoc = vector3(-52.1142, -1095.1726, 27.7429),
        CarLoc = vector4(-54.9667, -1096.7734, 27.3023, 30.3885),
    },
    [5] = {
        MenuLoc = vector3(-51.1400, -1086.9135, 27.7429),
        CarLoc = vector4(-50.2651, -1083.5985, 27.3023, 239.8100),
    },
}

Config.Sanders = {
    Computer = {
        [1] = vector3(293.3055, -1168.3994, 29.5999),
        [2] = vector3(297.8137, -1168.4938, 29.5999)
    },
    Random = {
        [1] = {
            Model = "akuma",
            Loc = vector3(303.0913, -1159.7031, 29.4701),
            Heading = 273.9576
        },
        [2] = {
            Model = "avarus",
            Loc = vector3(303.0913, -1158.7031, 29.4701),
            Heading = 273.9576
        },
        [3] = {
            Model = "bagger",
            Loc = vector3(303.0913, -1157.7031, 29.4701),
            Heading = 273.9576
        },
        [4] = {
            Model = "bati",
            Loc = vector3(303.0913, -1156.7031, 29.4701),
            Heading = 273.9576
        },
        [5] = {
            Model = "bf400",
            Loc = vector3(303.0913, -1155.7031, 29.4701),
            Heading = 273.9576
        },
        [6] = {
            Model = "carbonrs",
            Loc = vector3(303.0913, -1154.7031, 29.4701),
            Heading = 273.9576
        },
        [7] = {
            Model = "chimera",
            Loc = vector3(303.0913, -1153.7031, 29.4701),
            Heading = 273.9576
        },
        [8] = {
            Model = "cliffhanger",
            Loc = vector3(303.0913, -1152.7031, 29.4701),
            Heading = 273.9576
        },

        [9] = {
            Model = "daemon",
            Loc = vector3(289.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [10] = {
            Model = "defiler",
            Loc = vector3(290.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [11] = {
            Model = "deathbike",
            Loc = vector3(291.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [12] = {
            Model = "diablous",
            Loc = vector3(292.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [13] = {
            Model = "double",
            Loc = vector3(293.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [14] = {
            Model = "enduro",
            Loc = vector3(294.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [15] = {
            Model = "esskey",
            Loc = vector3(295.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [16] = {
            Model = "fcr",
            Loc = vector3(296.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [17] = {
            Model = "gargoyle",
            Loc = vector3(297.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [18] = {
            Model = "hakuchou",
            Loc = vector3(298.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [19] = {
            Model = "hexer",
            Loc = vector3(299.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [20] = {
            Model = "manchez",
            Loc = vector3(300.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
        [21] = {
            Model = "lectro",
            Loc = vector3(301.4071, -1150.6523, 29.4703),
            Heading = 359.4674
        },
    }
}
```
