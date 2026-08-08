local Assets = dofile("/data-fall-from-heaven/ffh/assets.lua")

local _M = {}

_M.owner_city_icon = {
    [6] = Assets.icons.city_clan,
}

_M.kind_sprite = {
    expedition = Assets.sprites.chariot,
    warband = Assets.sprites.archer,
    abashi = Assets.sprites.abaddon,
    archer = Assets.sprites.archer,
    beast = Assets.sprites.beast,
    inferno = Assets.sprites.inferno,
    scorpion = Assets.sprites.scorpion,
    vampire_lord = Assets.sprites.vampire_lord,
}

function _M.cityIcon(owner)
    return _M.owner_city_icon[owner] or Assets.icons.city_sheaim
end

function _M.unitSprite(kind)
    return _M.kind_sprite[kind] or Assets.icons.warband
end

return _M
