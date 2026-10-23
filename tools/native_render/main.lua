local root=assert(os.getenv('SCREENSAVER_WORKSPACE'),'Set SCREENSAVER_WORKSPACE to the workspace path')..'/'
function love.load()
  local ok,err=xpcall(function()
    local g=love.graphics
    local function module(name)
      local source=assert(io.open(root..'Screensaver/'..name..'.lua','rb'));local code=source:read('*a');source:close();return assert(loadstring(code))()
    end
    package.path=root..'gen1recomp-0.3.54/?.lua;'..package.path
    local rain=module('pokemon_rain')({generation=3},g)
    local fixtureTime=0
    local images={}
    local namesList={}
    for i,stem in ipairs({'BULBASAUR','BLASTOISE_2','EMOLGA','CACTURNE','TYRANITAR_1','SANDSHREW_1','BASCULEGION_1'}) do
      local function picture(frame)
        local f=io.open(root..'.work/sprite-render-probe/'..stem..'-front-style0-frame'..frame..'.png','rb')
        if not f then return nil end
        local bytes=f:read('*a');f:close()
        local image=g.newImage(love.filesystem.newFileData(bytes,stem..'.png'));image:setFilter('nearest','nearest');return image
      end
      local img=picture(1)
      if not img then
        local pixels=love.image.newImageData(32,32)
        for y=8,23 do for x=8,23 do pixels:setPixel(x,y,.3,.8,1,1) end end
        img=g.newImage(pixels)
      end
      images[i]={img,picture(45) or img};namesList[i]=stem
    end
    local game={data={gen3Pokemon={_names=namesList,frontPic=function(species)
      return {image=images[species][math.floor(fixtureTime*12)%2+1]}
    end}}}
    for i=1,16 do fixtureTime=i/60;rain.update(game,1/60) end
    local matrix=module('matrix')(g)
    local draw=module('effects')(g,{matrix=matrix,pokemon=rain.draw,classic=module('classic')(g)})
    local names={'Star Warp','Aurora Veil','Neon Pokeballs','Prism Garden','Moonlit Ripples','Matrix Rain','Pokemon Rain','Pokemon Orbits','Pokemon Constellation','Pokemon Mosaic','Pokeball Pulses','Retro Pipes','Mystify Trails','Bubble Drift','Flurry Streams','Flying Toasters'}
    local ids={1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17}
    local shots={}
    for i,id in ipairs(ids) do
      local c=g.newCanvas(960,540)
      g.setCanvas(c);g.clear(0,0,0,1);draw(id,12,960,540,1);g.setCanvas()
      local bytes=c:newImageData():encode('png'):getString()
      local f=assert(io.open(root..'Screensaver/docs/effect-'..id..'.png','wb'));f:write(bytes);f:close()
      shots[i]=c
    end
    for _,size in ipairs({{320,240},{480,320},{1920,1080},{540,960},{2560,1080},{3840,1080},{5120,1440}}) do
      local c=g.newCanvas(size[1],size[2]);g.setCanvas(c)
      for _,id in ipairs(ids) do draw(id,9,size[1],size[2],.5)end
      g.setCanvas();c:release()
    end
    local wideShots={}
    for i,id in ipairs(ids) do
      local c=g.newCanvas(1920,540);g.setCanvas(c);g.clear(0,0,0,1)
      draw(id,12,1920,540,1);g.setCanvas();wideShots[i]=c
      local pixels=c:newImageData()
      for side=0,1 do
        local hits=0
        for x=side==0 and 0 or 1280,side==0 and 640 or 1919,3 do
          for y=0,539,3 do
            local r,green,b=pixels:getPixel(x,y)
            if math.max(r,green,b)>.13 then hits=hits+1 end
          end
        end
        assert(hits>8,'effect '..i..' must populate outer third '..side..': '..hits)
      end
    end
    local wideGallery=g.newCanvas(1920,2400);g.setCanvas(wideGallery);g.clear(.025,.035,.065,1)
    g.setFont(g.newFont(20))
    for i,c in ipairs(wideShots)do
      local x,y=((i-1)%2)*960,math.floor((i-1)/2)*300
      g.setColor(1,1,1,1);g.draw(c,x,y,0,.5,.5);g.print(names[i],x+20,y+274)
    end
    g.setCanvas()
    local wideBytes=wideGallery:newImageData():encode('png'):getString()
    local wideFile=assert(io.open(root..'Screensaver/docs/ultrawide.png','wb'));wideFile:write(wideBytes);wideFile:close()
    local transparent=g.newCanvas(960,540);g.setCanvas(transparent)
    g.clear(.8,.2,.1,1);draw(3,12,960,540,1,0);g.setCanvas()
    local r=transparent:newImageData():getPixel(0,0)
    assert(math.abs(r-.8)<.02,'zero dim preserves world')
    g.setCanvas(transparent);g.clear(.8,.2,.1,1);draw(3,12,960,540,1,.5);g.setCanvas()
    r=transparent:newImageData():getPixel(0,0)
    assert(math.abs(r-.409)<.02,'half dim blends world')
    local gallery=g.newCanvas(1200,3040);g.setCanvas(gallery);g.clear(.025,.035,.065,1)
    g.setFont(g.newFont(20))
    for i,c in ipairs(shots)do
      local x=((i-1)%2)*600;local y=math.floor((i-1)/2)*370
      g.setColor(1,1,1,1);g.draw(c,x,y,0,.625,.625);g.print(names[i],x+20,y+342)
    end
    g.setColor(.8,.9,1,1);g.print('SCREENSAVER / 16 EFFECTS',20,2970)
    g.print('Sprite previews use a local 1025Dex fixture.',20,3005)
    g.setCanvas()
    local bytes=gallery:newImageData():encode('png'):getString()
    local f=assert(io.open(root..'Screensaver/docs/gallery.png','wb'));f:write(bytes);f:close()
    local palettes=g.newCanvas(1200,1850);g.setCanvas(palettes);g.clear(.025,.035,.065,1)
    local labels={'Green','Amber','Cyan','Red','Violet','White','Rainbow Flow','Ocean Flow','Sunset Flow','Aurora Flow'}
    for i=1,10 do
      local c=g.newCanvas(960,540);g.setCanvas(c);g.clear(0,0,0,1);draw(6,12,960,540,1,1,i)
      g.setCanvas(palettes);g.setColor(1,1,1,1)
      local x,y=((i-1)%2)*600,math.floor((i-1)/2)*370
      g.draw(c,x,y,0,.625,.625);g.print(labels[i],x+20,y+342)
    end
    g.setCanvas()
    bytes=palettes:newImageData():encode('png'):getString()
    f=assert(io.open(root..'Screensaver/docs/matrix-palettes.png','wb'));f:write(bytes);f:close()
  end,debug.traceback)
  local f=io.open(root..'.work/screensaver-preview/result.txt','w');f:write(ok and 'PASS native graphics: sixteen effects, ten Matrix palettes, eight resolutions, 32:9 coverage and transparency' or tostring(err));f:close()
  love.event.quit()
end

