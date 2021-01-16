% Functions and Procedures
function check_y (var fishes: array 1..* of array 1..8 of int, test_y,j:int):boolean %makes sure there is enough vertical distance between the fishes
    for i:lower(fishes)..upper(fishes)
	if i<j and abs(test_y-fishes(i)(2))<fishes(i)(6)+5 then result false
	end if
    end for
    result true
end check_y

proc new_fishes (var fishes:  array 1..* of array 1..8 of int, level:int,i:int,var pics: array 1..* of int) % Every time assigns the new fishes that enter the aquarium 
    var direction:int % assigns the direction that fishs entes the aquarium : 1 -> right and -1 -> left
    loop %makes sure the direction is either 1 or -1 and not 0
	 direction:=Rand.Int(-1,1)
	 exit when direction=1 or direction=-1
    end loop
    fishes(i)(4):=direction
    fishes(i)(3):=Rand.Int(1,level+1) %assigns the level of the fish
    fishes(i)(5):=30*fishes(i)(3) %assigns the widths of fishes
    fishes(i)(6):=10*fishes(i)(3) %assigns the heights of fishes
    fishes(i)(7):=direction*fishes(i)(3) %assigns the hosrisantal speed of fishes based on level
    fishes(i)(8):=Rand.Int(-1,1)*fishes(i)(3) %assigns the vertical speed of fishes based on level
    var test_y:int:=0
	loop %makes sure there is enough space between the fishes
	test_y:=Rand.Int(10,850)
	exit when check_y(fishes,test_y,i)=true
    end loop
    fishes(i)(2):=test_y %assigns the y-value of the fish's position
    if direction=-1 then fishes(i)(1):=970
    elsif direction=1 then fishes (i)(1):=-30*fishes(i)(3)
    end if
end new_fishes

proc new_rocket (var rockets:  array 1..* of array 1..4 of int,level,i:int) % Every time assigns the new rocket that enter the aquarium 
    var direction:int % assigns the direction that the rocket entes the aquarium : 1 -> up and -1 -> down
    loop %makes sure the direction is either 1 or -1 and not 0
	 direction:=Rand.Int(-1,1)
	 exit when direction=1 or direction=-1
    end loop
    rockets(i)(4):=direction
    rockets(i)(3):=Rand.Int(-1,1)*level
    rockets(i)(1):=Rand.Int(10,990)
    if direction=-1 then rockets(i)(2):=900
    elsif direction=1 then rockets (i)(2):=0
    end if
end new_rocket

proc check_pos (var fishes: array 1..* of array 1..8 of int, var rockets:array 1..* of array 1..4 of int, level:int, var pics: array 1..* of int) %checks x to see if there is a need for new fish
    for i:lower(fishes)..upper(fishes)
	if fishes(i)(2)>=900 or fishes(i)(2)<=0 or (fishes(i)(1)>=900 and fishes(i)(7)>0) or (fishes(i)(1)<=0 and fishes(i)(7)<0) then
	   new_fishes(fishes,level,i,pics)
	end if
    end for
    for i:lower(rockets)..upper(rockets)
	if rockets(i)(1)>=1000 or rockets(i)(1)<=0 or (rockets(i)(2)>=1000 and rockets(i)(4)>0) or (rockets(i)(2)<=0 and rockets(i)(4)<0) then
	   new_rocket(rockets,level,i)
	end if
    end for
end check_pos

proc display (var fishes: array 1..* of array 1..8 of int,var rockets:array 1..* of array 1..4 of int,var pics: array 1..* of int) %display the array of fishes
    var font:int:=Font.New("serif:12")
    for i:lower(fishes)..upper(fishes)
	if abs(fishes(i)(7))~=fishes(i)(3) or abs(fishes(i)(8))>fishes(i)(3) then
	    Draw.Text("Food!",floor(fishes(i)(1)+fishes(i)(5)/2-10),fishes(i)(2)+fishes(i)(6),font,red)
	end if
	if fishes(i)(4)= 1 then %Rotates the image when the fishes come from the opposite direction
	    Pic.Draw (pics(fishes(i)(3)*2), fishes(i)(1) , fishes(i)(2), picMerge)
	else 
	    Pic.Draw (pics (fishes(i)(3)*2-1), fishes(i)(1) , fishes(i)(2), picMerge)
	end if
    end for
    for i:lower(rockets)..upper(rockets)
	Pic.Draw (pics(29), rockets(i)(1) , rockets(i)(2), picMerge)
    end for
end display 

