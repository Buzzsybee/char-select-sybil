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

        wallkicks = 0,
        wallrides = 0,
      
        gfxAngleX = 0,
        gfxAngleY = 0,
        gfxAngleZ = 0,
    }
end

for i = 0, (MAX_PLAYERS - 1) do
    reset_sybil_states(i)
end

ACT_SYBIL_WALKING = allocate_mario_action(ACT_FLAG_MOVING | ACT_GROUP_MOVING | ACT_FLAG_WATER_OR_TEXT)

ACT_SYBIL_JUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_CONTROL_JUMP_HEIGHT)

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

local function update_sybil_gravity(m)
    m.vel.y = m.vel.y - 4
end

local function update_sybil_rotation(m)
    m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0xF00, 0xF00);
    djui_chat_message_create(tostring(math.abs(m.faceAngle.y - m.intendedYaw)))
    m.forwardVel = m.forwardVel* (1 - math.abs(convert_s16(m.faceAngle.y - m.intendedYaw))/0x9000)
end

local function apply_sybil_slope_accel(m)
    -- This doesn't actually do any slope stuffs, just here for rotation
    local slopeAccel;

    local floor = m.floor;
    if (floor == nil) then return end
    local steepness = math.sqrt(floor.normal.x * floor.normal.x + floor.normal.z * floor.normal.z);

    local normalY = floor.normal.y;
    local floorDYaw = m.floorAngle - m.faceAngle.y;

    m.slideYaw = m.faceAngle.y;

    m.slideVelX = m.forwardVel * sins(m.faceAngle.y);
    m.slideVelZ = m.forwardVel * coss(m.faceAngle.y);

    m.vel.x = m.slideVelX;
    m.vel.y = 0.0;
    m.vel.z = m.slideVelZ;

    mario_update_moving_sand(m);
    mario_update_windy_ground(m);
end


local function update_sybil_walking_speed(m)
    local maxTargetSpeed;
    local targetSpeed;

    if (m.floor ~= nil and m.floor.type == SURFACE_SLOW) then
        maxTargetSpeed = 22.0;
    else
        maxTargetSpeed = 28.0;
    end

    targetSpeed = m.intendedMag < maxTargetSpeed and m.intendedMag or maxTargetSpeed;

    if (m.quicksandDepth > 10.0) then
        targetSpeed = targetSpeed * 6.25 / m.quicksandDepth;
    end

    if (m.forwardVel <= 0.0) then
        m.forwardVel = m.forwardVel + 1.1;
    elseif (m.forwardVel <= targetSpeed) then
        m.forwardVel = m.forwardVel + 1.1 - m.forwardVel / 43.0;
    elseif (m.floor ~= nil and m.floor.normal.y >= 0.95) then
        m.forwardVel = m.forwardVel - 1.0;
    end

    if (m.forwardVel > 48.0) then
        m.forwardVel = 48.0;
    end

    update_sybil_rotation(m)
    apply_sybil_slope_accel(m);
end

local function act_sybil_walk(m)
    local startPos = {x = 0, y = 0, z = 0}
    local startYaw = m.faceAngle.y;

    mario_drop_held_object(m);

    --[[
    if (should_begin_sliding(m)) {
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0);
    }
    ]]

    if (m.input & INPUT_FIRST_PERSON ~= 0) then
        return begin_braking_action(m);
    end

    if (m.input & INPUT_A_PRESSED ~= 0) then
        return set_mario_action(m, ACT_SYBIL_JUMP, 0);
    end

    if (check_ground_dive_or_punch(m) ~= 0) then
        return true;
    end

    if (m.input & INPUT_NONZERO_ANALOG == 0) then
        return begin_braking_action(m);
    end

    if (analog_stick_held_back(m) ~= 0 and m.forwardVel >= 16.0) then
        return set_mario_action(m, ACT_TURNING_AROUND, 0);
    end

    if (m.input & INPUT_Z_PRESSED ~= 0) then
        return set_mario_action(m, ACT_SYBIL_SLIDE, 0);
    end

    m.actionState = 0;

    vec3f_copy(startPos, m.pos);
    update_sybil_walking_speed(m);

    local step = (perform_ground_step(m))
    if step == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_SYBIL_FREEFALL, 0);
        set_character_animation(m, CHAR_ANIM_GENERAL_FALL);
    elseif step == GROUND_STEP_NONE then
        anim_and_audio_for_walk(m);
        if (m.intendedMag - m.forwardVel > 16.0) then
            set_mario_particle_flags(m, PARTICLE_DUST, 0);
        end
    elseif step == GROUND_STEP_HIT_WALL then
        --push_or_sidle_wall(m, startPos);
        m.forwardVel = m.forwardVel - 5
        m.actionTimer = 0;
    end

    --check_ledge_climb_down(m);
    tilt_body_walking(m, startYaw);
    return false;
