local UINT32_MAX=(2^32)-1--maximum value for an unsigned 32-bit integer
local CHARACTER=data.raw['character']['character']
local DEFAULT_UTILITY_CONSTANTS=data.raw['utility-constants']['default']
--	remove character hit-box (no clip)
CHARACTER.collision_box={{0,0},{0,0}}
--	extend player reach
CHARACTER.build_distance=UINT32_MAX
CHARACTER.drop_item_distance=UINT32_MAX
CHARACTER.reach_distance=UINT32_MAX
CHARACTER.reach_resource_distance=UINT32_MAX
--	tint entity ghosts to a vibrant teal
local ghost_tint={
	g=1,
	b=1,
	a=.3}
local tile_ghost_tint={
	g=1,
	b=1,
	a=.4}
DEFAULT_UTILITY_CONSTANTS.ghost_tint=ghost_tint
DEFAULT_UTILITY_CONSTANTS.tile_ghost_tint=tile_ghost_tint