proc move (var fishes: array 1..* of array 1..8 of int,var rockets:array 1..* of array 1..4 of int) %creates the movement of fishes
    for i:lower(fishes)..upper(fishes)
	fishes(i)(1)+=fishes(i)(7) %d=v*dt
	fishes(i)(2)+=fishes(i)(8)
    end for
    for i:lower(rockets)..upper(rockets)
	rockets(i)(1)+=rockets(i)(3) %d=v*dt
	rockets(i)(2)+=rockets(i)(4)
    end for
end move 

proc catch (var fishes: array 1..* of array 1..8 of int,x,y,level:int) %creates the movement of fishes
    for i:lower(fishes)..upper(fishes)
	if sqrt((fishes(i)(1)-x)**2+(fishes(i)(2)-y)**2)<=200*(level+1)/2 and fishes(i)(3)>level then
	    var vx:int:=-floor((fishes(i)(1)-x+50)/(50*level)*fishes(i)(3))
	    var vy:int:=-floor((fishes(i)(2)-y+50)/(50*level)*fishes(i)(3))
	    fishes(i)(7):=vx
	    fishes(i)(8):=vy
	    if fishes(i)(7)>=0 then fishes(i)(4):=1
	    elsif fishes(i)(7)<0 then fishes(i)(4):=-1
	    end if
	else
	    if fishes(i)(7)>=0 then fishes(i)(4):=1
	    elsif fishes(i)(7)<0 then fishes(i)(4):=-1
	    end if
	    fishes(i)(7):=fishes(i)(4)*fishes(i)(3) 
	    if fishes(i)(8)>0 then fishes(i)(8):=fishes(i)(3)
	    elsif fishes(i)(8)<0 then fishes(i)(8):=fishes(i)(3)*-1
	    end if
       end if
    end for
end catch

function eat(var fishes: array 1..* of array 1..8 of int, x,y,level,vx,vy,width,height:int):int %checks if the main fish eats another fish (3) or gets eaten by another fish (2) or etc (1).
    for i:lower(fishes)..upper(fishes)
	if (x>=fishes(i)(1)-5 and x<=fishes(i)(1)+fishes(i)(5)+5 and y>=fishes(i)(2)-5 and y<=fishes(i)(2)+fishes(i)(6)+5) or (x+width>=fishes(i)(1)-5 and x+width<=fishes(i)(1)+fishes(i)(5)+5 and y>=fishes(i)(2)-5 and y<=fishes(i)(2)+fishes(i)(6)+5) or (x>=fishes(i)(1)-5 and x<=fishes(i)(1)+fishes(i)(5)+5 and y+height>=fishes(i)(2)-5 and y+height<=fishes(i)(2)+fishes(i)(6)+5) or (x+width>=fishes(i)(1)-5 and x+width<=fishes(i)(1)+fishes(i)(5)+5 and y+height>=fishes(i)(2)-5 and y+height<=fishes(i)(2)+fishes(i)(6)+5) then
	    if fishes(i)(3)<=level then %it records the number of dead fishes
		result 3+i
	    elsif fishes(i)(3)>level then
		result 2 
	    end if
	end if
   end for
   result 1
end eat

proc whole_eat (var fishes: array 1..* of array 1..8 of int,level:int, var pics: array 1..* of int) %checks to see if other fishes eat each other 
    for i:lower(fishes)..upper(fishes)-1
	for j:i+1.. upper(fishes)
	    if (fishes(i)(1)>=fishes(j)(1)-5 and fishes(i)(1)<=fishes(j)(1)+fishes(j)(5)+5 and fishes(i)(2)>=fishes(j)(2)-5 and fishes(i)(2)<=fishes(j)(2)+fishes(j)(6)+5) or (fishes(i)(1)+fishes(i)(5)>=fishes(j)(1)-5 and fishes(i)(1)+fishes(i)(5)<=fishes(j)(1)+fishes(j)(5)+5 and fishes(i)(2)>=fishes(j)(2)-5 and fishes(i)(2)<=fishes(j)(2)+fishes(j)(6)+5) or (fishes(i)(1)>=fishes(j)(1)-5 and fishes(i)(1)<=fishes(j)(1)+fishes(j)(5)+5 and fishes(i)(2)+fishes(i)(6)>=fishes(j)(2)-5 and fishes(i)(2)+fishes(i)(6)<=fishes(j)(2)+fishes(j)(6)+5) or (fishes(i)(1)+fishes(i)(5)>=fishes(j)(1)-5 and fishes(i)(1)+fishes(i)(5)<=fishes(j)(1)+fishes(j)(5)+5 and fishes(i)(2)+fishes(i)(6)>=fishes(j)(2)-5 and fishes(i)(2)+fishes(i)(6)<=fishes(j)(2)+fishes(j)(6)+5) then
		if fishes(i)(3)>fishes(j)(3) then %it checks for dead fishes
		    new_fishes(fishes,level,j,pics)
		elsif fishes(i)(3)<fishes(j)(3) then
		    new_fishes(fishes,level,i,pics)
		    exit
		end if
	    end if
	end for
    end for
