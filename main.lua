-- Copyright (c) 2016 Kevin Schluff

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local Delaunay = require "delaunay"

-- Load assets and start main coroutine
function love.load()

    love.window.setMode(0,0, {fullscreen = true})
    love.mouse.setVisible(false)
    
    assets = {}

    assets.beetleship = {}
    assets.beetleship.image = love.graphics.newImage("assets/beetleship.png")
    assets.beetleship.sx = 1/6
    assets.beetleship.sy = 1/6
    assets.beetleship.width = assets.beetleship.image:getWidth() * assets.beetleship.sx
    assets.beetleship.height = assets.beetleship.image:getHeight() * assets.beetleship.sy

    assets.star = {}
    assets.star.image = love.graphics.newImage("assets/star.png")

    assets.planet = {}
    assets.planet.image = love.graphics.newImage("assets/planet.png")
    assets.planet.sx = 1/6
    assets.planet.sy = 1/6
    assets.planet.width = assets.planet.image:getWidth() * assets.planet.sx
    assets.planet.height = assets.planet.image:getHeight() * assets.planet.sy

    assets.circle = {}
    assets.circle.image = love.graphics.newImage("assets/collisioncircle.png")
    assets.circle.sx = 1/3
    assets.circle.sy  = 1/3

    
    assets.background = love.graphics.newImage("assets/background.png")

    assets.title_font = love.graphics.newFont("assets/Space Comics.ttf", 42)
    assets.letter_font = love.graphics.newFont("assets/LiberationMono-Bold.ttf", 20)

    
    clear_scene()

    math.randomseed(os.time()) 
    
    coro = coroutine.create(function() if not pcall(main) then print(debug.traceback()) end end)
    
end

function love.update(dt)
    coroutine.resume(coro, dt)
end

function love.draw()
    if scene.background_image then
	local sx, sy
	sx = love.graphics.getWidth() / scene.background_image:getWidth() 
	sy = love.graphics.getHeight() / scene.background_image:getHeight() 
	love.graphics.draw(scene.background_image, 0, 0, 0, sx, sy)
    else
	love.graphics.setBackgroundColor(scene.bg.r, scene.bg.g, scene.bg.b)
    end

    love.graphics.setColor(128, 128, 0, 128)
    love.graphics.setLineWidth(4)
    for i,edge in ipairs(scene.edges) do
	love.graphics.line(edge[1].x, edge[1].y, edge[2].x, edge[2].y)
    end 
    love.graphics.setColor(255, 255, 255)
    
    for i,sprite in ipairs(scene.sprites) do
	local sx = sprite.sx or 1
	local sy = sprite.sy or 1
	local x = sprite.x - sprite.image:getWidth() * sx / 2
	local y = sprite.y - sprite.image:getHeight() * sy / 2
	
	love.graphics.draw(sprite.image, x, y, sprite.angle or 0, sx or 1, sy or 1)

	if sprite.letter then
	    love.graphics.setFont(assets.letter_font)
	    local letter_width = assets.letter_font:getWidth(sprite.letter)
	    local letter_height = assets.letter_font:getHeight(sprite.letter)
	    love.graphics.setColor(0,0,0)
	    love.graphics.print(sprite.letter, sprite.x - letter_width/2,
				sprite.y - letter_height/2)
	    love.graphics.setColor(255,255,255)
	end

    end

    for i,f in ipairs(scene.callbacks) do
	f()
    end
    
end

