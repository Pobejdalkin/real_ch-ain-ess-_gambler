pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--game about chess gambling!
--roflanebalo

function _init()
		--variables
		buttons={}
		active_button=nil
		scene="intro"
		menustatusr=0
		menucheckedr=0
		turn={num=0,dig=0}
		active_tile={x=-1,y=-1}
		win_tiles_number=9
		win_tiles={{0,0}}
		dead_tiles={}
		--mooooves
		player_pos={xg=4,yg=5}
		avaliable_moves={num=4,dig=0}
		avaliable_rolls=1
		queen_moves=1
		bishop_moves=1
		knight_moves=1
		rook_moves=1
		dead_board=nil
		win_counter=win_tiles_number-1
		--figures offsets
		king_offset={
		{-1,-1},{0,-1},{1,-1},
		{1,0},{1,1},{0,1},
		{-1,1},{-1,0}
		}
		knight_offset={{-1,-2},{-2,-1},{1,-2},{2,-1},{2,1},{1,2},{-1,2},{-2,1}}
		rook_offset={{-1,0},{0,-1},{1,0},{0,1}}
		bishop_offset={{-1,-1},{1,1},{1,-1},{-1,1}}
		
		--functions
		poke( 0x5f2d, 0x1 | 0x2)
		grid_generate()
	 palt(0,false)
	 palt(14,true)
		moveboard=grid_moves_generate()
		generate_win_tiles(win_tiles_number)
end
-->8
--game state machine

function _update60()
	if scene=="intro" then
		update_intro() 
	elseif	scene=="main_menu" then
		update_main_menu()
	elseif scene=="game" 	then
		update_game()
	elseif scene=="bluescreen" then
		update_bluescreen()
	elseif scene=="win" then
		update_win()
	end
end


function _draw()
--scenes
 if scene=="intro" then
 	draw_intro()
 elseif scene=="main_menu" then
 	draw_main_menu()
 elseif scene=="game" then
		draw_game()	
	elseif scene=="bluescreen" then
		draw_bluescreen()
	elseif scene=="win" then
		draw_win()
	end
	
	--mouse draw
	spr(00,stat(32),stat(33))
--mouse coords otladka
--	color(8)
--	print("x:"..
--	stat(32)..
--	" y:"..
--	stat(33),
--	stat(32),stat(33)-8)
end
-->8
-- intro
function update_intro()
	if btnp(5) then
		sfx(2)
		scene="main_menu"
		add(buttons,create_button
		("pLAY!",7,92,22,8,start_game,0))
		add(buttons,create_button
		("bLERP",7,104,22,8,blerp,0))
		add(buttons,create_button
		("eXIT",7,116,18,8,exit,0))
	end
end

function draw_intro()
 cls()
 
 print("press mouse",44,60)
 print("for start",44,66)
end
-->8
--menu 

function update_main_menu()

active_button=check_button(stat(32),stat(33))
	if btnp(❎) and active_button != nil then
		active_button.funct()
	end
end

function draw_main_menu()
	cls()
	color(8)
	print("let's go...",7,10)
	gamblin()
	draw_buttons()
end


-->8
--update game functions
function update_game()
	menuman(stat(32),stat(33))
	check_active_tile(stat(32),stat(33))
	if menustatusr ==1 then
		active_button=check_button(stat(32),stat(33))
		if btnp(❎) and active_button != nil then
			active_button.funct()
		end
	end
	if menustatusr==0 and
				btnp(❎) then
		move_click()
		update_moveboard()
	end
end







-->8
--draw game functions
function draw_game()
 cls()
 grid_draw()
	player_draw()
	draw_hints()
	draw_♥()
	if menustatusr==1 then
		draw_r_menu()
		draw_buttons()
	end
	
end
	

-->8
--lib

--side bar draw
function draw_r_menu()
	--tab background
	fillp(292)
	rectfill(95,0,127,127,0x1d)
	fillp(0)
	rect(95,0,127,127,1)
 --indicators
	print("turn:"..turn.num,
	71-turn.dig*4,14,1)
