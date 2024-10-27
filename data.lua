local UINT32_MAX=(2^32)-1--maximum value for an unsigned 32-bit integer
--	remove character hit-box (no clip)
data.raw['character']['character'].collision_box={
	{0,0},
	{0,0}}
--	extend player reach
data.raw['character']['character'].build_distance=UINT32_MAX
data.raw['character']['character'].drop_item_distance=UINT32_MAX
data.raw['character']['character'].reach_distance=UINT32_MAX
data.raw['character']['character'].reach_resource_distance=UINT32_MAX
--	tint entity ghosts to a vibrant teal
local ghost_tint={
	g=1,
	b=1,
	a=.3}
local tile_ghost_tint={
	g=1,
	b=1,
	a=.4}
data.raw['utility-constants']['default'].ghost_tint=ghost_tint
data.raw['utility-constants']['default'].tile_ghost_tint=tile_ghost_tint