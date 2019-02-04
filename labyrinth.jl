"""Programm zur erstellung eines Labryrinths.
Das Programm ist sehr un effizient, da am immer alle optionen für neue sub bäume getestet werden. gegen ende passiert mehr nichts als etwas, da die menge an zu überprüfenden felder immer größer wird."""

using ImageView, ImageMagick, Images, TestImages

#directions 
tx = [1,0,-1,0]
ty = [0,1,0,-1]

#dimensions
XDIM = 50
YDIM = 50

#board
img = zeros(YDIM,XDIM)
collector = zeros(XDIM,YDIM,1)

# starting position at the most left
start = rand(2:XDIM-1) 
img[start,1] = 1 

#abbruchbedingung der branches
koords_white = findall(x -> x == 1.0, img) 
totalstuck = 0

x = 1 #to only get one entrance
y = start
r = 1 # the first step should be away from the wall
while true   
    global stuckcount = [0,0,0,0]
    while x < XDIM # die bedingung ist überflüssig
        #first check if move is posible, then its made
        lx = x + tx[r]
        ly = y + ty[r]
        
        if img[ly,lx] == 1 || lx == 1 || ly == 1 || ly == YDIM || lx == XDIM#rand
            global stuckcount[r] = 1
        else
            if lx < XDIM && count( i -> i == 1.0, img[ly-1:ly+1,lx-1:lx+1]) >= 3 #knicke
                global stuckcount[r] = 1
            else 
                global x = lx
                global y = ly
                img[y,x] = 1
                global stuckcount = [0,0,0,0]
                global totalstuck = 0

                #time sequenz
                global collector = cat(collector,img;dims=3)


            end
        end
        
        #wenn alle richtungenblockiert sind dann geht es nicht weiter
        if count( i -> i == 1, stuckcount) == 4
            global totalstuck = totalstuck +1
            break
        end
        
        global r = rand(1:4)
    end
    
    #die neuen x und y werte müssen aus dem pool der weißen felder kommen
    koords_white = findall(x -> x == 1.0, img)
    
    if totalstuck == size(koords_white)[1] #ausgang
        beforeend = [i for i = 2:size(koords_white)[1] if koords_white[i][2] == XDIM-1]
        index = beforeend[rand(1:size(beforeend)[1])]
        endx = koords_white[index][2]
        endy = koords_white[index][1]
        img[endy,endx+1] = 1 # exit 
        break
    end
    
    newkoords = rand(2:size(koords_white)[1])
    
    global x = koords_white[newkoords][2]
    global y = koords_white[newkoords][1]
end

collector = cat(collector,img;dims=3)

##solver

#initiate memory
mem = (start,1)
img[mem[1],mem[2]] = 0.5
collector = cat(collector,img;dims=3)
#initiate pos 
pos = (start,2)
img[pos[1],pos[2]] = 0.5
collector = cat(collector,img;dims=3)

while pos[2] != XDIM

    #initiate memoryhelper
    membuff = pos

#    println("$pos, $membuff, $mem")
#    if pos[1] >= 1 && pos[2] >= 1 && pos[1] <= YDIM && pos[2] <= XDIM 
#        display(img[pos[1]-1:pos[1]+1,pos[2]-1:pos[2]+1])
#    end
#    print("continue?")
#    readline(stdin) == "q" && break
    
    dy = mem[1] - pos[1]
    dx = mem[2] - pos[2]

    if img[pos[1] - dx, pos[2] + dy] > 0.1 # 0.1 is my epsilon
        global pos = (pos[1] - dx, pos[2] + dy)
    elseif img[pos[1] - dy, pos[2] - dx] > 0.1
        global pos = (pos[1] - dy, pos[2] - dx)
    elseif img[pos[1] + dx, pos[2] - dy] > 0.1 
        global pos = (pos[1] + dx, pos[2] - dy)
    elseif img[pos[1] + dy, pos[2] + dx] > 0.1
        global pos = (pos[1] + dy, pos[2] + dx)
    else
        break # not gonna happen :^)
    end

    img[pos[1],pos[2]] = 0.5
    global collector = cat(collector, img;dims=3)
    
    #set up for the next dx dy
    global mem = membuff
end


imshow(collector)
