local SCENES = {
    GAME = 'scenes.game',
    MENU = 'scenes.menu',
    HIGH_SCORES = 'scenes.highscores',
    GAME_OVER = 'scenes.gameover'
}

local DIRECTIONS = {
    LEFT = 1,
    TOP = 2,
    RIGHT = 3
}

local TRANSITION_TIMES = {
    SHIP_MOVEMENT = 250,
    LASER_MOVEMENT = 500
}

local TRANSITIONS = {
    PAGE_CHANGE = { time=800, effect="crossFade" }
}

local AUDIO_DIRECTORY = 'assets/audio/'
local IMAGES_DIRECTORY = 'assets/images/'
local PARTICLES_DIRECTORY = 'assets/particles/'

local DIRECTORIES = {
    AUDIO = AUDIO_DIRECTORY,
    IMAGES = IMAGES_DIRECTORY,
    PARTICLES = PARTICLES_DIRECTORY
}

local SOUNDS = {
    EXPLOSION = AUDIO_DIRECTORY .. 'explosion.wav',
    FIRE = AUDIO_DIRECTORY .. 'fire.wav'
}

local MUSIC = {
    GAME = AUDIO_DIRECTORY .. '80s-Space-Game_Looping.wav',
    MENU = AUDIO_DIRECTORY .. 'Escape_Looping.wav',
    HIGH_SCORES = AUDIO_DIRECTORY .. 'Midnight-Crawlers_Looping.wav'
}

local IMAGES = {
    BACKGROUND = IMAGES_DIRECTORY .. 'background.png',
    GAME_TITLE = IMAGES_DIRECTORY .. 'title.png',
    GAME_OBJECTS = IMAGES_DIRECTORY .. 'gameObjects.png',
}

local PARTICLES = {
    FIRE_EXPLOSION = PARTICLES_DIRECTORY .. 'explosion.json',
    GALAXY = PARTICLES_DIRECTORY .. 'galaxy.json'
}

return {
    SCENES = SCENES,
    DIRECTIONS = DIRECTIONS,
    TRANSITION_TIMES = TRANSITION_TIMES,
    TRANSITIONS = TRANSITIONS,
    SOUNDS = SOUNDS,
    MUSIC = MUSIC,
    IMAGES = IMAGES,
    PARTICLES = PARTICLES,
    DIRECTORIES = DIRECTORIES
}