s = gMarioStates[0]

function spawn_particle(particle)
    s.particleFlags = s.particleFlags | particle
end