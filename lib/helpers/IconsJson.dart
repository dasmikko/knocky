// To parse this JSON data, do
//
//     final icons = iconsFromJson(jsonString);

import 'dart:convert';

List<Icon> iconsFromJson(String str) =>
    List<Icon>.from(json.decode(str).map((x) => Icon.fromJson(x)));

String iconsToJson(List<Icon> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<Icon> getIcons() {
  String json = ''' 
    [
    {
        "id": 0,
        "url": "static/icons/default.png",
        "description": "Default Icon",
        "category": "General",
        "restricted": true
    },
    {
        "id": 1,
        "url": "static/icons/drama.png",
        "description": "Drama",
        "category": "Draw Hard"
    },
    {
        "id": 2,
        "url": "static/icons/games.png",
        "description": "Games",
        "category": "Draw Hard"
    },
    {
        "id": 3,
        "url": "static/icons/life.png",
        "description": "Life Stuff",
        "category": "Draw Hard"
    },
    {
        "id": 4,
        "url": "static/icons/money.png",
        "description": "Money",
        "category": "Draw Hard"
    },
    {
        "id": 5,
        "url": "static/icons/announcement.png",
        "description": "Announcement",
        "category": "General",
        "restricted": true
    },
    {
        "url": "static/icons/arcade-cabinet.png",
        "description": "Arcade",
        "id": 6,
        "category": "Games"
    },
    {
        "url": "static/icons/blog.png",
        "description": "Blog",
        "id": 7,
        "category": "General"
    },
    {
        "url": "static/icons/bomb.png",
        "description": "Bomb",
        "id": 8,
        "category": "United States"
    },
    {
        "url": "static/icons/bug.png",
        "description": "Bug",
        "id": 9,
        "category": "General"
    },
    {
        "url": "static/icons/code.png",
        "description": "Programming",
        "id": 10,
        "category": "Technology"
    },
    {
        "url": "static/icons/combo-chart.png",
        "description": "Chart",
        "id": 11,
        "category": "General"
    },
    {
        "url": "static/icons/cooker.png",
        "description": "Cooking",
        "id": 12,
        "category": "General"
    },
    {
        "url": "static/icons/crying-baby.png",
        "description": "Baby",
        "id": 13,
        "category": "United States"
    },
    {
        "url": "static/icons/dota.png",
        "description": "Dota 2",
        "category": "Games",
        "id": 14
    },
    {
        "url": "static/icons/europe-news.png",
        "description": "EU News",
        "category": "General",
        "id": 15
    },
    {
        "url": "static/icons/gallery.png",
        "description": "Photos",
        "category": "General",
        "id": 16
    },
    {
        "url": "static/icons/grocery-bag.png",
        "description": "Grocery",
        "category": "Food",
        "id": 17
    },
    {
        "url": "static/icons/gun.png",
        "description": "Gun",
        "category": "United States",
        "id": 18
    },
    {
        "url": "static/icons/heart-with-pulse.png",
        "description": "Health",
        "category": "General",
        "id": 19
    },
    {
        "url": "static/icons/help.png",
        "description": "Help",
        "category": "General",
        "id": 20
    },
    {
        "url": "static/icons/hot-article.png",
        "description": "Hot Topic",
        "category": "General",
        "restricted": true,
        "id": 21
    },
    {
        "url": "static/icons/news.png",
        "description": "News",
        "category": "General",
        "id": 22
    },
    {
        "url": "static/icons/nintendo-entertainment-system.png",
        "description": "Nintendo Entertainment System",
        "category": "Games",
        "id": 23
    },
    {
        "url": "static/icons/pin.png",
        "description": "Pin",
        "category": "General",
        "restricted": true,
        "id": 24
    },
    {
        "url": "static/icons/planner.png",
        "description": "Calendar",
        "category": "General",
        "id": 25
    },
    {
        "url": "static/icons/tv-show.png",
        "description": "Modern TV",
        "category": "Technology",
        "id": 26
    },
    {
        "url": "static/icons/uk-news.png",
        "description": "UK News",
        "category": "General",
        "id": 27
    },
    {
        "url": "static/icons/us-music.png",
        "description": "Music",
        "category": "General",
        "id": 28
    },
    {
        "url": "static/icons/us-news.png",
        "description": "US News",
        "category": "General",
        "id": 29
    },
    {
        "description": "Old TV",
        "url": "static/icons/retro-tv.png",
        "category": "Technology",
        "id": 30
    },
    {
        "description": "Smile",
        "url": "static/icons/smiling.png",
        "category": "General",
        "id": 31
    },
    {
        "description": "Vomit",
        "url": "static/icons/vomited.png",
        "category": "General",
        "id": 32
    },
    {
        "description": "Science",
        "url": "static/icons/test-tube.png",
        "category": "General",
        "id": 33
    },
    {
        "description": "Art",
        "url": "static/icons/easel.png",
        "category": "General",
        "id": 34
    },
    {
        "description": "Banana",
        "url": "static/icons/banana.png",
        "category": "Food",
        "id": 35
    },
    {
        "description": "Love",
        "url": "static/icons/heart-with-arrow.png",
        "category": "General",
        "id": 36
    },
    {
        "description": "Radioactive",
        "url": "static/icons/radio-active.png",
        "category": "General",
        "id": 37
    },
    {
        "description": "Poison",
        "url": "static/icons/poison.png",
        "category": "General",
        "id": 38
    },
    {
        "description": "Eye (Crossed)",
        "url": "static/icons/invisible.png",
        "category": "General",
        "id": 39
    },
    {
        "description": "Eye",
        "url": "static/icons/visible.png",
        "category": "General",
        "id": 40
    },
    {
        "description": "Gamepad",
        "url": "static/icons/controller.png",
        "category": "Games",
        "id": 41
    },
    {
        "description": "Boredom",
        "url": "static/icons/boring.png",
        "category": "General",
        "id": 42
    },
    {
        "description": "Anger",
        "url": "static/icons/swearing-male.png",
        "category": "General",
        "id": 43
    },
    {
        "description": "Idea",
        "url": "static/icons/idea.png",
        "category": "General",
        "id": 44
    },
    {
        "description": "Announcement",
        "url": "static/icons/megaphone.png",
        "category": "General",
        "id": 45
    },
    {
        "description": "Money",
        "url": "static/icons/banknotes.png",
        "category": "General",
        "id": 46
    },
    {
        "description": "Robot",
        "url": "static/icons/robot-3.png",
        "category": "Technology",
        "id": 47
    },
    {
        "description": "Ringing Phone",
        "url": "static/icons/phonelink-ring.png",
        "category": "Technology",
        "id": 48
    },
    {
        "description": "Skull",
        "url": "static/icons/thriller.png",
        "category": "General",
        "id": 49
    },
    {
        "description": "Hamburguer",
        "url": "static/icons/hamburger.png",
        "category": "United States",
        "id": 50
    },
    {
        "description": "Cherry Blossom",
        "url": "static/icons/sakura.png",
        "category": "General",
        "id": 51
    },
    {
        "description": "Sushi",
        "url": "static/icons/sushi.png",
        "category": "Food",
        "id": 52
    },
    {
        "description": "Life Buoy",
        "url": "static/icons/lifebuoy.png",
        "category": "General",
        "id": 53
    },
    {
        "description": "Handshake",
        "url": "static/icons/handshake.png",
        "category": "General",
        "id": 54
    },
    {
        "description": "Fist",
        "url": "static/icons/clenched-fist.png",
        "category": "General",
        "id": 55
    },
    {
        "description": "Mask",
        "url": "static/icons/anonymous-mask.png",
        "category": "General",
        "id": 56
    },
    {
        "description": "Rocket",
        "url": "static/icons/rocket.png",
        "category": "Technology",
        "id": 57
    },
    {
        "description": "Vodka",
        "url": "static/icons/vodka.png",
        "category": "Food",
        "id": 58
    },
    {
        "description": "Poop",
        "url": "static/icons/poo.png",
        "category": "General",
        "id": 59
    },
    {
        "description": "Car",
        "url": "static/icons/sedan.png",
        "category": "Technology",
        "id": 60
    },
    {
        "description": "Futuristic Car",
        "url": "static/icons/tesla-model-x.png",
        "category": "Technology",
        "id": 61
    },
    {
        "description": "RAM",
        "url": "static/icons/memory-slot.png",
        "category": "Technology",
        "id": 62
    },
    {
        "description": "CPU",
        "url": "static/icons/processor.png",
        "category": "Technology",
        "id": 63
    },
    {
        "description": "Fire",
        "url": "static/icons/fire-element.png",
        "category": "General",
        "id": 64
    },
    {
        "description": "Firework",
        "url": "static/icons/firework.png",
        "category": "General",
        "id": 65
    },
    {
        "description": "Siren",
        "url": "static/icons/siren.png",
        "category": "General",
        "id": 66
    },
    {
        "description": "Confetti",
        "url": "static/icons/confetti.png",
        "category": "General",
        "id": 67
    },
    {
        "description": "Campfire",
        "url": "static/icons/campfire.png",
        "category": "General",
        "id": 68
    },
    {
        "description": "Panties",
        "url": "static/icons/panties.png",
        "category": "General",
        "id": 69
    },
    {
        "description": "Nuclear Explosion",
        "url": "static/icons/mushroom-cloud.png",
        "category": "United States",
        "id": 70
    },
    {
        "description": "Bomb",
        "url": "static/icons/bomb-with-timer.png",
        "category": "United States",
        "id": 71
    },
    {
        "description": "Adhd",
        "url": "static/icons/adhd.png",
        "category": "General",
        "id": 72
    },
    {
        "description": "Cute-Monster",
        "url": "static/icons/cute-monster.png",
        "category": "General",
        "id": 73
    },
    {
        "description": "Japan-Circular",
        "url": "static/icons/japan-circular.png",
        "category": "Countries",
        "id": 74
    },
    {
        "description": "Sad-Sun",
        "url": "static/icons/sad-sun.png",
        "category": "General",
        "id": 75
    },
    {
        "description": "Anime-Emoji",
        "url": "static/icons/anime-emoji.png",
        "category": "General",
        "id": 76
    },
    {
        "description": "Daruma-Doll",
        "url": "static/icons/daruma-doll.png",
        "category": "General",
        "id": 77
    },
    {
        "description": "Jellyfish",
        "url": "static/icons/jellyfish.png",
        "category": "General",
        "id": 78
    },
    {
        "description": "Sailor-Moon",
        "url": "static/icons/sailor-moon.png",
        "category": "General",
        "id": 79
    },
    {
        "description": "Argentina-Circular",
        "url": "static/icons/argentina-circular.png",
        "category": "Countries",
        "id": 80
    },
    {
        "description": "Dice",
        "url": "static/icons/dice.png",
        "category": "General",
        "id": 81
    },
    {
        "description": "Landslide",
        "url": "static/icons/landslide.png",
        "category": "General",
        "id": 82
    },
    {
        "description": "Security-Guard",
        "url": "static/icons/security-guard.png",
        "category": "United States",
        "id": 83
    },
    {
        "description": "Australia-Circular",
        "url": "static/icons/australia-circular.png",
        "category": "Countries",
        "id": 84
    },
    {
        "description": "Dog-Pee",
        "url": "static/icons/dog-pee.png",
        "category": "Animals",
        "id": 85
    },
    {
        "description": "Language-Skill",
        "url": "static/icons/language-skill.png",
        "category": "General",
        "id": 86
    },
    {
        "description": "Skull-Heart--V2",
        "url": "static/icons/skull-heart--v2.png",
        "category": "General",
        "id": 87
    },
    {
        "description": "Bad-Piggies",
        "url": "static/icons/bad-piggies.png",
        "category": "Games",
        "id": 88
    },
    {
        "description": "Dog-Pooping",
        "url": "static/icons/dog-pooping.png",
        "category": "United States",
        "id": 89
    },
    {
        "description": "Lasagna",
        "url": "static/icons/lasagna.png",
        "category": "Food",
        "id": 90
    },
    {
        "description": "Soil",
        "url": "static/icons/soil.png",
        "category": "General",
        "id": 91
    },
    {
        "description": "Batman-Emoji",
        "url": "static/icons/batman-emoji.png",
        "category": "General",
        "id": 92
    },
    {
        "description": "Euro-Exchange",
        "url": "static/icons/euro-exchange.png",
        "category": "General",
        "id": 93
    },
    {
        "description": "Lawn-Care",
        "url": "static/icons/lawn-care.png",
        "category": "General",
        "id": 94
    },
    {
        "description": "South-Korea-Circular",
        "url": "static/icons/south-korea-circular.png",
        "category": "Countries",
        "id": 95
    },
    {
        "description": "Belgium-Circular",
        "url": "static/icons/belgium-circular.png",
        "category": "Countries",
        "id": 96
    },
    {
        "description": "Finland-Circular",
        "url": "static/icons/finland-circular.png",
        "category": "Countries",
        "id": 97
    },
    {
        "description": "Lobster",
        "url": "static/icons/lobster.png",
        "category": "Food",
        "id": 98
    },
    {
        "description": "Spain2-Circular",
        "url": "static/icons/spain2-circular.png",
        "category": "Countries",
        "id": 99
    },
    {
        "description": "Boiling",
        "url": "static/icons/boiling.png",
        "category": "Food",
        "id": 100
    },
    {
        "description": "Fortnite",
        "url": "static/icons/fortnite.png",
        "category": "Games",
        "id": 101
    },
    {
        "description": "Marijuana-Leaf",
        "url": "static/icons/marijuana-leaf.png",
        "category": "General",
        "id": 102
    },
    {
        "description": "Statue-Of-Christ-The-Redeemer",
        "url": "static/icons/statue-of-christ-the-redeemer.png",
        "category": "General",
        "id": 103
    },
    {
        "description": "Border-Collie",
        "url": "static/icons/border-collie.png",
        "category": "Animals",
        "id": 104
    },
    {
        "description": "Fry",
        "url": "static/icons/fry.png",
        "category": "Food",
        "id": 105
    },
    {
        "description": "Mdma",
        "url": "static/icons/mdma.png",
        "category": "General",
        "id": 106
    },
    {
        "description": "Stump-With-Roots",
        "url": "static/icons/stump-with-roots.png",
        "category": "General",
        "id": 107
    },
    {
        "description": "Brazil-Circular",
        "url": "static/icons/brazil-circular.png",
        "category": "Countries",
        "id": 108
    },
    {
        "description": "Full-Of-Shit",
        "url": "static/icons/full-of-shit.png",
        "category": "General",
        "id": 109
    },
    {
        "description": "Meowth",
        "url": "static/icons/meowth.png",
        "category": "Games",
        "id": 110
    },
    {
        "description": "Sweden-Circular",
        "url": "static/icons/sweden-circular.png",
        "category": "Countries",
        "id": 111
    },
    {
        "description": "Brigadeiro",
        "url": "static/icons/brigadeiro.png",
        "category": "Food",
        "id": 112
    },
    {
        "description": "Gasoline-Refill",
        "url": "static/icons/gasoline-refill.png",
        "category": "United States",
        "id": 113
    },
    {
        "description": "Mexico-Circular",
        "url": "static/icons/mexico-circular.png",
        "category": "Countries",
        "id": 114
    },
    {
        "description": "Switzerland-Circular",
        "url": "static/icons/switzerland-circular.png",
        "category": "Countries",
        "id": 115
    },
    {
        "description": "Buddha",
        "url": "static/icons/buddha.png",
        "category": "General",
        "id": 116
    },
    {
        "description": "Germany-Circular",
        "url": "static/icons/germany-circular.png",
        "category": "Countries",
        "id": 117
    },
    {
        "description": "Music-Band",
        "url": "static/icons/music-band.png",
        "category": "General",
        "id": 118
    },
    {
        "description": "Tapir",
        "url": "static/icons/tapir.png",
        "category": "Animals",
        "id": 119
    },
    {
        "description": "Call-Me",
        "url": "static/icons/call-me.png",
        "category": "General",
        "id": 120
    },
    {
        "description": "National-Park",
        "url": "static/icons/national-park.png",
        "category": "General",
        "id": 121
    },
    {
        "description": "The-Sims",
        "url": "static/icons/the-sims.png",
        "category": "Games",
        "id": 122
    },
    {
        "description": "Canada-Circular",
        "url": "static/icons/canada-circular.png",
        "category": "Countries",
        "id": 123
    },
    {
        "description": "Great-Britain-Circular",
        "url": "static/icons/great-britain-circular.png",
        "category": "Countries",
        "id": 124
    },
    {
        "description": "Nightmare",
        "url": "static/icons/nightmare.png",
        "category": "General",
        "id": 125
    },
    {
        "description": "Trust",
        "url": "static/icons/trust.png",
        "category": "General",
        "id": 126
    },
    {
        "description": "Car-Fire",
        "url": "static/icons/car-fire.png",
        "category": "General",
        "id": 127
    },
    {
        "description": "Group-Of-Animals",
        "url": "static/icons/group-of-animals.png",
        "category": "Animals",
        "id": 128
    },
    {
        "description": "Nintendo-Gamecube-Controller",
        "url": "static/icons/nintendo-gamecube-controller.png",
        "category": "Games",
        "id": 129
    },
    {
        "description": "Under-Computer",
        "url": "static/icons/under-computer.png",
        "category": "Technology",
        "id": 130
    },
    {
        "description": "Caveman",
        "url": "static/icons/caveman.png",
        "category": "General",
        "id": 131
    },
    {
        "description": "Headache",
        "url": "static/icons/headache.png",
        "category": "General",
        "id": 132
    },
    {
        "description": "No-Drugs",
        "url": "static/icons/no-drugs.png",
        "category": "General",
        "id": 133
    },
    {
        "description": "Undertale",
        "url": "static/icons/undertale.png",
        "category": "Games",
        "id": 134
    },
    {
        "description": "Chad-Circular",
        "url": "static/icons/chad-circular.png",
        "category": "Countries",
        "id": 135
    },
    {
        "description": "Hills",
        "url": "static/icons/hills.png",
        "category": "General",
        "id": 136
    },
    {
        "description": "Norway-Circular",
        "url": "static/icons/norway-circular.png",
        "category": "Countries",
        "id": 137
    },
    {
        "description": "Usa-Circular",
        "url": "static/icons/usa-circular.png",
        "category": "Countries",
        "id": 138
    },
    {
        "description": "Chickenpox",
        "url": "static/icons/chickenpox.png",
        "category": "General",
        "id": 139
    },
    {
        "description": "Hitler",
        "url": "static/icons/hitler.png",
        "category": "General",
        "id": 140
    },
    {
        "description": "Nuke",
        "url": "static/icons/nuke.png",
        "category": "United States",
        "id": 141
    },
    {
        "description": "Ussr-Circular",
        "url": "static/icons/ussr-circular.png",
        "category": "Countries",
        "id": 142
    },
    {
        "description": "China-Circular",
        "url": "static/icons/china-circular.png",
        "category": "Countries",
        "id": 143
    },
    {
        "description": "Holy-Bible",
        "url": "static/icons/holy-bible.png",
        "category": "General",
        "id": 144
    },
    {
        "description": "Overwatch",
        "url": "static/icons/overwatch.png",
        "category": "Games",
        "id": 145
    },
    {
        "description": "Wake-Up",
        "url": "static/icons/wake-up.png",
        "category": "General",
        "id": 146
    },
    {
        "description": "Choir--V2",
        "url": "static/icons/choir--v2.png",
        "category": "General",
        "id": 147
    },
    {
        "description": "Improvement",
        "url": "static/icons/improvement.png",
        "category": "General",
        "id": 148
    },
    {
        "description": "Peace-Pigeon",
        "url": "static/icons/peace-pigeon.png",
        "category": "Animals",
        "id": 149
    },
    {
        "description": "Wildfire",
        "url": "static/icons/wildfire.png",
        "category": "General",
        "id": 150
    },
    {
        "description": "City-Buildings",
        "url": "static/icons/city-buildings.png",
        "category": "General",
        "id": 151
    },
    {
        "description": "India-Circular",
        "url": "static/icons/india-circular.png",
        "category": "Countries",
        "id": 152
    },
    {
        "description": "Plasma-Ball",
        "url": "static/icons/plasma-ball.png",
        "category": "Technology",
        "id": 153
    },
    {
        "description": "Winner",
        "url": "static/icons/winner.png",
        "category": "General",
        "id": 154
    },
    {
        "description": "Complaint",
        "url": "static/icons/complaint.png",
        "category": "General",
        "id": 155
    },
    {
        "description": "Insects",
        "url": "static/icons/insects.png",
        "category": "Animals",
        "id": 156
    },
    {
        "description": "Pocket",
        "url": "static/icons/pocket.png",
        "category": "General",
        "id": 157
    },
    {
        "description": "Wring",
        "url": "static/icons/wring.png",
        "category": "General",
        "id": 158
    },
    {
        "description": "Country",
        "url": "static/icons/country.png",
        "category": "Countries",
        "id": 159
    },
    {
        "description": "Internship",
        "url": "static/icons/internship.png",
        "category": "General",
        "id": 160
    },
    {
        "description": "Pokeball-2",
        "url": "static/icons/pokeball-2.png",
        "category": "Games",
        "id": 161
    },
    {
        "description": "Cross",
        "url": "static/icons/cross.png",
        "category": "General",
        "id": 162
    },
    {
        "description": "Ireland-Circular",
        "url": "static/icons/ireland-circular.png",
        "category": "Countries",
        "id": 163
    },
    {
        "description": "Cup-With-Straw",
        "url": "static/icons/cup-with-straw.png",
        "category": "Food",
        "id": 164
    },
    {
        "description": "Israel-Circular",
        "url": "static/icons/israel-circular.png",
        "category": "Countries",
        "id": 165
    },
    {
        "description": "Pray",
        "url": "static/icons/pray.png",
        "category": "General",
        "id": 166
    },
    {
        "description": "Virtual Reality",
        "url": "static/icons/virtual-reality.png",
        "category": "Games",
        "id": 167
    },
    {
        "description": "Aftereffects",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/aftereffects.svg",
        "category": "Draw Hard",
        "id": 168
    },
    {
        "description": "Anime",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/anime.svg",
        "category": "Draw Hard",
        "id": 169
    },
    {
        "description": "Art",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/art.svg",
        "category": "Draw Hard",
        "id": 170
    },
    {
        "description": "Chat",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/chat.svg",
        "category": "Draw Hard",
        "id": 171
    },
    {
        "description": "Computers",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/computers.svg",
        "category": "Draw Hard",
        "id": 172
    },
    {
        "description": "Cpp",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/cpp.svg",
        "category": "Draw Hard",
        "id": 173
    },
    {
        "description": "Drama",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/drama.svg",
        "category": "Draw Hard",
        "id": 174
    },
    {
        "description": "Everythingnothing",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/everythingnothing.svg",
        "category": "Draw Hard",
        "id": 175
    },
    {
        "description": "Games",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/games.svg",
        "category": "Draw Hard",
        "id": 176
    },
    {
        "description": "Gross",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/gross.svg",
        "category": "Draw Hard",
        "id": 177
    },
    {
        "description": "Heart",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/heart.svg",
        "category": "Draw Hard",
        "id": 178
    },
    {
        "description": "Heartbreak",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/heartbreak.svg",
        "category": "Draw Hard",
        "id": 179
    },
    {
        "description": "Help",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/help.svg",
        "category": "Draw Hard",
        "id": 180
    },
    {
        "description": "Html",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/html.svg",
        "category": "Draw Hard",
        "id": 181
    },
    {
        "description": "Humor",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/humor.svg",
        "category": "Draw Hard",
        "id": 182
    },
    {
        "description": "Js",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/js.svg",
        "category": "Draw Hard",
        "id": 183
    },
    {
        "description": "Life",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/life.svg",
        "category": "Draw Hard",
        "id": 184
    },
    {
        "description": "Link",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/link.svg",
        "category": "Draw Hard",
        "id": 185
    },
    {
        "description": "Lua",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/lua.svg",
        "category": "Draw Hard",
        "id": 186
    },
    {
        "description": "Map",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/map.svg",
        "category": "Draw Hard",
        "id": 187
    },
    {
        "description": "Microsoft",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/microsoft.svg",
        "category": "Draw Hard",
        "id": 188
    },
    {
        "description": "Money",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/money.svg",
        "category": "Draw Hard",
        "id": 189
    },
    {
        "description": "Movies",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/movies.svg",
        "category": "Draw Hard",
        "id": 190
    },
    {
        "description": "Music",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/music.svg",
        "category": "Draw Hard",
        "id": 191
    },
    {
        "description": "News",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/news.svg",
        "category": "Draw Hard",
        "id": 192
    },
    {
        "description": "Nintendo",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/nintendo.svg",
        "category": "Draw Hard",
        "id": 193
    },
    {
        "description": "Nsfw",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/nsfw.svg",
        "category": "Draw Hard",
        "id": 194
    },
    {
        "description": "Pc",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/pc.svg",
        "category": "Draw Hard",
        "id": 195
    },
    {
        "description": "Pets",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/pets.svg",
        "category": "Draw Hard",
        "id": 196
    },
    {
        "description": "Photos",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/photos.svg",
        "category": "Draw Hard",
        "id": 197
    },
    {
        "description": "Photoshop",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/photoshop.svg",
        "category": "Draw Hard",
        "id": 198
    },
    {
        "description": "Php",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/php.svg",
        "category": "Draw Hard",
        "id": 199
    },
    {
        "description": "Politics",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/politics.svg",
        "category": "Draw Hard",
        "id": 200
    },
    {
        "description": "Poll",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/poll.svg",
        "category": "Draw Hard",
        "id": 201
    },
    {
        "description": "Postyour",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/postyour.svg",
        "category": "Draw Hard",
        "id": 202
    },
    {
        "description": "Programming",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/programming.svg",
        "category": "Draw Hard",
        "id": 203
    },
    {
        "description": "Question",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/question.svg",
        "category": "Draw Hard",
        "id": 204
    },
    {
        "description": "Rant",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/rant.svg",
        "category": "Draw Hard",
        "id": 205
    },
    {
        "description": "Release",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/release.svg",
        "category": "Draw Hard",
        "id": 206
    },
    {
        "description": "Repeat",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/repeat.svg",
        "category": "Draw Hard",
        "id": 207
    },
    {
        "description": "Request",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/request.svg",
        "category": "Draw Hard",
        "id": 208
    },
    {
        "description": "School",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/school.svg",
        "category": "Draw Hard",
        "id": 209
    },
    {
        "description": "Science",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/science.svg",
        "category": "Draw Hard",
        "id": 210
    },
    {
        "description": "Shitpost",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/shitpost.svg",
        "category": "Draw Hard",
        "id": 211
    },
    {
        "description": "Sony",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/sony.svg",
        "category": "Draw Hard",
        "id": 212
    },
    {
        "description": "Stupid",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/stupid.svg",
        "category": "Draw Hard",
        "id": 213
    },
    {
        "description": "Tutorial",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/tutorial.svg",
        "category": "Draw Hard",
        "id": 214
    },
    {
        "description": "Tv",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/tv.svg",
        "category": "Draw Hard",
        "id": 215
    },
    {
        "description": "Valve",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/valve.svg",
        "category": "Draw Hard",
        "id": 216
    },
    {
        "description": "Wip",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/wip.svg",
        "category": "Draw Hard",
        "id": 217
    },
    {
        "description": "Ninja - Sub Zero",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-subzero.png",
        "category": "Games",
        "id": 218
    },
    {
        "description": "Walter White",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/walter-white.png",
        "category": "Pop Culture",
        "id": 219
    },
    {
        "description": "Spiderman",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/spiderman.png",
        "category": "Pop Culture",
        "id": 220
    },
    {
        "description": "Sex Offender",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/sex-offender.png",
        "category": "General",
        "id": 221
    },
    {
        "description": "Scream",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/scream.png",
        "category": "Pop Culture",
        "id": 222
    },
    {
        "description": "One Ring to Rule them All",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/lotr-ring.png",
        "category": "Pop Culture",
        "id": 223
    },
    {
        "description": "Iron Man",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/iron-man.png",
        "category": "Pop Culture",
        "id": 224
    },
    {
        "description": "Female Back",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/female-back.png",
        "category": "General",
        "id": 225
    },
    {
        "description": "Darth Vader",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/darth-vader.png",
        "category": "Pop Culture",
        "id": 226
    },
    {
        "description": "Batman",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/batman.png",
        "category": "Pop Culture",
        "id": 227,
        "restricted": true
    },
    {
        "description": "Ninja - Tremor",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-tremor.png",
        "category": "Games",
        "id": 228,
        "restricted": true
    },
    {
        "description": "Ninja - Smoke",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-smoke.png",
        "category": "Games",
        "id": 229
    },
    {
        "description": "Ninja - Scorpion",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-scorpion.png",
        "category": "Games",
        "id": 230,
        "restricted": true
    },
    {
        "description": "Ninja - Reptile",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-reptile.png",
        "category": "Games",
        "id": 231,
        "restricted": true
    },
    {
        "description": "Ninja - Rain",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-rain.png",
        "category": "Games",
        "id": 232,
        "restricted": true
    },
    {
        "description": "Ninja - Noob",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-noob.png",
        "category": "Games",
        "id": 233,
        "restricted": true
    },
    {
        "description": "Ninja - Ermac",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-ermac.png",
        "category": "Games",
        "id": 234,
        "restricted": true
    },
    {
        "description": "Ninja - Chameleon",
        "url": "https://cdn.knockout.chat/hotlink-ok/thread-icons/ninja-chameleon.gif",
        "category": "Games",
        "id": 235,
        "restricted": true
    }
]
  ''';
  return iconsFromJson(json);
}

Icon getIconOrDefault(iconId) {
  try {
    return getIcons().firstWhere((Icon litem) => litem.id == iconId);
  } catch (err) {
    return getIcons().first;
  }
}

const _baseurl = "https://knockout.chat/";
//const _cdnUrl = "https://cdn.knockout.chat/";
//const _ratingsUrl = "${_cdnUrl}assets/ratings/rating-";

class Icon {
  Icon({
    this.id,
    this.url,
    this.description,
    this.category,
    this.restricted,
  });

  int id;
  String url;
  String description;
  Category category;
  bool restricted;

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
        id: json["id"],
        url: json["url"].toString().startsWith('static')
            ? _baseurl +
                json["url"] // If url starts with static, append baseURL
            : json["url"],
        description: json["description"],
        category: categoryValues.map[json["category"]],
        restricted: json["restricted"] == null ? null : json["restricted"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
        "description": description,
        "category": categoryValues.reverse[category],
        "restricted": restricted == null ? null : restricted,
      };
}

enum Category {
  GENERAL,
  DRAW_HARD,
  GAMES,
  UNITED_STATES,
  TECHNOLOGY,
  FOOD,
  COUNTRIES,
  ANIMALS,
  POP_CULTURE
}

final categoryValues = EnumValues({
  "Animals": Category.ANIMALS,
  "Countries": Category.COUNTRIES,
  "Draw Hard": Category.DRAW_HARD,
  "Food": Category.FOOD,
  "Games": Category.GAMES,
  "General": Category.GENERAL,
  "Pop Culture": Category.POP_CULTURE,
  "Technology": Category.TECHNOLOGY,
  "United States": Category.UNITED_STATES
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