end whole_eat

proc load_pictures(var pics: array 1..* of int)%Loads all the images
    var fname : string
    for i : lower(pics) .. upper(pics)
	fname := "images/"+intstr(i) +".bmp"
	pics(i):=Pic.FileNew(fname)
    end for
end load_pictures

proc boosting(var rockets: array 1..* of array 1..4 of int, var x,y,level,vx,vy,width,height,boost,tt,t:int)%checks if the main fish eats a rocket or not.
    for i:lower(rockets)..upper(rockets)
	if boost=0 and ((x>=rockets(i)(1)-5 and x<=rockets(i)(1)+100 and y>=rockets(i)(2)-5 and y<=rockets(i)(2)+40) or (x+width>=rockets(i)(1)-5 and x+width<=rockets(i)(1)+100 and y>=rockets(i)(2)-5 and y<=rockets(i)(2)+40) or (x>=rockets(i)(1)-5 and x<=rockets(i)(1)+100 and y+height>=rockets(i)(2)-5 and y+height<=rockets(i)(2)+40) or (x+width>=rockets(i)(1)-5 and x+width<=rockets(i)(1)+40 and y+height>=rockets(i)(2)-5 and y+height<=rockets(i)(2)+40)) then
	    new_rocket(rockets,level,i)
	    boost:=1
	    tt:=t
	    if vx~=0 then vx*=2
	    elsif vy~=0 then vy*=2
	    end if
	end if
   end for
end boosting

proc save(var fishes: array 1..* of array 1..8 of int,var rockets:array 1..* of array 1..4 of int,level,x,y,direction,vx,vy,width,height,score,t,tt:int)% saves the dependent variables 
    var f:int
    open: f,"save.txt", put
    put :f,intstr(upper(fishes))
    put :f,intstr(upper(rockets))
    for i:lower(fishes)..upper(fishes)
	var a:string:=""
	for j:1..8
	    a+=intstr(fishes(i)(j))+" "
	end for
	put : f, a
    end for
   put:f,intstr(level)
   put:f,intstr(x)
   put:f,intstr(y)
   put:f,intstr(direction)
   put:f,intstr(vx)
   put:f,intstr(vy)
   put:f,intstr(width)
   put:f,intstr(height)
   put:f,intstr(score)
   put:f,intstr(t)
   put:f,intstr(tt)
   for i:lower(rockets)..upper(rockets)
       var a:string:=""
       for j:1..4
	   a+=intstr(fishes(i)(j))+" "
       end for
       put : f, a
   end for
   close:f
end save

proc load(var fishes: array 1..* of array 1..8 of int,var rockets:array 1..* of array 1..4 of int,var level,x,y,direction,vx,vy,width,height,score,t,tt:int)% saves the dependent variables 
    var f:int
    var s:string
    var i:int:=1
    open: f,"save.txt", get
    get: f,s
    var up:int:=strint(s)
    get: f,s
    var upp:int:=strint(s)
    for j:lower(fishes)..up*8
	get:f,s
	fishes(i)(((j-1) mod 8)+1):=strint(s)
	if j=8*i then i+=1
	end if
    end for
   get:f,s
   level:=strint(s)
   get:f,s
   x:=strint(s)
   get:f,s
   y:=strint(s)
   get:f,s
   direction:=strint(s)
   get:f,s
   vx:=strint(s)
   get:f,s
   vy:=strint(s)
   get:f,s
   width:=strint(s)
   get:f,s
   height:=strint(s)
   get:f,s
   score:=strint(s)
   get:f,s
   t:=strint(s)
   get:f,s
   tt:=strint(s)
   i:=1
   for j:lower(rockets)..upp*4
       get:f,s
       rockets(i)(((j-1) mod 4)+1):=strint(s)
       if j=4*i then i+=1
       end if
   end for
   close: f
end load