--	print("moves:"..avaliable_moves.num,
--	67-avaliable_moves.dig*4,20,1)
--	spr(1,59-avaliable_moves.dig*4,19)
	print("⧗",63-turn.dig*4,14,10)
 --move indicators
 rectfill(97,73,125,81,13)
	spr(83,98,74)
	rect(97,73,125,81,1)
	print("x"..queen_moves,106,75,1)
	
	rectfill(97,84,125,92,13)
	spr(67,98,85)
	rect(97,84,125,92,1)
	print("x"..rook_moves,106,86,1)
	
	rectfill(97,95,125,103,13)
	spr(66,98,96)
	rect(97,95,125,103,1)
	print("x"..knight_moves,106,97,1)
	
	rectfill(97,106,125,114,13)
	spr(82,98,107)
	rect(97,106,125,114,1)
	print("x"..bishop_moves,106,108,1)
	
end

--side bar status
function menuman(mx,my)
	if mx>120 and menustatusr==0 then
		menustatusr=1
		menucheckedr=1
	end
	if mx<95 and menustatusr==1 then
		menustatusr=0
	end
end

--draw hints
function draw_hints()
	if menucheckedr == 0 then
			spr(2,118,52)	
	end
end

function gamblin()
	local colorz = {14,13,12,11,10,9,8,7}
	local sprites = {16,18,20,22,24,26,28,16}
	for coli = 1,#colorz do --each color
		for i=1,#sprites do --each letter
			t1 = t()*35 + i*3 - colorz[coli]*4
			-- position
			x =-8+i*15 +cos(t1/90)*8
			y =33+(colorz[coli]*1.2-7)+sin(t1/45)*5
			pal(7,colorz[coli])
			spr(sprites[i], x, y,2,2)
		end
 end
end

function grid_generate()
	chessboard = {}
		for x = 1,8 do 
			chessboard[x] = {}
	 	for y = 1,8 do
	 		chessboard[x][y] = (x+y) % 2
	 		--white - 0
	 		--black - 1
	 	end
		end
end

function grid_draw()
	for x=1,8 do
		for y=1,8 do
			local col = 0
			local wintile={x,y}
			if active_tile.x == x and
						active_tile.y == y then
						col = 9
			elseif win_tile_status(wintile) then
				col = 3 
			elseif chessboard[x][y]==0
					then col = 6
					else col = 13
			end
			rectfill(x*16-16,y*16-16,
												x*16,y*16,col)
			if moveboard[x][y]==1 then
				mark_tile(x,y)
	  end
	  if dead_board!=nil and dead_board[x][y] == 1 then
	   mark_deathtile(x,y)
	  end
		end
	end
	if avaliable_moves.num <1 then
		death_render()
	end
end

function check_active_tile(x,y)
	local xg=ceil(x/16)
	local yg=ceil(y/16)
	active_tile.x=xg
	active_tile.y=yg
end

function grid_to_pixels(xg,yg)
	local x=xg*16-16
	local y=yg*16-16
 return {x=x,y=y}
end

function player_draw()
	local xg=player_pos.xg
	local	yg=player_pos.yg
	local pixelpos
	pixelpos=grid_to_pixels(xg,yg)
	spr(64,pixelpos.x,pixelpos.y,2,2)
end

function update_moveboard()
 moveboard=grid_moves_generate()
	if avaliable_moves.num>0 then
		local x=player_pos.xg
		local y=player_pos.yg
		      moveboard=figure_move(x,y,king_offset,1)
								if queen_moves>0 then
									merge_boards(moveboard,
									figure_move(x,y,king_offset,8))
								end
								if knight_moves>0 then
									merge_boards(moveboard,
									figure_move(x,y,knight_offset,1))
								end
								if bishop_moves>0 then
									merge_boards(moveboard,
									figure_move(x,y,bishop_offset,8))
								end
								if rook_moves>0 then
									merge_boards(moveboard,
									figure_move(x,y,rook_offset,8))
								end
		if dead_board!=nil then					
			compare_boards(moveboard,dead_board)
		end	
	end
