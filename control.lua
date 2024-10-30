script.on_event(defines.events.on_pre_player_crafted_item,function(event)
	local player=game.players[event.player_index]
	--	instant hand-crafting
	instant_crafting_init_storage()
	instant_crafting_cancel_craft(player)
	instant_crafting_remove_ingredients(player)
	instant_crafting_add_products(player)
end)
script.on_event(defines.events.on_player_cancelled_crafting,function(event)
	local player=game.players[event.player_index]
	--	instant hand-crafting
	instant_crafting_init_storage()
	instant_crafting_remember_products(event.recipe,event.cancel_count)
	instant_crafting_remember_ingredients(event.items)
end)
--	instant hand-crafting
function instant_crafting_init_storage()
	storage.instant_crafting={}
	storage.instant_crafting.products={}
	storage.instant_crafting.ingredients={}
end
function instant_crafting_cancel_craft(player)
	local craft_to_cancel={}
	craft_to_cancel.index=#player.crafting_queue
	craft_to_cancel.count=player.crafting_queue[craft_to_cancel.index].count
	player.cancel_crafting(craft_to_cancel)
end
function instant_crafting_remember_products(recipe,count)
	for _,product in pairs(recipe.products)do
		local product_to_insert={}
		product_to_insert.name=product.name
		if product.amount then
			product_to_insert.count=product.amount
		end
		if product.amount_max then
			product_to_insert.count=math.floor((product.amount_min+product.amount_max)/2)
		end
		product_to_insert.count=product_to_insert.count*count
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
		local stack={}
		stack.name=item
		stack.count=count
		table.insert(storage.instant_crafting.ingredients,stack)
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