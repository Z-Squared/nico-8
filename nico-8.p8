pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- nico-8
-- by nodocchi

--[[
nico nico nii♥
--]]

-- globals
camera_drag = true

objects = {}
bkgd= {13, 12, 3, 6}

function _init()
 -- set title screen functions as intial game loop
 _draw = title_draw
 _update = title_update
 title_init()
end

----------------
-- title screen!
----------------
function title_init()
 arrow = {
  x = 20,
  y = 30
 }
end

function title_draw()
 cls()
 print(">", arrow.x, arrow.y, 12)

 print("nico-8",0,0,13)

 print("level 1", 30, 30, 13)
 print("level 2", 30, 38, 13)
 print("level 3", 30, 46, 13)
 print("level 4", 30, 54, 13)
 print("camera drag: "..tostr(camera_drag), 30, 62, 13)
end

-- sets the update function to a title screen
function title_update()
 dbg = ""
 if (btn(2) and btn(3)) then
  return
 end

 if btnp(2) then
  if arrow.y == 30 then
   arrow.y = 62
  else
   arrow.y -= 8
  end
 end

 if btnp(3) then
  if arrow.y == 62 then
   arrow.y = 30
  else
   arrow.y += 8
  end
 end

 if btnp(4) then
  if arrow.y == 62 then
   if camera_drag == true then
    camera_drag = false
   else
    camera_drag = true
   end
    return
  end

  if arrow.y == 30 then currentlevel = 0 end
  if arrow.y == 38 then currentlevel = 1 end
  if arrow.y == 46 then currentlevel = 2 end
  if arrow.y == 54 then currentlevel = 3 end

  game_init()
 end
end

-- when the game starts
function game_init()
 t=0

 _update = game_update
 _draw = game_draw

 -- creates an array of the levels
 levels = {}

 for l=0,3 do
  levels[l+1] = {}
  for x=0,127 do
   levels[l+1][x+1] = {}
   for y=0,15 do
    levels[l+1][x+1][y+1] = mget(x,y+(16*l))
   end
  end
 end

 -- sets the play area for level 1 to a level offset stored in array
 for x=0,127 do
   for y=0,15 do
    mset(x,y,levels[currentlevel+1][x+1][y+1])
  end
 end

 -- scans map for nico's sprite
 map_each(function(x,y)
  if mget(x,y) == 1 then
   nico = make_nico(x,y)
   add(objects, nico)
   mset(x,y,0)
  end
 end)

 -- scans map for npc sprite
 map_each(function(x,y)
  if mget(x,y) == 9 or mget(x,y) == 11 or mget(x,y) == 13 then
   local npc = make_npc(x,y, mget(x, y))
   add(objects, npc)
   mset(x,y,0)
  end
 end)

 -- load the solid parts of the map
 map_each(function(x, y)
  if fget(mget(x,y), 1) then
   add(objects, create_object(x, y, mget(x, y)))
   mset(x, y, 0)
  end
 end)

 -- loads the camera
 game_cam = make_cam(nico)
end

-->8
-- constructors + actors

-- camera constructor
function make_cam(target)
 return {
  tar = target,

  cam_y = 0,
  cam_x = 0,

  min_x = 0,
  max_x = 128*8,

  update=function(self)
   self.cam_x = self.tar.x - 60

   if(self.cam_x < self.min_x) then
    self.cam_x = self.min_x
   end
   if(self.cam_x + 128 > self.max_x) then
    self.cam_x = self.max_x - 128
   end
  end,

  value=function(self)
   return self.cam_x, self.cam_y
  end,

  return_x=function(self)
   return self.cam_x
  end,

  return_y=function(self)
   return self.cam_y
  end
 }
end

-- object constructor
function create_object(x, y, sprite)
 return {
  x = x * 8,
  y = y * 8,
  s = sprite,

  obj_type = ({
   [49] = "disc",
   [50] = "bottle",
   [54] = "orb"
   })[sprite],

  hitbox = ({
   [49] = {x = 1, y = 2, w = 5, h = 5},
   [50] = {x = 2, y = 1, w = 3, h = 6},
   [54] = {x = 1, y = 1, w = 6, h = 6}
   })[sprite],

  update=function(self)
   if t%8 == 0 then
    self.y = self.y + 1
   elseif t%4 == 0 then
    self.y = self.y - 1
   end
  end
 }
end