end

function grid_moves_generate()
	local moveboard = {}
		for x = 1,8 do 
			moveboard[x] = {}
	 	for y = 1,8 do
	 		moveboard[x][y] = 0
	 	end
		end
		return moveboard
end

function move_event(number)

	if number>=1 then
		sfx(5) 
	elseif number==-1 then
		sfx(4)
	elseif number<1 then
		sfx(0)
	else stop("error in move event number 0")
	end
	
	avaliable_moves.num+=number
	local movenum=avaliable_moves.num
	local dig=0
	while movenum>=10 do
		movenum/=10
		dig+=1
	end
	avaliable_moves.dig=dig
	if avaliable_moves.num == 0 then
		sfx(7)
	 death_time=t()
	 buttons={}
	 add(buttons,create_button
	("to main menu",40,92,48,8,return_to_main,0))
	end
end

function move_click()
	if avaliable_moves.num==0 then
		death()
	end
	if dead_board!=nil and dead_board[active_tile.x][active_tile.y]==1 then
	 sfx(8)
	elseif moveboard[active_tile.x][active_tile.y]==0 then
		sfx(3)
	else
		local win_tile_status_check={active_tile.x,active_tile.y}		
		if win_tile_status(win_tile_status_check) then
			win_counter-=1
			if win_counter==0 then
				scene="win"
				sfx(10)
				return
			end
		end
		move_event(-1)
		what_figure_move(player_pos.xg,player_pos.yg,active_tile.x,active_tile.y)
		local deadtile={player_pos.xg,player_pos.yg}
		add(dead_tiles,deadtile)
		dead_board=board_from_tiles(dead_tiles)
		player_pos.xg=active_tile.x
		player_pos.yg=active_tile.y
	end
end

function death()
	scene="bluescreen"
end

function draw_♥()
	for i=0,avaliable_moves.num-1 do
		spr(1,i%8*8+3,1+flr(i/8)*3)
	end
	if avaliable_moves.num-1<1 then	
		print("last move to win!",3,10,8)
	end
end

function what_figure_move(x,y,x1,y1)
	local xo = x - x1
	local yo = y - y1
	if abs(xo)<=1 and abs(yo)<=1 then
		--kingmove
		return
	end
	local _rook = (xo==0 or yo==0)
	if _rook and rook_moves>0 then
		rook_moves-=1
		return
	end
	local _bishop = abs(xo)==abs(yo)
	if _bishop and bishop_moves>0 then
		bishop_moves-=1
		return
	end
	if (_bishop or _rook) and queen_moves>0 then
		queen_moves-=1
		return
	end
	knight_moves-=1
end

function generate_win_tiles(number)
	while #win_tiles<number do
		local wintile={flr(1+rnd(8)),flr(1+rnd(8))}
			if not win_tile_status(wintile) then
		 	add(win_tiles,wintile)
		 end
	end
end

function mark_tile(x,y)
	fillp(0b0011001111001100)
				rect(x*16-15,y*16-15,
													x*16-2,y*16-2,0x86)
				fillp(0)
end

function win_tile_status(wintile)
		for x in all(win_tiles) do
			if	wintile[1] == x[1] and
						wintile[2] == x[2] then
						return true
			end
		end
		return false
end


function mark_deathtile(x,y)
	local xg = x
	local yg = y
	local coords=grid_to_pixels(xg,yg)
	spr(30,coords.x,coords.y,2,2)
end	

function dead_tile_status(dedt)
		for x in all(dead_tiles) do
			if	dedt[1] == x[1] and
						dedt[2] == x[2] then
						return true
			end
		end
		return false
end
-->8
--button lib

--button actions
function start_game()
	buttons={}
	sfx(2)
	scene="game"
	update_moveboard()
	add(buttons,create_button
		("⧗+♥ ",97,117,28,8,make_turn,1))
	add(buttons,create_button
		("die",96,1,30,8,surrender,1))			
