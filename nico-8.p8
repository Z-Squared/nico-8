pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- nico-8
-- by nodocchi

--[[
nico nico nii♥
--]]

export_levels = false

function _init()
-- creates array from map
 levels = create_level_array()

 arrow = {
  x = 20,
  y = 30
 }

 if export_levels == true then
  printh("level 1", "level1.txt", true)
  printh("level 2", "level2.txt", true)
  printh("level 3", "level3.txt", true)
  printh("level 4", "level4.txt", true)
  
  for l=1,4 do
   for x=1,128 do
    for y=1,16 do
     printh("cell "..(x-1)..","..(y-1).."="..levels[l][x][y], "level"..l..".txt")
    end
   end
  end
 end

 dbg = ""

 is_titlescreen = true

 if is_titlescreen == false then
  game_init()
 end
end

function game_init()
 t=0

 create_map(currentlevel)

-- scans map for nico's sprite
 for y=0,15 do
  for x=0,127 do
   if (mget(x,y) == 1) then
    nico = make_nico(x,y)
    mset(x,y,0)
   end
  end
 end
end

function titlescreen()
 cls()

 print(">", arrow.x, arrow.y, 12)

 print("nico-8",0,0,13)

 print("level 1", 30, 30, 13)
 print("level 2", 30, 38, 13)
 print("level 3", 30, 46, 13)
 print("level 4", 30, 54, 13)

 menu_input()
end

function menu_input()
 
 if (btn(2) and btn(3)) then
  return
 end

 if btnp(2) then
  if arrow.y == 30 then
   arrow.y = 54
  else
   arrow.y -= 8
  end
 end

 if btnp(3) then
  if arrow.y == 54 then
   arrow.y = 30
  else
   arrow.y += 8
  end
 end

 if btn(4) then
  if arrow.y == 30 then currentlevel = 0 end
  if arrow.y == 38 then currentlevel = 1 end
  if arrow.y == 46 then currentlevel = 2 end
  if arrow.y == 54 then currentlevel = 3 end

  is_titlescreen = false

  game_init()
 end

end

-- creates nico based on x and y which should be found using mget
function make_nico(x,y)
 local n = {} -- nico-nii
  n.x = x * 8 -- convert tile value to pixel value
  n.y = y * 8 -- convert tile value to pixel value
  n.vx = 0
  n.vy = 0
  n.s = 1
  n.l = false -- left?

 return n
end

-- creates an array of the levels
function create_level_array(level_offset)
 local level = {}

 for x=0,127 do
  level[x+1] = {}
   for y=0,15 do
    level[x+1][y+1] = mget(x,y+(16*level_offset))
  end
 end

 return level
end

-- sets the play area for level 1 to levels stored in array
function create_map(level_offset)
 for x=0,127 do
   for y=0,15 do
    mset(x,y,levels[level_offset+1][x+1][y+1])
  end
 end
end

-- call me with all of your debug messages!
function debug(msg)
 if dbg != "" then
  dbg = dbg.."\n"
 end

 dbg = dbg..tostr(msg)
end
-->8
-- update + related

function _update()
 if is_titlescreen == true then
  titlescreen()
 else
  game_update()
 end
end

function game_update()
 t=t+1
 dbg = ""

 if t == 32766 then t = 0 end -- lolololololol

 -- if nico nico nii♥ is playing, prevent other input
 if stat(16) != 1 then
  handle_input()
 else
  nico.s = 4
 end

 brake()

 if nico.vx > 5 then nico.vx = 5 end
 if nico.vx < -5 then nico.vx = -5 end

 if not on_ground() then
  nico.vy = nico.vy + 1
 end

 fx = nico.x + nico.vx
 fy = nico.y + nico.vy

 afy = (nico.y + fy) / 2
 afx = (nico.x + fx) / 2

 if is_ground(fx, afy) or is_ground(fx, fy) then
  for i = nico.y,fy do
   if is_ground(nico.x, i) then
    nico.y = i
    break
   end
  end

  nico.vy = 0
 end

 if solid(afx, fy) or solid(fx, fy) then
  for i = nico.x,fx do
   if solid(i, nico.y) then
    nico.x = i
    break
   end
  end

  nico.vx = 0
 end

 if nico.vy > 15 then
  nico.vy = 15
 end

 nico.x = nico.x + nico.vx
 nico.y = nico.y + nico.vy

 if nico.x < 0 then nico.x = 0 end
end

-- all button press stuff should be handled here
function handle_input()
 nico.s = 1

 -- nico nico nii♥
 if (btn(2)) and on_ground() then
  if nico.vx == 0 then
   if stat(16) != 1 then
    sfx(1, 0)
   end
  else
   brake()
  end

  return
 end

 -- jump
 if nico.jumping and not (btn(4)) and on_ground() then
  nico.jumping = false
 end

 if not nico.jumping and (btn(4)) and on_ground() then
  nico.vy = -8
  nico.jumping = true
  sfx(0)
 end

 -- jump acceleration
 if is_ground(nico.x, nico.y - 1) then
  if not btn(4) then
   nico.vy = nico.vy + 1
  end
 end

 -- both directions means no movement
 if (btn(0) and btn(1)) then
  return
 end

 -- directions
 if (btn(0)) then
  if solid(nico.x - 1, nico.y) == false then
   nico.vx=nico.vx-2
   nico.l=true
   nico.s=2+t/4%2
  end
 end
 if (btn(1)) then
  if solid(nico.x + 7, nico.y) == false then
   nico.vx=nico.vx+2
   nico.l=false
   nico.s=2+t/4%2
  end
 end

