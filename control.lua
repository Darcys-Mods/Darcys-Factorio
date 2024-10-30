script.on_event(defines.events.on_built_entity,function(event)
	local player=game.players[event.player_index]
	--	instant build
	prepare_build(player)
end,{{
	filter='type',
	type='entity-ghost'
}})
script.on_event(defines.events.on_marked_for_upgrade,function(event)
	local player=game.players[event.player_index]
	--	instant build
	prepare_build(player)
end)
script.on_event(defines.events.on_player_cancelled_crafting,function(event)
	local player=game.players[event.player_index]
	--	instant hand-crafting
	instant_crafting_init_storage()
	instant_crafting_remember_products(event.recipe,event.cancel_count)
	instant_crafting_remember_ingredients(event.items)
end)
script.on_event(defines.events.on_player_deconstructed_area,function(event)
	local player=game.players[event.player_index]
	--	instant build
	prepare_build(player)
end)
script.on_event(defines.events.on_player_main_inventory_changed,function(event)
	local player=game.players[event.player_index]
	--	instant build
	prepare_build(player)
	--	infinite inventory
	infinite_inventory_adjust_inventory(player)
end)
script.on_event(defines.events.on_pre_player_crafted_item,function(event)
	local player=game.players[event.player_index]
	--	instant hand-crafting
	instant_crafting_init_storage()
	instant_crafting_cancel_craft(player)
	instant_crafting_remove_ingredients(player)
	instant_crafting_add_products(player)
end)
script.on_event(defines.events.on_undo_applied,function(event)
	local player=game.players[event.player_index]
	--	instant build
	prepare_build(player)
end)
--	instant build
function prepare_build(player)
	storage.todo={
		deconstructables=game.surfaces[1].find_entities_filtered{
			to_be_deconstructed=true
		},
		reconstructables=game.surfaces[1].find_entities_filtered{
			to_be_upgraded=true
		},
		constructables=game.surfaces[1].find_entities_filtered{
			type='entity-ghost'
		}
	}
	do_deconstruction(player)
	do_reconstruction(player)
	do_construction(player)
end
function do_deconstruction(player)
	for _,deconstructable in pairs(storage.todo.deconstructables)do
		player.mine_entity(deconstructable)
	end
end
function do_reconstruction(player)
	for _,reconstructable in pairs(storage.todo.reconstructables)do
		upgrade_target=reconstructable.get_upgrade_target()
		if player.get_item_count(upgrade_target.name)>0 then
			player.remove_item{
				name=upgrade_target.name,
				count=1
			}
			if player.can_insert({
				name=reconstructable.name,
				count=1
			})then
				player.insert({
					name=reconstructable.name,
					count=1
				})
			else
				player.surface.spill_item_stack(player.position,{
					name=reconstructable.name,
					count=1
				},1,player.force,0)
			end
			local underground_type
			if reconstructable.type=='underground-belt' then
				underground_type=reconstructable.belt_to_ground_type
			end
			local entity_upgrade=player.surface.create_entity{
				name=upgrade_target.name,
				position={
					reconstructable.position.x,
					reconstructable.position.y
				},
				direction=reconstructable.direction,
				force=player.force,
				fast_replace=true,
				spill=false,
				type=underground_type
			}
		end
	end
end
function do_construction(player)
	for _,constructable in pairs(storage.todo.constructables)do
		if player.get_item_count(constructable.ghost_name)>0 then
			player.remove_item{
				name=constructable.ghost_name,
				count=1
			}
			constructable.revive()
		end
	end
end
--	infinite inventory
function infinite_inventory_adjust_inventory(player)
	local inventory=player.get_main_inventory()
	local slots_occupied=0
	for i1=#inventory,1,-1 do
		local slot=inventory[i1]
		if slot.count>0 then
			slots_occupied=slots_occupied+1
		end
	end
	player.character_inventory_slots_bonus=slots_occupied
end
--	instant hand-crafting
function instant_crafting_init_storage()
	storage.instant_crafting={
		products={},
		ingredients={}
	}
end
function instant_crafting_cancel_craft(player)
	player.cancel_crafting({
		index=#player.crafting_queue,
		count=player.crafting_queue[#player.crafting_queue].count
	})
end
function instant_crafting_remember_products(recipe,count)
	for _,product in pairs(recipe.products)do
		local product_to_insert={
			name=product.name,
			count=(product.amount or 0)*count
		}
		if product.amount_max then
			product_to_insert.count=math.floor((product.amount_min+product.amount_max)/2)*count
		end
		table.insert(storage.instant_crafting.products,product_to_insert)
	end
end
function instant_crafting_add_products(player)
	for _,product in pairs(storage.instant_crafting.products)do
		player.insert(product)
	end
end
function instant_crafting_remember_ingredients(items)
	for item,count in pairs(items.get_contents())do
		table.insert(storage.instant_crafting.ingredients,{
			name=item,
			count=count
		})
	end
end
function instant_crafting_remove_ingredients(player)
	for _,ingredient in pairs(storage.instant_crafting.ingredients)do
		player.remove_item({
			type='item',
			name=ingredient.count.name,
			count=ingredient.count.count
		})
	end
end