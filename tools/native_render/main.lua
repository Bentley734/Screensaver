local root=assert(os.getenv('SCREENSAVER_WORKSPACE'),'Set SCREENSAVER_WORKSPACE to the workspace path')..'/'
function love.load()
  local ok,err=xpcall(function()
    local g=love.graphics
    local source=assert(io.open(root..'Screensaver/effects.lua','rb'));local code=source:read('*a');source:close();local draw=assert(loadstring(code))()(g)
    local names={'Star Warp','Aurora Veil','Neon Pokeballs','Prism Garden','Moonlit Ripples'}
    local shots={}
    for i=1,5 do
      local c=g.newCanvas(960,540)
      g.setCanvas(c);g.clear(0,0,0,1);draw(i,12,960,540,1);g.setCanvas()
      local bytes=c:newImageData():encode('png'):getString()
      local f=assert(io.open(root..'Screensaver/docs/effect-'..i..'.png','wb'));f:write(bytes);f:close()
      shots[i]=c
    end
    for _,size in ipairs({{320,240},{480,320},{1920,1080},{540,960},{2560,1080},{3840,1080},{5120,1440}}) do
      local c=g.newCanvas(size[1],size[2]);g.setCanvas(c)
      for i=1,5 do draw(i,9,size[1],size[2],.5)end
      g.setCanvas();c:release()
    end
    local wideShots={}
    for i=1,5 do
      local c=g.newCanvas(1920,540);g.setCanvas(c);g.clear(0,0,0,1)
      draw(i,12,1920,540,1);g.setCanvas();wideShots[i]=c
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
    local wideGallery=g.newCanvas(1920,2850);g.setCanvas(wideGallery);g.clear(.025,.035,.065,1)
    g.setFont(g.newFont(20))
    for i,c in ipairs(wideShots)do
      g.setColor(1,1,1,1);g.draw(c,0,(i-1)*570);g.print(names[i],20,(i-1)*570+544)
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
    local gallery=g.newCanvas(1200,1110);g.setCanvas(gallery);g.clear(.025,.035,.065,1)
    g.setFont(g.newFont(20))
    for i,c in ipairs(shots)do
      local x=((i-1)%2)*600;local y=math.floor((i-1)/2)*370
      g.setColor(1,1,1,1);g.draw(c,x,y,0,.625,.625);g.print(names[i],x+20,y+342)
    end
    g.setColor(.8,.9,1,1);g.print('SCREENSAVER',640,790)
    g.print('Five effects. Your world behind them.',640,835)
    g.print('Optional pause / adjustable background dim',640,875)
    g.setCanvas()
    local bytes=gallery:newImageData():encode('png'):getString()
    local f=assert(io.open(root..'Screensaver/docs/gallery.png','wb'));f:write(bytes);f:close()
  end,debug.traceback)
  local f=io.open(root..'.work/screensaver-preview/result.txt','w');f:write(ok and 'PASS native graphics: five effects, eight resolutions, 32:9 outer-third coverage and transparency' or tostring(err));f:close()
  love.event.quit()
end