end

-- slow down nico
function brake()
 if nico.vx > 0 then nico.vx = nico.vx - 1 end
 if nico.vx < 0 then nico.vx = nico.vx + 1 end
end

-- check for solid blocks
function solid(x, y)
 if (x < 0 or x >= 1024 ) then
  return true end

 return fget(mget(flr(x / 8), flr(y / 8)), 0)
end

function is_blocking(x, y)
 return fget(mget(x / 8, y / 8 + 1), 0)
end

-- is nico on the ground?
function on_ground()
 return is_ground(nico.x, nico.y)
end

function is_ground(x, y)
 return is_blocking(x + 1, y)
  or is_blocking(x + 7, y)
end
-->8
-- draw + related

function _draw()
 if is_titlescreen == false then
  game_draw()
 end
end

function game_draw()
 cls()

 cam_x, cam_y = 0, 0

 if nico.x < 60 then
  cam_x = 0
 elseif nico.x > 263 then
  cam_x = 204
 else
  cam_x = nico.x-60
 end

 camera(cam_x, cam_y)

-- debug some value here
-- if nico.vy >= 15 then
--  print("waahhhhh!!",0+cam_x,0,7)
-- end

 -- cooridinate debugging, includes x and y values for nico, camera, and map tiles
 debug("nico.x="..nico.x..", nico.y="..nico.y)
 debug("cam_x="..cam_x..", cam_y="..cam_y)
 debug("tilex="..flr(nico.x / 8)..", tiley="..flr(nico.y / 8)..", solid: "..tostr(solid(nico.x,nico.y)))

 local left = nico.l

 draw_level_background()

 palt(0,true)
 palt(11,false)
 map(0,0, 0,0, 120,20)
 palt(11,true)
 palt(0,false)

 if nico.s == 4 then
  nico.l = false
  if t%16 > 8 then
   print("nico nico nii♥",nico.x-20,nico.y-8,14)
  end
 end

 if nico.jumping and not on_ground() then
  if nico.vy > 0 then
   nico.s = 6
  else
   nico.s = 5
  end
 end

 drawsprite(nico)

 nico.l = left

 camera()

 print(dbg,0,0,7)
end

function drawsprite(s) -- this is cool
 spr(s.s, s.x, s.y, 1, 1, s.l)
end

function draw_level_background()
 if currentlevel == 0 then
  rectfill(0,0,248,118,13)
 elseif currentlevel == 1 then
  rectfill(0,0,248,118,12)
 elseif currentlevel == 2 then
  rectfill(0,0,248,118,11)
 elseif currentlevel == 3 then
  rectfill(0,0,248,118,10)
 end
end

__gfx__
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb80000bbb00b0bbb000000000000000000000000000000000000000000000000000000000000000000000000
00000000b80000bbb80000bbb80000bbb80008bb0800f00bb80000bb0000000000000000022222000000000007aaaa0000000000088888000000000000000000
007007000800f00b0800f00b0800f00b8000f08b00f2f20b0800f00b00000000000000002222f22000000000a7aafaa000000000888ff8800000000000000000
0007700000f2f20b00f2f20b00f2f20b072f270b00ffff0b00f2f00b000000000000000022f3f32000000000aafcfca00000000088f2f2800000000000000000
0007700000ffff0b00ffff0b00ffff0b0efffe0bb0eeebbbb0ffffbb000000000000000022ffff2000000000aaffffa00000000088ffff800000000000000000
00700700b0eeebbbb0eeebbbb0eee7bbb0eeebbbb7ccc7bbb7eee7bb00000000000000000211120000000000a011100000000000081118000000000000000000
00000000b7ccc7bbb7ccc1bbb1cccbbbbbcccbbbb1b1bbbbbbcccbbb000000000000000007ccc7000000000007ccc7000000000007ccc7000000000000000000
00000000bb1b1bbbbb1bbbbbbbbb1bbbbb1b1bbbbbbbbbbbbb1bb1bb000000000000000000101000000000000010100000000000001010000000000000000000
3333b3b3000000006666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b33b3333000000006666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4445444400000b004445444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544454b0000b004545455400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545403b0b0004444454400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44445444003b33b04454444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44554455000330004544554400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000300004444445400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44454554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45544454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45444544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44454445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100d000101100001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000001000100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010011000009000b000d000000110020201010100011000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101212121212101010101010101010101010101212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d57023570305703d5503f5203a300380002b00032000350003700038000390003a0003a0003a00039000390003700031000280001d00017000100000c000080000600003000020003c0003c0003c000
01110000287701d73009700287701d730097002a7502a7402a7400970001700016000250002500025000150001500015000000000000000000000000000000000000000000000000000000000000000000000000
00100000030000100003000030000a0000a0000800001000010000a000000000a0000a0000a000010000300003000080000a0000a0000a000080000800001000030000a00008000030000a000000000000000000
__music__
00 40424344