-- nico constructor
-- creates nico based on x and y (which should be found using mget)
function make_nico(x,y)
 return { -- nico-nii
  x = x * 8, -- convert tile value to pixel value
  y = y * 8, -- convert tile value to pixel value
  vx = 0,
  vy = 0,
  s = 1,
  l = false, -- left?
  hitbox = {x = 0, y = 1, w = 7, h = 7},

  -- slow down nico
  slow_down=function(this)
   if this.vx > 0 then this.vx = this.vx - 1
   elseif this.vx < 0 then this.vx = this.vx + 1 end
  end,

  handle_input=function(this)
   this.s = 1

   -- nico nico nii♥
   if (btn(2)) and on_ground() then
    if this.vx == 0 then
     if stat(16) != 1 then
      sfx(1, 0)
     end
    else
     this.slow_down(this)
    end

    return
   end

   -- jump
   if this.jumping and not (btn(4)) and on_ground() then
    this.jumping = false
   end

   if not this.jumping and (btn(4)) and on_ground() then
    this.vy = -8
    this.jumping = true
    sfx(0)
   end

   -- jump acceleration
   if is_ground(nico.x, nico.y - 1) then
    if not btn(4) then
     this.vy = this.vy + 1
    end
   end

   -- both directions means no movement
   if (btn(0) and btn(1)) then
    return
   end

   -- directions
   if (btn(0)) then
    if is_wall(this.x - 1, this.y) == false then
     this.vx=this.vx-2
     this.l=true
     this.s=2+t/4%2
    end
   end
   if (btn(1)) then
    if is_wall(this.x + 7, this.y) == false then
     this.vx=this.vx+2
     this.l=false
     this.s=2+t/4%2
    end
   end
  end,

  update=function(this)
   -- if nico nico nii♥ is playing, prevent other input
   if stat(16) != 1 then
    this.handle_input(this)
   else
    this.s = 4
   end

   this.slow_down(this)

   if this.vx > 5 then this.vx = 5 end
   if this.vx < -5 then this.vx = -5 end

   if not on_ground() then
    this.vy = this.vy + 1
   end

   fx = this.x + this.vx
   fy = this.y + this.vy

   afy = (this.y + fy) / 2
   afx = (this.x + fx) / 2

   if is_ground(fx, afy) or is_ground(fx, fy) then
    for i = this.y,fy do
     if is_ground(this.x, i) then
      this.y = i
      break
     end
    end

    this.vy = 0
   end

   if is_wall(afx, fy) or is_wall(fx, fy) then
    for i = this.x,fx do
     if is_wall(i, this.y) then
      this.x = i
      break
     end
    end

    this.vx = 0
   end

   if this.vy > 15 then
    this.vy = 15
   end

   this.x = this.x + this.vx
   this.y = this.y + this.vy
  end,

  pre_draw=function(this)
   if this.s == 4 then
    this.l = false
    if t%16 > 8 then
     print("nico nico nii♥",this.x-20,this.y-8,14)
    end
   end

   if this.jumping and not on_ground() then
    if this.vy > 0 then
     this.s = 6
    else
     this.s = 5
    end
   end

   palt(11,true)
   palt(0,false)
  end,

  post_draw=function()
   palt(0,true)
   palt(11,false)
  end
 }
end

function make_npc(x, y, sprite)
 return {
  x = x * 8, -- convert tile value to pixel value
  y = y * 8, -- convert tile value to pixel value
  vx = 0,
  vy = 0,
  s = sprite,
  l = false, -- left?
  hitbox = {x = 0, y = 1, w = 7, h = 7},
  name = ({
   [9] = "nozomi",
   [11] = "eli",
   [13] = "maki"
  })[sprite],

  update=function(self)
   if t%8 == 0 then
    self.l = true
   elseif t%4 == 0 then
    self.l = false
   end
  end,

  pre_draw=function(self)
   print(self.name,self.x,self.y-8,14)
  end,
}
end
-->8
-- game update + related
function game_update()
 dbg = ""
 t=t+1

 if t == 32766 then t = 0 end -- lolololololol
 if camera_drag == true then game_cam:update() end

 foreach(objects,function(obj) obj:update() end)

 if camera_drag == false then game_cam:update() end
end

-- check for wall
function is_wall(x, y)
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
-- game draw + related

function game_draw()
 cls()

 camera(game_cam:value())

 -- cooridinate debugging, includes x and y values for nico, camera, and map tiles
 debug("nico.x="..nico.x..", nico.y="..nico.y)
 debug("cam_x="..game_cam:return_x()..", cam_y="..game_cam:return_y())
 debug("tilex="..flr(nico.x / 8)..", tiley="..flr(nico.y / 8)..", solid: "..tostr(is_wall(nico.x,nico.y)))

 local left = nico.l

 draw_level_background()

 map(0,0, 0,0, 128,16)

 -- sprite drawing and dispatching
 foreach(objects, function(s)
  if s.pre_draw then
   s:pre_draw()
  end

  spr(s.s, s.x, s.y, 1, 1, s.l)

  if s.post_draw then
   s:post_draw()
  end
 end)

 nico.l = left

 camera()

 print(dbg,0,0,7)
end

function draw_level_background()
  rectfill(0,0,2480,118,bkgd[currentlevel+1])
end

-->8
-- util + abstractions

-- call me with all of your debug messages!
function debug(msg)
 if dbg != "" then
  dbg = dbg.."\n"
 end

 dbg = dbg..tostr(msg)
end

-- accepts a functions, that will be called with every x and y
-- coordinate in the map
function map_each(callback)
 for y=0,15 do
  for x=0,127 do
   callback(x, y)
  end
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
000000000000000000007700000000000000000000000000000ee000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006670000007000000000000000000000000000000ee7e00000000000000000000000000000000000000000000000000000000000000000000000000
0000000006666700007770000000000000000000000000000eeee7e0000000000000000000000000000000000000000000000000000000000000000000000000
000000000660660000ccc0000000000000000000000000000eeeeee0000000000000000000000000000000000000000000000000000000000000000000000000
000000000766660000ccc00000000000000000000000000000eeee00000000000000000000000000000000000000000000000000000000000000000000000000
000000000076600000ccc000000000000000000000000000000ee000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000001000100000000000000000000000000010000000000000000000000000000000002020000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000031313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000003100000031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001001100090000000b00000d00110020201010100011000032110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101212121212101010101010101010101010101212121212002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201212121212
2020202020202020202020202020202020202020202020202020202020202020002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
2020202020202020202020202020202020202020202020202020202020202020002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
2020202020202020202020202020202020202020202020202020202020202020002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
2020202020202020202020202020202020202020202020202020202020202020002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
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