end

function exit()
	cls()
	color(8)
	stop("bye")
end
function blerp()
 sfx(0)
 sfx(1)
end

function make_turn()
	if avaliable_moves.num==0 then
		death()
	end
	move_event(1)
 sfx(6)
 for number=1,3 do		
 local ded = #dead_tiles
 local out_of_space = 0
	while #dead_tiles<ded+number do
		if out_of_space >250 then
					out_of_space = 0
					number-=1
		end
		local dietile={flr(1+rnd(8)),flr(1+rnd(8))}
			if not dead_tile_status(dietile) and
			   not win_tile_status(dietile) then
		 	add(dead_tiles,dietile)
		 else out_of_space+=1
		 end
		end		
	
 end
 update_moveboard()
 dead_board=board_from_tiles(dead_tiles)
	turn.num+=1
	local turnnum=turn.num
	local dig=0
	while turnnum>=10 do
		turnnum/=10
		dig+=1
	end
		turn.dig= dig
end

function surrender()
	sfx(7)
	death_time=t()
	buttons={}
	add(buttons,create_button
	("to main menu",40,92,48,8,return_to_main,0))
	avaliable_moves.num=0
end

function return_to_main()
	_init()
	sfx(2)
	scene="main_menu"
	buttons={}
	add(buttons,create_button
	("pLAY!",7,92,22,8,start_game,0))
	add(buttons,create_button
	("bLERP",7,104,22,8,blerp,0))
	add(buttons,create_button
	("eXIT",7,116,18,8,exit,0))
end
---------------------------
-- main button functions
function check_button(x,y)
	for button in all(buttons) do
		if x>=button.x and y>=button.y and
					x<button.x+button.width and
					y<button.y+button.height then	
					 if active_button!= button then
					 	sfx(4)
					 end
			return button
		end
	end
	return nil	
end