proc instructions(var pics: array 1..* of int) %shows the instructions
    var font:int:=Font.New("Serif:18")
    var font2:int:=Font.New("Serif:18")
    var valueX,valueY:int
    var button:int:=0
    loop
	Pic.Draw(pics(26),0,0,picCopy)
	Draw.Text("Back",800,875,font2,41)
	Draw.Text("Norma and his family were on a trip to the south part of the ocean, but Norma got lost in " ,50,825,font,red)
	Draw.Text("the ocean slips. Now Norma is trying to find his way back home! Help him through this" ,50,775,font,red)
	Draw.Text("dangerous journey and be careful with the sharks!! This game has four levels and in each" ,50,725,font,red)
	Draw.Text("level Norma can eat fishes smaller than him but can be eaten by bigger fishes. You can use" ,50,675,font,red)
	Draw.Text("the rockets to boost Norma. The chart below shows Norma's prays and predators in each level:" ,50,625,font,red)
	Pic.Draw(pics(27),100,250,picCopy)
	Pic.Draw(pics(28),100,100,picCopy)
	Mouse.Where(valueX,valueY,button)
	if valueX>=800 and valueX<=885 and valueY>=875 and valueY<=900 and button=1 then
	    exit
	end if
	View.Update()
    end loop
end instructions

