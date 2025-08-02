if not _G.charSelectExists then return end

local function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end

local s16 = function(x)

    x = (math.floor(x) & 0xFFFF)

    if x >= 32768 then return x - 65536 end
    return x
end

gExtrasStates = {}
function reset_sybil_states(index)
    if index == nil then index = 0 end
    gExtrasStates[index] = {
        index = network_global_index_from_local(0),
        actionTick = 0,
        prevFrameAction = 0,
      
        gfxAngleX = 0,
        gfxAngleY = 0,
        gfxAngleZ = 0,
    }
end

for i = 0, (MAX_PLAYERS - 1) do
    reset_sybil_states(i)
end

ACT_SYBIL_WALKING = allocate_mario_action(ACT_FLAG_MOVING | ACT_GROUP_MOVING | ACT_FLAG_WATER_OR_TEXT)

ACT_SYBIL_JUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

ACT_SYBIL_FREEFALL = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

ACT_SYBIL_ATTACK = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_FLAG_MOVING)

ACT_SYBIL_CROUCH = allocate_mario_action(ACT_FLAG_STATIONARY | ACT_FLAG_IDLE)

ACT_SYBIL_SLIDE = allocate_mario_action(ACT_FLAG_MOVING | ACT_GROUP_MOVING | ACT_FLAG_WATER_OR_TEXT)

ACT_SYBIL_SLIDE_FALL = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

ACT_SYBIL_SLIDE_JUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

ACT_SYBIL_SIDEFLIP = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

ACT_SYBIL_AIR_KICK = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

ACT_SYBIL_WALL_BOUNCE = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

ACT_SYBIL_BACKFLIP = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

ACT_SYBIL_GROUND_POUND = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

ACT_SYBIL_HIGH_JUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

ACT_SYBIL_WALL_RIDE = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

ACT_SYBIL_BOUNCE = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

ACT_SYBIL_AIR_BRAKE = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING)

--placeholder functions for actions

local function act_sybil_walk()
    
end

local function act_sybil_walk()
    
end

local function act_sybil_jump()

end

local function act_sybil_freefall()

end

local function act_sybil_attack()

end

local function act_sybil_crouch()

end

local function act_sybil_slide()

end

local function act_sybil_slide_fall()

end

local function act_sybil_slide_jump()

end

local function act_sybil_sideflip()

end

local function act_sybil_air_kick()

end

local function act_sybil_wall_bounce()

end

local function act_sybil_backflip()

end

local function act_sybil_high_jump()

end

local function act_sybil_ground_pound()

end

local function act_sybil_wall_ride()

end

local function act_sybil_bounce()

end

local function act_sybil_air_brake()

end

local function update_sybil(m)
    local e = gExtrasStates[m.playerIndex]

    -- Global Action Timer 
    e.actionTick = e.actionTick + 1
    if e.prevFrameAction ~= m.action then
        e.prevFrameAction = m.action
        e.actionTick = 0
    end
end

_G.charSelect.character_hook_moveset(CHAR_SYBIL, HOOK_MARIO_UPDATE, update_sybil)
_G.charSelect.character_hook_moveset(CHAR_SYBIL, HOOK_ON_LEVEL_INIT, reset_sybil_states)