end

local function act_sybil_jump(m)
    if m.actionTimer < 5 and m.input & INPUT_A_DOWN ~= 0 then
        if m.actionArg == 0 then 
            m.vel.y = 45
        end
    end
    if (check_kick_or_dive_in_air(m) ~= 0) then
        return true;
    end

    if (m.input & INPUT_Z_PRESSED ~= 0) then
        return set_mario_action(m, ACT_GROUND_POUND, 0);
    end

    play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, 0);
    common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_SINGLE_JUMP,
                           AIR_STEP_CHECK_LEDGE_GRAB);

    update_sybil_rotation(m)
    m.actionTimer = m.actionTimer + 1
    return false;
end

local function act_sybil_freefall(m)
    local animation = 0;

    if (m.input & INPUT_B_PRESSED ~= 0) then
        --return set_mario_action(m, ACT_DIVE, 0);
    end

    if (m.input & INPUT_Z_PRESSED ~= 0) then
        --return set_mario_action(m, ACT_GROUND_POUND, 0);
    end

    if m.actionArg == 0 then
        animation = CHAR_ANIM_GENERAL_FALL;
    elseif m.actionArg == 1 then
        animation = CHAR_ANIM_FALL_FROM_SLIDE;
    elseif m.actionArg == 2 then
        animation = CHAR_ANIM_FALL_FROM_SLIDE_KICK;
    end

    common_air_action_step(m, ACT_FREEFALL_LAND, animation, AIR_STEP_CHECK_LEDGE_GRAB);
    update_sybil_rotation(m)
    return false;
end

local function act_sybil_attack(m)

end

local function act_sybil_crouch(m)

end

local function act_sybil_slide(m)

end

local function act_sybil_slide_fall(m)

end

local function act_sybil_slide_jump(m)

end

local function act_sybil_sideflip(m)

end

local function act_sybil_air_kick(m)

end

local function act_sybil_wall_bounce(m)

end

local function act_sybil_backflip(m)

end

local function act_sybil_high_jump(m)

end

local function act_sybil_ground_pound(m)

end

local function act_sybil_wall_ride(m)

end

local function act_sybil_bounce(m)

end

local function act_sybil_air_brake(m)

end

hook_mario_action(ACT_SYBIL_WALKING, act_sybil_walk)
hook_mario_action(ACT_SYBIL_JUMP, {every_frame = act_sybil_jump, gravity = update_sybil_gravity})
hook_mario_action(ACT_SYBIL_FREEFALL, {every_frame = act_sybil_freefall, gravity = update_sybil_gravity})

local function update_sybil(m)
    local e = gExtrasStates[m.playerIndex]

    -- Global Action Timer 
    e.actionTick = e.actionTick + 1
    if e.prevFrameAction ~= m.action then
        e.prevFrameAction = m.action
        e.actionTick = 0
    end
end

local jumpActs = {
    [ACT_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
}

local function before_sybil_action(m, nextAct)
    local e = gExtrasStates[m.playerIndex]
    if nextAct == ACT_WALKING and not e.forceDefaultWalk then
        return set_mario_action(m, ACT_SYBIL_WALKING, 0)
    else
        e.forceDefaultWalk = false
    end

    if jumpActs[nextAct] then
        return set_mario_action(m, ACT_SYBIL_JUMP, nextAct == ACT_TRIPLE_JUMP and 1 or 0)
    end

    if nextAct == ACT_FREEFALL then
        return set_mario_action(m, ACT_SYBIL_FREEFALL, 0)
    end
end

_G.charSelect.character_hook_moveset(CHAR_SYBIL, HOOK_MARIO_UPDATE, update_sybil)
_G.charSelect.character_hook_moveset(CHAR_SYBIL, HOOK_BEFORE_SET_MARIO_ACTION, before_sybil_action)
_G.charSelect.character_hook_moveset(CHAR_SYBIL, HOOK_ON_LEVEL_INIT, reset_sybil_states)