% Independent variables 
var pics: array 1..29 of int:=init(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
var chars : array char of boolean 
var font:int:=Font.New("serif:12")
var font2: int:=Font.New("serif:25")
var font3: int:=Font.New("serif:40")
var button:int:=0
var valueX,valueY:int:=0
var eat_stat:int
var l:int:=0 
load_pictures(pics)

% Starter
setscreen("graphics: 1000;900, offscreenonly")

loop
    Pic.Draw (pics (25), 0 , 0, picCopy)
    Draw.FillBox(380,740,715,790,10)
    Font.Draw("Feeding Frenzy",380,750,font3,12)
    Draw.FillBox(500,595,575,625,13)
    Font.Draw("Start!",500,600,font2,14)
    Draw.FillBox(460,445,630,480,13)
    Font.Draw("Load Game!!",460,450,font2,10)
    Draw.FillBox(460,295,635,325,13)
    Font.Draw("Instructions?!",460,300,font2, 11)
    Draw.FillBox(500,145,585,175,13)
    Font.Draw("Exit!!!",500,150,font2, 9)
    View.Update    
    Mouse.Where(valueX,valueY,button)
    if valueX>=500 and valueX<=595 and valueY>=575 and valueY<=625 and button=1 then
	exit
    elsif valueX>=500 and valueX<=585 and valueY>=145 and valueY<=175 and button=1 then
	quit
    elsif valueX>=460 and valueX<=630 and valueY>=445 and valueY<=480 and button=1 then
	l:=1
	exit
    elsif valueX>=460 and valueX<=635 and valueY>=295 and valueY<=325 and button=1 then
	instructions(pics)
    end if
end loop 

% Dependent variables
%fishes(i)= (x-value, y-value, level, direction, width, height, vx, vy) 
%rockets(i)= (x-value, y-value, vx, vy) 
var fishes: flexible array 1..6 of array 1..8 of int
var rockets: flexible array 1..2 of array 1..4 of int
var level:int:=1
var x:int:=500
var y:int:=450
var direction:int:=1
var vx:int:=10*level
var vy:int:=0
var width:int:=35*level
var height:int:=12*level
var score:int:=0
var boost:int:=0
var t:int:=0
var tt:int:=0

if l=0 then
   for i:lower(fishes)..upper(fishes)
       new_fishes(fishes,level,i,pics)
   end for
   for i:lower(rockets)..upper(rockets)
       new_rocket(rockets,level,i)
   end for
elsif l=1 then % loads the dependent variables
    var f:int
    var s:string
    % finds out the lenghts of the arrays fishes and rockets
    open: f,"save.txt", get
    get: f,s
    var up:int:=strint(s)
    new fishes,up
    get: f,s
    var upp:int:=strint(s)
    new rockets,upp
    close: f
    load(fishes,rockets,level,x,y,direction,vx,vy,width,height,score,t,tt)
end if

% Main Program
loop
    loop
	Pic.Draw (pics (18+level), 0 , 0, picCopy)
	t+=1
	Mouse.Where(valueX,valueY,button)
	Draw.Text("Your score is: "+intstr(score),450,875,font,40+level)
	Draw.Text("Your level is: "+intstr(level),453,850,font,40+level)
	Draw.Text("Exit!!!!",800,875,font2,40+level)
	Draw.Text("Save",100,875,font2,40+level)
	if valueX>=800 and valueX<=885 and valueY>=875 and valueY<=900 and button=1 then
	    quit
	end if
	if valueX>=100 and valueX<=185 and valueY>=875 and valueY<=900 and button=1 then
	    save(fishes,rockets,level,x,y,direction,vx,vy,width,height,score,t,tt)
	    quit
	end if
	check_pos(fishes,rockets, level,pics)
	catch(fishes,x,y,level)
	move(fishes,rockets)
	display(fishes,rockets,pics)
	Input.KeyDown (chars) 
	x+=vx
	y+=vy
	if t-tt>50 then tt:=0;boost:=0
	end if
	if chars (KEY_UP_ARROW) then 
	    if boost=0 then
		vy:=7*level 
		vx:=0
	    elsif boost=1 then
		vy:=14*level
		vx:=0
	    end if
	elsif chars (KEY_RIGHT_ARROW) then 
	    direction:=1
	    if boost=0 then
		vx:=7*level 
		vy:=0
	    elsif boost=1 then
		vx:=14*level
		vy:=0
	    end if
	elsif chars (KEY_LEFT_ARROW) then 
	    direction:=-1
	    if boost=0 then
		vx:=-7*level 
		vy:=0
	    elsif boost=1 then
		vx:=-14*level
		vy:=0
	    end if
	elsif chars (KEY_DOWN_ARROW) then 
	    vy:=-7*level
	    if boost=0 then
		vy:=-7*level 
		vx:=0
	    elsif boost=1 then
		vy:=-14*level
		vx:=0
	    end if        
	end if 
	if x>=1000-width or x<=0 then
	    vx:=vx*-1
	    direction*=-1
	    if x<=0 then x:=0
	    else x:=1000-width
	    end if
	end if
	if y>=900-height or y<=0 then
	    vy:=vy*-1
	    if y<=0 then y:=0
	    else y:=900-height
	    end if
	end if
	if boost~=0 then Draw.Text("Booosted", floor(x+width/2-15),y+height,font,red) 
	end if
	if direction=1 then Pic.Draw (pics (10+level*2), x , y, picMerge)
	elsif direction=-1 then Pic.Draw (pics (10+level*2-1), x , y, picMerge) 
	end if   
	View.Update()
	delay(100)
	boosting(rockets,x,y,level,vx,vy,width,height,boost,tt,t)
	eat_stat:=eat(fishes,x,y,level,vx,vy,width,height)
	if eat_stat=2 then
	    exit
	elsif eat_stat>2 then
	    score+=fishes(eat_stat-3)(3)
	    new_fishes(fishes,level,eat_stat-3,pics)
	end if
	whole_eat(fishes,level,pics)
	cls
	if score>=5*level**2 then 
	    new fishes,6+3*level
	    new rockets,2+level
	    level+=1
	    if level<=4 then
		for i:lower(fishes)..upper(fishes)
		    new_fishes(fishes,level,i,pics)
		end for 
		for i:lower(rockets)..upper(rockets)
		    new_rocket(rockets,level,i)
		end for 
		width:=35*level
		height:=12*level
	    end if
	end if
	exit when level=5
    end loop
    cls
    delay(100)
    if level=5 then
	Pic.Draw(pics(23),0,0,picCopy)
	Font.Draw("Congratulations you won!!",480,450,font2,red)
    else
	Pic.Draw(pics(24),0,0,picCopy)
	Font.Draw("You lost!!!!!!",480,450,font2,red)
	Font.Draw("Your score is: "+intstr(score),480,425,font2,red)
    end if
    
    Font.Draw("Restart!",480,375,font2,red)
    Font.Draw("Exit!!!",480,325,font2, red)
    
    View.Update()
    
    loop
	Mouse.Where(valueX,valueY,button)
	if valueX>=475 and valueX<=560 and valueY>=375 and valueY<=400 and button=1 then
	    exit
	end if
	if valueX>=475 and valueX<=560 and valueY>=325 and valueY<=350 and button=1 then
	    quit
	end if
    end loop
    
    % resets all the variables
    new fishes,6
    new rockets,2
    boost:=0 
    level:=1
    x:=500
    y:=450
    direction:=1
    vx:=5*level
    vy:=0
    width:=35*level
    height:=12*level
    eat_stat:=0
    score:=0

    for i:lower(fishes)..upper(fishes)
	new_fishes(fishes,level,i,pics)
    end for 
    
   for i:lower(rockets)..upper(rockets)
       new_rocket(rockets,level,i)
   end for    
end loop
