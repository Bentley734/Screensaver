-- Original procedural artwork. No textures, shaders, ROM assets or per-frame canvases.
return function(g,extra)
  extra=extra or {}
  local pi, sin, cos = math.pi, math.sin, math.cos
  local opacity=1
  local function color(r,b,c,a) g.setColor(r,b,c,(a or 1)*opacity) end
  local function glow(x,y,r,red,green,blue)
    for n=3,1,-1 do
      color(red,green,blue,.07/n); g.circle('fill',x,y,r*n)
    end
    color(red,green,blue,.9);g.circle('fill',x,y,r*.35)
  end
  local effects={}
  -- Logical area grows with aspect ratio. Add detail rather than leaving a
  -- fixed-width composition in the middle of an ultrawide window.
  local function count(base,w,h)
    return math.max(base,math.min(base*4,math.floor(base*w*h/(960*540)+.5)))
  end
  -- Deterministic depth positions keep the star field stable across frame rates.
  effects[1]=function(t,w,h)
    for i=1,count(180,w,h) do
      local angle=i*2.39996323
      local seed=sin(i*12.9898)*43758.5453
      local depth=1-((seed-math.floor(seed)+t*.15)%1)
      local radius=24/(depth+.025)
      local x,y=w/2+cos(angle)*radius*w/540,h/2+sin(angle)*radius*h/540
      local old=math.max(0,radius-3/(depth+.06))
      color(.45+.5*(1-depth),.7+.25*(1-depth),1,math.min(1,(1-depth)*1.6))
      g.setLineWidth(1+(1-depth)*1.5)
      g.line(w/2+cos(angle)*old*w/540,h/2+sin(angle)*old*h/540,x,y)
    end
    glow(w/2,h/2,8,.24,.45,1)
  end
  effects[2]=function(t,w,h)
    for band=1,3 do
      for layer=18,1,-1 do
        local points={}
        for x=-16,w+16,16 do
          local y=h*(.28+band*.11)+sin(x/w*5+t*.24+band)*h*.12
            +sin(x/w*11-t*.16+band)*h*.045+layer*2
          points[#points+1]=x;points[#points+1]=y
        end
        color(.12+(band-1)*.22,.85-(band-1)*.21,.65+(band-1)*.16,(19-layer)/220)
        g.setLineWidth(7);g.line(points)
      end
    end
  end
  local function bounce(t,range,offset)
    local v=(t+offset)%(range*2);return range-math.abs(range-v)
  end
  effects[3]=function(t,w,h)
    for i=1,count(24,w,h) do
      local r=15+(i%3)*7
      local rx,ry=math.max(1,w-2*r-8),math.max(1,h-2*r-8)
      local x=r+4+bounce(t*(21+i*3),rx,(i*.754877666%1)*rx*2)
      local y=r+4+bounce(t*(17+i*2),ry,(i*.56984029%1)*ry*2)
      local red,green,blue=.5+.5*sin(i*2),.5+.5*sin(i*2+2),.5+.5*sin(i*2+4)
      glow(x,y,r,red,green,blue)
      g.push();g.translate(x,y);g.rotate(t*.15*(i%2==0 and 1 or -1))
      color(red,green,blue);g.setLineWidth(2);g.circle('line',0,0,r)
      g.line(-r,0,-r*.25,0);g.line(r*.25,0,r,0)
      g.circle('line',0,0,r*.25);g.circle('line',0,0,r*.12)
      g.pop()
    end
  end
  effects[4]=function(t,w,h)
    g.push();g.translate(w/2,h/2)
    for ring=1,13 do
      -- Expand the garden to the frame's corners in normalized screen space.
      -- Only positions stretch; each diamond retains its shape at any ratio.
      local r=ring*math.sqrt(480*480+270*270)/13
      local petals=6*(1+math.floor((ring-1)/4))
      for petal=0,petals-1 do
        local a=petal*2*pi/petals+t*.125+ring*.18
        local x,y=cos(a)*r*w/960,sin(a)*r*h/540
        color(.5+.4*sin(ring*.4+t*.2),.5+.4*sin(ring*.4+2+t*.2),.5+.4*sin(ring*.4+4+t*.2),.65)
        g.setLineWidth(1.5);g.push();g.translate(x,y);g.rotate(-a+t*.08)
        local s=9+7*sin(t*.3+ring)^2
        g.polygon('line',0,-s,s*.7,0,0,s,-s*.7,0);g.pop()
      end
    end
    g.pop()
  end
  effects[5]=function(t,w,h)
    for j=1,count(9,w,h) do
      local age=(t*.22+j*.61803398875)%3
      local x=(j*.754877666%1)*w;local y=(j*.56984029%1)*h
      local r=age*math.min(w,h)*.22
      color(.24,.62,.9,(1-age/3)*.45);g.setLineWidth(1.5)
      g.ellipse('line',x,y,r,r*.45)
      color(.45,.85,1,(1-age/3)*.18);g.ellipse('line',x,y,r+7,(r+7)*.45)
    end
    for i=1,count(42,w,h) do
      local x=((i*.61803398875+t*.006)%1)*w
      local y=((i*.41421356+sin(t*.15+i)*.03)%1)*h
      glow(x,y,2,.45,.9,.75)
    end
  end
  effects[6]=function(t,w,h,palette)
    if extra.matrix then extra.matrix(t,w,h,opacity,palette) end
  end
  effects[7]=function(t,w,h)
    if extra.pokemon then extra.pokemon(t,w,h,opacity) end
  end
  return function(effect,t,w,h,alpha,shade,palette)
    if w<=0 or h<=0 then return end
    g.push('all');g.origin();g.setShader();g.setScissor();g.setBlendMode('alpha')
    -- Fit the short axis so portrait layouts get full-height compositions too.
    -- Uniform scale preserves circles and diamonds; layouts use both dimensions.
    local scale=math.min(w/960,h/540)
    g.scale(scale,scale);w=w/scale;h=h/scale
    opacity=alpha
    color(.018,.025,.065,shade or 1);g.rectangle('fill',0,0,w,h)
    effects[effect](t,w,h,palette)
    g.pop()
  end
end
