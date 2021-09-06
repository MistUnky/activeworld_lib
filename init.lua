function reg_plont(plant, soils, atmos)
	minetest.register_abm({
		nodenames = soils,
		interval = 1,
		chance = 8*8,
		catch_up = false,
		action = function(pos)
			if minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name == atmos and minetest.find_node_near(pos, 2, {plant}) then
				minetest.set_node({x=pos.x,y=pos.y+1,z=pos.z}, {name=plant})
			end
		end
	})
	minetest.register_abm({
		nodenames = {plant},
		interval = 1,
		chance = 8,
		catch_up = false,
		action = function(pos)
			minetest.set_node(pos, {name=atmos})
		end
	})
end

function reg_plant(plant, soils)
	reg_plont(plant, soils, "air")
end

function reg_parasite(parasite, food, ch)
	minetest.register_abm({
		nodenames = food,
		neighbors = {parasite}, -- this instead of 2?
		interval = 1,
		chance = ch,
		catch_up = false,
		action = function(pos)
			--if minetest.find_node_near(pos, 2, {parasite}) then
				minetest.set_node(pos, {name=parasite})
			--end
		end
	})
end

function reg_finite_liq(liquid)
	minetest.register_abm({
		nodenames = {liquid.."_source"},
		interval = 1,
		chance = 1,
		catch_up = false,
		action = function(pos)
			if minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == liquid.."_flowing" then
				minetest.set_node(pos, {name="air"})
				minetest.set_node({x=pos.x,y=pos.y-1,z=pos.z}, {name=liquid.."_source"})
			else
				local mymeta = math.random(1,4)
				local mypos = {x=0,y=0,z=0}
				if mymeta == 1 then
					mypos = {x=pos.x+1,y=pos.y,z=pos.z}
				elseif mymeta == 2 then
					mypos = {x=pos.x-1,y=pos.y,z=pos.z}
				elseif mymeta == 3 then
					mypos = {x=pos.x,y=pos.y,z=pos.z+1}
				elseif mymeta == 4 then
					mypos = {x=pos.x,y=pos.y,z=pos.z-1}
				end
				if minetest.get_node(mypos).name == liquid.."_flowing" then
					minetest.set_node(pos, {name="air"})
					minetest.set_node(mypos, {name=liquid.."_source"})
				end
			end
		end
	})
	minetest.override_item(liquid.."_source", {liquid_renewable = false})
	minetest.override_item(liquid.."_flowing", {liquid_renewable = false})
end

function reg_sync_f(brain)
	for node = 1, #brain do
		minetest.override_item(brain[node], {walkable = true, groups = {falling_node = 1, choppy = 1}})
		reg_parasite(brain[node], brain, 28)
	end
end

function reg_sync(brain)
	for node = 1, #brain do
		reg_parasite(brain[node], brain, 28)
	end
end

function reg_melt(solid) --needs work
	minetest.register_abm({
		nodenames = {solid},
		interval = 1,
		chance = 1,
		catch_up = false,
		action = function(pos)
			local plode = minetest.get_node(pos).name
			if minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name ~= "default:stone" and minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name ~= "default:desert_stone" and minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name ~= "default:ice" then
				if minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "air" or minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "default:water_flowing" or minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "default:river_water_flowing" then
					minetest.set_node(pos, {name="air"})
					minetest.set_node({x=pos.x,y=pos.y-1,z=pos.z}, {name=plode})
				elseif minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "default:water_source" then
					minetest.set_node(pos, {name="default:water_source"})
					minetest.set_node({x=pos.x,y=pos.y-1,z=pos.z}, {name=plode})
				elseif minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "default:river_water_source" then
					minetest.set_node(pos, {name="default:river_water_source"})
					minetest.set_node({x=pos.x,y=pos.y-1,z=pos.z}, {name=plode})
				else
					--if not minetest.find_node_near(pos, 0, {"default:stone"}) then
						local mymeta = math.random(1,4)
						local mypos = {x=0,y=0,z=0}
						if mymeta == 1 then
							mypos = {x=pos.x+1,y=pos.y,z=pos.z}
						elseif mymeta == 2 then
							mypos = {x=pos.x-1,y=pos.y,z=pos.z}
						elseif mymeta == 3 then
							mypos = {x=pos.x,y=pos.y,z=pos.z+1}
						elseif mymeta == 4 then
							mypos = {x=pos.x,y=pos.y,z=pos.z-1}
						end
						if minetest.get_node(mypos).name == "air" or minetest.get_node(mypos).name == "default:water_flowing" then
							minetest.set_node(pos, {name="air"})
							minetest.set_node(mypos, {name=plode})
						elseif minetest.get_node(mypos).name == "default:water_source" then
							minetest.set_node(pos, {name="default:water_source"})
							minetest.set_node(mypos, {name=plode})
						end
					--end
				end
			end
		end
	})
end

function reg_fall(nodee)
	minetest.register_abm({
		nodenames = {nodee},
		interval = 1,
		chance = 1,
		catch_up = false,
		action = function(pos)
			local plode = minetest.get_node(pos).name
			if minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "air" or minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "default:water_flowing" then
				minetest.set_node(pos, {name="air"})
				minetest.set_node({x=pos.x,y=pos.y-1,z=pos.z}, {name=plode})
			elseif minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "default:water_source" then
				minetest.set_node(pos, {name="default:water_source"})
				minetest.set_node({x=pos.x,y=pos.y-1,z=pos.z}, {name=plode})
			end
		end
	})
end

 -- example use - minetest_game active world - makes mossycobble spread, finite liquids, land erosion, and coral reef growth (add this to example.lua (?) or make this a modpack and have this be example mod (?))
reg_parasite("air", {"default:snow"}, 1) -- erase snow layers, default:snow messes up when combined with the terrain melting function
reg_parasite("default:mossycobble", {"default:cobble"}, 28)
reg_finite_liq("default:water")
reg_finite_liq("default:lava")
reg_finite_liq("default:river_water")
reg_melt("group:soil") --melt soils
reg_melt("group:sand") -- melt sands
reg_melt("default:gravel") --melt gravel
reg_melt("default:snowblock") --melt snowblock
reg_fall("default:cactus") --plants, trees, bushes and flora fall down after terrain melting/erosion
reg_fall("default:papyrus")
reg_fall("group:tree")
--BUSHES
reg_fall("default:bush_leaves")
reg_fall("default:acacia_bush_leaves")
reg_fall("default:pine_bush_leaves")
reg_fall("default:blueberry_bush_leaves")
reg_fall("default:blueberry_bush_leaves_with_berries")
reg_fall("group:flora")
--underwatercorals
reg_plont("default:coral_skeleton", {"default:sand"}, "default:water_source")
reg_plont("default:coral_brown", {"default:sand"}, "default:water_source")
reg_plont("default:coral_orange", {"default:sand"}, "default:water_source")
reg_plont("default:coral_cyan", {"default:sand"}, "default:water_source")
reg_plont("default:coral_green", {"default:sand"}, "default:water_source")
reg_plont("default:coral_pink", {"default:sand"}, "default:water_source")
--reg_plont("default:sand_with_kelp", {"default:sand"}, "default:water_source") --broken :( (*This is because of how kelp is implemented)