function main()
    local level = nil
    
    splash()
    
    local levels = {
	{
	    num = 1,
	    name = "HOME ROW",
	    num_puzzles = 5,
	    keys={"a","s","d","f","g","h","j","k","l"},
	    min_stars = 10,
	    max_stars = 15,
	    cut_scene = function()
	    end
	    
	},
	{
	    num = 2,
	    name = "TOP ROW",
	    num_puzzles = 5,
	    keys={"q", "w", "e", "r", "t", "y", "u", "i", "o", "p"},
	    min_stars = 10,
	    max_stars = 15,
	    cut_scene = function()
	    end
	    
	},
	{
	    num = 3,
	    name = "BOTTOM ROW",
	    num_puzzles = 5,
	    keys={"z", "x", "c", "v", "b", "n", "m"},
	    min_stars = 10,
	    max_stars = 15,
	    cut_scene = function()
	    end
	    
	    
	},
	{
	    num = 4,
	    name = "ALPHABET SOUP",
	    num_puzzles = 5,
	    keys={"a","s","d","f","g","h","j","k","l", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "z", "x", "c", "v", "b", "n", "m"},
	    min_stars = 15,
	    max_stars = 20,
	    cut_scene = function()
	    end
	    
	},
	{
	    num = 5,
	    name = "MIXED CASE",
	    num_puzzles = 5,
	    keys={"a","s","d","f","g","h","j","k","l", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "z", "x", "c", "v", "b", "n", "m",
		  "A","S","D","F","G","H","J","K","L", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Z", "X", "C", "V", "B", "N", "M"},
	    min_stars = 15,
	    max_stars = 20,
	    cut_scene = function()
	    end
	    
	},

	{
	    num = 6,
	    name = "NUMBERS",
	    num_puzzles = 5,
	    keys={"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
	    min_stars = 10,
	    max_stars = 20,
	    cut_scene = function()
	    end
	    
	},
	{
	    num = 7,
	    name = "PUNCTUATION",
	    num_puzzles = 5,
	    keys = {"!", "@", "#", "$", "%", "\\", "&", "*", ".", ";", ":", "?", "/", "+", "-", "="},
	    min_stars = 10,
	    max_stars = 15,
	    cut_scene = function()
	    end
	},
	{
	    num = 8,
	    name = "ALL TOGETHER",
	    num_puzzles = 10,
	    keys={"a","s","d","f","g","h","j","k","l", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "z", "x", "c", "v", "b", "n", "m",
		  "A","S","D","F","G","H","J","K","L", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Z", "X", "C", "V", "B", "N", "M",
		  "!", "@", "#", "$", "%", "\\", "&", "*", ".", ";", ":", "?", "/", "+", "-", "=",
		  "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},	
	    min_stars = 15,
	    max_stars = 25,
	    cut_scene = function()
	    end
	}
    }
    
    start_level = math.min(start_level, #levels)
    print("start_level", start_level)
	
    for l = start_level, #levels do
	level = levels[l]
	intro_screen(level)
	
	for s = 1,level.num_puzzles do
	    puzzle = generate_puzzle(level)
	    play_puzzle(puzzle)	
	end
	cut_scene(level)
    end
    game_over()
    love.event.quit()
end

function splash()    
    scene.callbacks = {}
    scene.callbacks[1] = function()
	love.graphics.setFont(assets.title_font)
	love.graphics.setColor(0, 0, 0)
	text = "STAR BEETLE"
	x =  love.graphics.getWidth()/2 - assets.title_font:getWidth(text)/2 
	y =  love.graphics.getHeight()/5 
	love.graphics.print(text, x, y)
	love.graphics.setColor(255, 255, 255)
    end


    local stars = {}
    for i = 1,10 do
	table.insert(scene.sprites, {
	    image = assets.star.image,
	    x = math.random(love.graphics.getWidth() / 5, love.graphics.getWidth() * 4/5),
	    y = math.random(love.graphics.getHeight() / 5, love.graphics.getHeight() * 4/5),
	})
    end

    table.insert(scene.sprites, {
	image = assets.planet.image,
	x = love.graphics.getWidth() * 3/4,
	y = love.graphics.getHeight() / 3,
	sx = .3,
	sy = .3
    })

    table.insert(scene.sprites, {
	image = assets.beetleship.image,
	x = love.graphics.getWidth() / 2,
	y = love.graphics.getHeight() / 2
    })
    
    
    key = wait_for_key(20, 1)
    -- If a number is pressed, skip to that level
    start_level = tonumber(key) or 1
    
    print("done splash")
end

function intro_screen(level)
    print("intro_screen")
    clear_scene()
    
    scene.callbacks[1] = function()
	love.graphics.setFont(assets.title_font)
	love.graphics.setColor(0, 0, 0)
	text = "LEVEL " .. level.num
	x =  love.graphics.getWidth()/2 - assets.title_font:getWidth(text)/2 
	y =  love.graphics.getHeight()/4 - assets.title_font:getHeight(text)/2 
	love.graphics.print(text, x, y)
	text = "\""..level.name.."\""
	x =  love.graphics.getWidth()/2 - assets.title_font:getWidth(text)/2 
	y =  love.graphics.getHeight()/4 + assets.title_font:getHeight(text)
	love.graphics.print(text, x, y)
	love.graphics.setColor(255, 255, 255)
    end

    
    wait_for_key(10, 0.5)
end

function game_over()    
    scene.callbacks = {}
    scene.callbacks[1] = function()
	love.graphics.setFont(assets.title_font)
	love.graphics.setColor(0, 0, 0)
	text = "GAME OVER"
	x =  love.graphics.getWidth()/2 - assets.title_font:getWidth(text)/2 
	y =  love.graphics.getHeight()/5 
	love.graphics.print(text, x, y)
	love.graphics.setColor(255, 255, 255)
    end


    local stars = {}
    for i = 1,10 do
	table.insert(scene.sprites, {
	    image = assets.star.image,
	    x = math.random(love.graphics.getWidth() / 5, love.graphics.getWidth() * 4/5),
	    y = math.random(love.graphics.getHeight() / 5, love.graphics.getHeight() * 4/5),
	})
    end

    table.insert(scene.sprites, {
	image = assets.planet.image,
	x = love.graphics.getWidth() * 3/4,
	y = love.graphics.getHeight() / 3,
	sx = .3,
	sy = .3
    })

    table.insert(scene.sprites, {
	image = assets.beetleship.image,
	x = love.graphics.getWidth() / 2,
	y = love.graphics.getHeight() / 2
    })
    
    
    key = wait_for_key(20, 1)
    print("game over")
end

function generate_puzzle(level)
    print("generate_puzzle start")
    local puzzle = {}
    puzzle.num_visited = 0
    -- Place player in a random location.
    print("generate player")
    puzzle.player = {}
    puzzle.player.image = assets.beetleship.image
    puzzle.player.x = math.random(assets.beetleship.width,
				  love.graphics.getWidth() - assets.beetleship.width)
    puzzle.player.y = math.random(assets.beetleship.height,
				  love.graphics.getHeight() - assets.beetleship.height)
    puzzle.player.sx = assets.beetleship.sx
    puzzle.player.sy = assets.beetleship.sy
    
    -- Place the planet at a random location.
    print("generate planet")
    puzzle.planet = {}
    puzzle.planet.image = assets.planet.image
    puzzle.planet.x = math.random(assets.planet.width,
				  love.graphics.getWidth() - assets.planet.width)

    puzzle.planet.y = math.random(assets.planet.height,
				  love.graphics.getHeight() - assets.planet.height)
    puzzle.planet.sx = assets.planet.sx
    puzzle.planet.sy = assets.planet.sy

    puzzle.planet.letter = level.keys[math.random(1, #level.keys)]
    puzzle.planet.visited = false
    
    -- Generate stars at random locations. 
    print("generate stars")
    puzzle.stars = {}
    for i=1,math.random(level.min_stars, level.max_stars) do
	puzzle.stars[i] = {}
	puzzle.stars[i].image = assets.star.image
	scale = 1/2
	puzzle.stars[i].sx = scale
	puzzle.stars[i].sy = scale
	puzzle.stars[i].x = math.random(love.graphics.getWidth()/7,
					love.graphics.getWidth() - love.graphics.getWidth()/7)
	puzzle.stars[i].y = math.random(assets.star.image:getHeight() * scale,
					love.graphics.getHeight() - assets.star.image:getHeight() * scale)
	puzzle.stars[1].visited = false
    end

    -- Treat the planet like a star
    table.insert(puzzle.stars, puzzle.planet)
    
    -- Separate sprites by some minimum distance.
    sprites = separate_stars(puzzle.stars)
    
    -- Create a connected graph using Delaunay triangulation.
    -- (Player and planet are nodes too)
    -- Record graph edges and neighbour relationships
    local points = {}
    for i,sprite in ipairs(sprites) do
	sprite.neighbours = {}
	points[i] = Delaunay.Point(sprite.x, sprite.y)
    end
    print "triangulate"

    puzzle.edges = {}
    local triangles = Delaunay.triangulate(unpack(points))
    for i, triangle in ipairs(triangles) do
	local e1p1 = sprites[triangle.e1.p1.id]
	local e1p2 = sprites[triangle.e1.p2.id]

	local e2p1 = sprites[triangle.e2.p1.id]
	local e2p2 = sprites[triangle.e2.p2.id]

	local e3p1 = sprites[triangle.e3.p1.id]
	local e3p2 = sprites[triangle.e3.p2.id]
	
	e1p1.neighbours[e1p2] = e1p2
	e1p2.neighbours[e1p1] = e1p1
		
	e2p1.neighbours[e2p2] = e2p2
	e2p2.neighbours[e2p1] = e2p1

	e3p1.neighbours[e3p2] = e3p2
	e3p2.neighbours[e3p1] = e3p1
	
	table.insert(puzzle.edges, {sprites[triangle.e1.p1.id], sprites[triangle.e1.p2.id]})
	table.insert(puzzle.edges, {sprites[triangle.e2.p1.id], sprites[triangle.e2.p2.id]})
	table.insert(puzzle.edges, {sprites[triangle.e3.p1.id], sprites[triangle.e3.p2.id]})
    end

    scene.edges = puzzle.edges
    

    -- Assign letters to stars
    for i, star in ipairs(puzzle.stars) do
	star.letter = level.keys[math.random(1, #level.keys)]
    end
    coroutine.yield()

    -- Replace any letters where one node has two neighbours
    -- with the same letter.  Call it "cuckoo coloring".
    -- For each node, go through all it's neighbours.
    -- If a neighbour has the same letter as anothe rneighbour,
    -- randomly replace it.  This could cause another conflict,
    -- so iterate until the letters stabilize.  
    MAX_ITERATIONS = 500
    local iterations = 0
    local modified = true
    while modified and iterations < MAX_ITERATIONS do
	iterations = iterations + 1
	modified = false
	for i, star in ipairs(puzzle.stars) do
	    local letter_set = {}
	    for _, neighbour in pairs(star.neighbours) do
		if letter_set[neighbour.letter] then
		    neighbour.letter = level.keys[math.random(1, #level.keys)]
		    modified = true
		end
		letter_set[neighbour.letter] = true
	    end
	end
	coroutine.yield()
    end
    if iterations >= MAX_ITERATIONS then
	print("max iterations for letters reached")
    end
    

    
    print("generate_puzzle end")
    return puzzle
end

function play_puzzle(puzzle)
    print("play_puzzle")

    clear_scene()

    -- Move the player to the first star and mark the star as visited
    puzzle.player.x = puzzle.stars[1].x
    puzzle.player.y = puzzle.stars[1].y
    local current_star = puzzle.stars[1]

    keys = map_neighbour_keys(current_star)

    print("play_puzzle loop")
    while true do

	if next(keys) == nil then
	    -- no moves left, end the puzzle
	    puzzle_failed()
	    break
	end
	
	if any_key_pressed then
	    next_star = keys[letter_pressed]
	    if next_star then
		current_star.visited = true
		puzzle.num_visited = puzzle.num_visited + 1
		current_star = move_player(next_star)
		if current_star == puzzle.planet then
		    puzzle_complete(puzzle)
		    break
		end
		keys = map_neighbour_keys(current_star)
	    end
	    -- Ensure the key is released, so we don't
	    -- skip ahead to another star with the same
	    -- letter.
	    while any_key_pressed do
		coroutine.yield()
	    end
	end
	
	scene.sprites = {}
	for _,star in ipairs(puzzle.stars) do
	    if not star.visited and star ~= current_star then
		table.insert(scene.sprites, star)
	    end
	end
	table.insert(scene.sprites, puzzle.player)
	
	-- The circle hints make it too easy.  The player should make some mistakes once in a while
	-- Maybe make this optional for younger players.
	-- for _, neighbour in pairs(current_star.neighbours) do
	--     if not neighbour.visited and neighbour ~= puzzle.planet then
	-- 	local circle = {}
	-- 	circle.image = assets.circle.image
	-- 	circle.x = neighbour.x
	-- 	circle.y = neighbour.y
	-- 	circle.sx = assets.circle.sx
	-- 	circle.sy = assets.circle.sy
	-- 	table.insert(scene.sprites, circle)
	--     end
	-- end

	scene.edges = {}
	for _, edge in ipairs(puzzle.edges) do
	    table.insert(scene.edges, edge)
	end
	
	coroutine.yield()
    end
    
end

function map_neighbour_keys(star)
    print("map neighbour keys")
    local keys = {}
    for _,neighbour in pairs(star.neighbours) do
	-- Get all the valid keys for this round
--	print(neighbour.letter)
	if not neighbour.visited then
	    keys[neighbour.letter] = neighbour
	end
    end
    return keys
end

function move_player(next_star)
    puzzle.player.x = next_star.x
    puzzle.player.y = next_star.y
    return next_star
end

function puzzle_failed()
    print("No moves left")

    scene.callbacks[1] = function()
	love.graphics.setFont(assets.title_font)
	love.graphics.setColor(0, 0, 0)
	text = "SORRY, TRY AGAIN"
	x =  love.graphics.getWidth()/2 - assets.title_font:getWidth(text)/2 
	y =  love.graphics.getHeight()/4 - assets.title_font:getHeight(text)/2 
	love.graphics.print(text, x, y)
	love.graphics.setColor(255, 255, 255)
    end

    wait_for_key(3, 0.5)
    -- TODO Replay or quit
end

function puzzle_complete(puzzle)
    print("Puzzle Complete")
    local num_stars = #puzzle.stars - 1 -- Don't count the planet
    local num_visited = puzzle.num_visited
    local score

    if num_visited == num_stars then
	score = 3
    elseif num_stars - num_visited < (num_stars / 5) then
	score = 2
    else
	score = 1
    end

    for i=1,score do
	table.insert(scene.sprites, {
			 image = assets.star.image,
			 x = (love.graphics.getWidth() - 3 * assets.star.image:getWidth() * 1.5)/2 + i * assets.star.image:getWidth(),
			 y = (love.graphics.getHeight() - assets.star.image:getHeight() * 1.5)/2,
			 sx = 1.5,
			 sy = 1.5
	})
    end

    wait_for_key(3, 0.5)

    -- TODO Next or Quit
end

function cut_scene(level)
    print("cut_scene level " .. level.num)
    clear_scene()
    scene.callbacks[1] = function()
	love.graphics.setFont(assets.title_font)
	love.graphics.setColor(0, 0, 0)
	text = "LEVEL " .. level.num .. " COMPLETE"
	x =  love.graphics.getWidth()/2 - assets.title_font:getWidth(text)/2 
	y =  love.graphics.getHeight()/5 - assets.title_font:getHeight(text)/2 
	love.graphics.print(text, x, y)
	love.graphics.setColor(255, 255, 255)
    end
    
    scene.callbacks[2] = level.cut_scene

    wait_for_key(10, 1)
end

function pause_screen()
    local saved_scene = scene
    clear_scene()

    scene.sprites[1] = {
	image = assets.exit.image,
	x = love.graphics.getWidth() / 4,
	y = love.graphics.getHeight() / 2 - assets.exit.image:getHeight() * assets.exit.sy / 2,
	sx = assets.exit.sx,
	sy = assets.exit.sy
    }

    scene.sprites[2] = {
	image = assets.play.image,
	x = love.graphics.getWidth() * 3 / 4,
	y = love.graphics.getHeight() / 2 - assets.play.image:getHeight() * assets.play.sy / 2,
	sx = assets.play.sx,
	sy = assets.play.sy
    }

    wait_for_key(100, 2)
    love.event.quit()
end


function love.textinput(t)
--    print("textinput", t)
    letter_pressed = t
end

function love.keypressed(key, scancode, is_repeat)
    if not any_key_pressed then
	if key == "escape" then
	    love.event.quit()
	elseif key == "lshift" or key == "rshift" then
	    return
	end
    
	any_key_pressed = true
	key_pressed = key
    end
end

function love.keyreleased(key, scancode)
    any_key_pressed = false
    key_pressed = nil
--    print("key released", key)
end

function clear_scene()
    scene = {}
    scene.bg = {r=0, g=0, b=0}
    scene.sprites = {}
    scene.callbacks = {}
    scene.edges = {}
    scene.background_image = assets.background
end

-- Find the minimum amount to move
-- each sprite alongto avoid
-- it overlapping the collision circle
-- of another.
function separate_stars(stars)

    print "separate_stars"
    clear_scene()

    for i, star in ipairs(stars) do
	table.insert(scene.sprites, star)
    end
    
    MIN_SEPARATION = 100 
    
    local moved = true
    while moved do
	-- Run until no sprites need to be moved
	moved = false
	
	for i,sprite in ipairs(scene.sprites) do
	    local overlap_magnitude = 0
	    local overlap_angle = 0
	    local overlapped_index = 0
	    for j,other in ipairs(scene.sprites) do
		if sprite ~= other then

		    local dx = other.x - sprite.x
		    local dy = other.y - sprite.y
		    local dist = math.sqrt(dx*dx + dy*dy)
		    local angle = math.atan2(dy,dx)
		    
		    if (MIN_SEPARATION - dist) > 1 then
			moved = true
			local new_overlap = MIN_SEPARATION - dist
			-- If this is the first overlap, or it is smaller than the
			-- previous overlap, keep it as the minimum overlap.
			if overlap_magnitude == 0 or new_overlap < overlap_magnitude then
			    overlap_magnitude = new_overlap
			    overlap_angle = math.atan2(dy, dx)
			    overlapped_index = j
			end
		    end
		end
	    end
	    -- Nudge the sprite by the minimum overlap.  Clip to screen bordered
	    -- by MIN_SEPARATION.
	    sprite.x = sprite.x - overlap_magnitude * math.cos(overlap_angle)
	    sprite.x = math.max(sprite.x, MIN_SEPARATION/2)
	    sprite.x = math.min(sprite.x, love.graphics.getWidth() - MIN_SEPARATION/2)
	    
	    sprite.y = sprite.y - overlap_magnitude * math.sin(overlap_angle)
	    sprite.y = math.max(sprite.y, MIN_SEPARATION/2)
	    sprite.y = math.min(sprite.y, love.graphics.getHeight() - MIN_SEPARATION/2)

	    -- Show the new sprite positions
	    coroutine.yield()
--	    love.timer.sleep(0.5)
	end	    
    end

    return scene.sprites
end

function wait_for_key(timeout, mandatory_wait)
    mandatory_wait = mandatory_wait or 0
    local remaining = timeout or 0
    while remaining > 0 do
	local dt = coroutine.yield()
	remaining = remaining - dt
	if any_key_pressed and remaining <= (timeout - mandatory_wait) then
	    return key_pressed
	end
    end
end