function draw_button(button)
	local x,y = button.x,button.y
	local height,width,str = button.height,button.width,button.str
	local col = 6
	if button == active_button then
		col = 8
		colrf = 10
		colr  = 9
	end
 if button.box==1 then
 	rectfill(x,y,x+width,y+height,colrf)
 	rect(x,y,x+width,y+height,colr)
 end
 print(str,x+width/2-#str*2,y+height/2-2,col)
end

function draw_buttons()
	for x in all(buttons) do
		draw_button(x)
	end
end

function create_button(str,x,y,width,height,funct,box)
	return{str=str,x=x,y=y,width=width,height=height,funct=funct,box=box}
end
-->8
--bluescreen
--ta ta dam u are dead x_x

function update_bluescreen()
	active_button=check_button(stat(32),stat(33))
		if btnp(❎) and active_button != nil then
			active_button.funct()
		end
end
	
function draw_bluescreen()
	cls(12)
	print ("unfortunately,you are died",12,21,7)
	print ("there will be statistics",15,31,7)
	print ("...",58,48,7)
	print ("...",58,58,7)
	print ("...",58,68,7)
	draw_buttons()
end


function death_render()
		cls(0)
		local pixelpos
		local k = (t()-death_time)
		local kkk=k*k*k*k*k*k*10
	 pixelpos=grid_to_pixels(player_pos.xg,player_pos.yg)
		circfill(pixelpos.x+8,pixelpos.y+8,kkk,8)
		print ("unfortunately,you are died",12,21,0)
		if kkk> 32000 then
			scene="bluescreen"
		end
end
-->8
-- figure rules

function figure_move(x,y,offsets,distance)
	local moves=grid_moves_generate()
 for offset in all(offsets) do
 	for l=1,distance do
 		local xo = x + offset[1]*l
 		local yo = y + offset[2]*l
 		if within_board(xo,yo) then
 			moves[xo][yo]=1
 		end
 	end
 end
 return moves
end

function within_board(x,y)	
	return x>=1 and x <=8
				and y>=1 and y <=8
end

function merge_boards(b1,b2)
	for x,row in ipairs(b1) do
		for y,_ in ipairs(row) do
			b1[x][y] |= b2[x][y]
		end
	end
end

function compare_boards(b1,b2)
	for x,row in ipairs(b1) do
		for y,_ in ipairs(row) do
		if	b2[x][y] == 0 and
					b1[x][y] == 1 then
					b1[x][y] = 1
		else 
					b1[x][y] = 0
		end
		end
	end
end

function board_from_tiles(tiles)
	local board = {}
		for x=1,8 do
			board[x] = {}
			for y=1,8 do
				board[x][y] = 0
			end
		end
		for tile in all(tiles) do
			for x=1,8 do
				for y=1,8 do
					if x==tile[1] and y==tile[2] then
						board[x][y] = 1
					end
				end
			end
		end
		return board	
end

function board_inverse(board)
	for x=1,8 do
		for y=1,8 do
			if board[x][y] == 1 then
						board[x][y] = 0
			elseif
						board[x][y] == 0 then
						board[x][y] = 1
			end
		end
	end
end
-->8
--winscene

function update_win()
 
end

function draw_win()
	cls(11)
	print("you are win!",40,64,7)
end
__gfx__
78eeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
778eeeeee11e11eeeeee8eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7778eeee1881881eeeee88ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77778eee1888881e8888888e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777878eee18881ee8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7878eeeeee181eee8888888e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8e878eeeeee1eeeeeeee88ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee88eeeeeeeeeeeeeee8eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000eeee0000000000eeeeee00000ee00000eeee000000000000eeeeee000000000eeeee00000e00000eeeee00000e00000eeeee11eeeeeeeeeeee11
077777777770eeee07777777700eeeee07770ee07770eeee077777777770eeeee0077777770eeeee07770e07770eeeee07770e07770eeeee0e0eeeeeeeeee0e0
077777777770eeee07777777770eeeee077700007770eeee077777777770eeeee0777777770eeeee07770007770eeeee07770e07770eeeeee11eeeeeeeeee11e
077770000000eeee00000007770eeeee077770077770eeee077770000000eeeee0777777770eeeee07770077770eeeee07770e07770eeeeeeee10eeeeee01eee
077770eeeeeeeeeeeeeeee07770eeeee077770077770eeee077770eeeeeeeeeee0777007770eeeee07770077770eeeee07770e07770eeeeeeee1e1eeee1e1eee
077770eeeeeeeeeeeeeeee07770eeeee077770077770eeee077770eeeeeeeeeee0777007770eeeee07770777770eeeee07770e07770eeeeeeeee01eeee10eeee
077770eeeeeeeeeee0000007770eeeee077777777770eeee07777000000eeeeee0777007770eeeee07770777770eeeee07770007770eeeeeeeeeee0ee0eeeeee
077770eeeeeeeeeee0777777770eeeee077777777770eeee077777777700eeeee0777007770eeeee07777777770eeeee07777777770eeeeeeeeeeee11eeeeeee
077770eeeeeeeeeee0777777770eeeee077777777770eeee077777777770eeeee0777007770eeeee07777707770eeeee07777777770eeeeeeeeeeee11eeeeeee
077770eeeeeeeeeee0000007770eeeee077707707770eeee077770007770eeeee0777007770eeeee07777707770eeeee07770007770eeeeeeeeeee0ee0eeeeee
077770eeeeeeeeeeeeeeee07770eeeee077707707770eeee077770e07770eeeee0777007770eeeee07777007770eeeee07770e07770eeeeeeeee01eeee10eeee
077770eeeeeeeeeeeeeeee07770eeeee077707707770eeee077770e07770eeee00777007770eeeee07777007770eeeee07770e07770eeeeeeee1e1eeee1e1eee
077770eeeeeeeeee00000007770eeeee077700007770eeee077770007770eeee07770007770eeeee07770007770eeeee07770e07770eeeeeeee10eeeeee01eee
077770eeeeeeeeee07777777770eeeee07770ee07770eeee077777777770eeee07770e07770eeeee07770e07770eeeee07770e07770eeeeee01eeeeeeeeee10e
077770eeeeeeeeee07777777700eeeee07770ee07770eeee077777777700eeee07770e07770eeeee07770e07770eeeee07770e07770eeeee1e1eeeeeeeeee1e1
000000eeeeeeeeee0000000000eeeeee00000ee00000eeee00000000000eeeee00000e00000eeeee00000e00000eeeee00000e00000eeeee10eeeeeeeeeeee01
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700000077770000070700007777000000770000700700007007000077700000000000000000000000000000000000000000000000000000000000000000000
07700000000007000707070007000000007070000700700007007000070000000000000000000000000000000000000000000000000000000000000000000000
07700000007777000707070007777000007070000707700007777000070000000000000000000000000000000000000000000000000000000000000000000000
07700000000007000700070007007000007070000770700007007000070000000000000000000000000000000000000000000000000000000000000000000000
07700000077770000700070007770000070070000700700007007000070000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee6eeeeeeeeeee6eeee6e66e6eeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee616eeeeeeee6656eee666666eeeee5e5ee5e5eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee61116eeeeee66666eeee5555eeeee5757557575eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee6616eeeeeee66ee6eeee6666eeeee5777777775eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee611116eeeeee66eeeeeee6666eeeee5777777775eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee671716eeeeeee666eeeee6666eeeee5666666665eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee611116eeeeee666666ee666666eeeee57777775eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee661166eeeeeeeeeeeeeeeeeeeeeeeee57777775eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee61111116eeeeeeee6eeeeee6eeeeeee5777777775eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee611116eeeeeeee66eeeeee6ee6eeee5777777775eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee611116eeeeeee6666eee6e6e6eeeee5777777775eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee61111116eeeeee6666eeee6666eeeee5777777775eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee6111111116eeeee6666eeee666eeeeee5666666665eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee60000006eeeeeee55eeeeee55eeeee577777777775ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee6111111116eeee666666ee666666eeee5555555555eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee66666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
8888822222288ffffff8888888888888888888888888888888888888888888888888888888888888888228228888ff88ff888222822888888822888888228888
8888828888288f8888f8888888888888888888888888888888888888888888888888888888888888882288822888ffffff888222822888882282888888222888
8888822222288f8888f8888888888888888888888888888888888888888888888888888888888888882288822888f8ff8f888222888888228882888888288888
8888888888888f8888f8888888888888888888888888888888888888888888888888888888888888882288822888ffffff888888222888228882888822288888
8888828282888f8888f88888888888888888888888888888888888888888888888888888888888888822888228888ffff8888228222888882282888222288888
8888882828288ffffff88888888888888888888888888888888888888888888888888888888888888882282288888f88f8888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666661111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666667777777711111111777777771111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666611111111111111116666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666661111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666611111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666600000000000000000000000000000000000000000000000066666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee66666666111111111111111111111111111111111111111111111111111111111111111166666666eeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888881888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888817188888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888817718888

__sfx__
011400000030000300003000030000300003000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001861230613104001040010400104001040010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0000185501d150245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000c54005140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9d1000000c64300100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
190300000c73028730377303c73000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c6231d620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090f0000301402d100301403010030100301403010030140301003f10030140301003010030140300003010030130301303013030120301203012030110301103011300100001000010000100001000000000000
031000001364312653000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c7500c7500c7501075010750107501375013750137501875018750187501875018750187500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0411000017050170001a0001a050100001005010000100001c050000001c050000001c050000001c0501c050000001c05000000000001a050000000000000000000001705000000000001a050000001005000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0430000000000000000c6450c00000000000000c0530000000000000000c6550000000000000000c0530000000000000000c6550000000000000000c0530000000000000000c655000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000001885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 46474344

