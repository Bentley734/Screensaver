-- Original procedural homages to classic desktop screensavers.
-- No operating-system artwork, binaries or textures are used.
return function(g)
  local sin,cos,pi=math.sin,math.cos,math.pi
  local function color(r,b,c,a)g.setColor(r,b,c,a)end
  local function rgb(n)return .5+.5*sin(n),.5+.5*sin(n+2.1),.5+.5*sin(n+4.2)end
  local function fold(v,range)
    local n=v%(range*2);return range-math.abs(range-n)
  end
  local effects={}
  effects[13]=function(t,w,h,alpha)
    local unit=40
    local cols,rows=math.max(2,math.floor(w/unit)),math.max(2,math.floor(h/unit))
    local pipes=math.max(6,math.min(20,math.floor(w*h/(960*540)*6)))
    for i=1,pipes do
      local age=(t+i*3.7)%32;local head=math.floor(age*3)
      local x,y=1+(i*7)%cols,1+(i*11)%rows
      local dir=i%4;local points={}
      for step=0,head+1 do
        local px,py=x*unit-unit/2,y*unit-unit/2
        points[#points+1]={px,py}
        if (step*13+i*7)%5<2 then dir=(dir+((step+i)%2==0 and 1 or 3))%4 end
        local nx=x+(dir==0 and 1 or dir==2 and -1 or 0)
        local ny=y+(dir==1 and 1 or dir==3 and -1 or 0)
        if nx<1 or nx>cols or ny<1 or ny>rows then dir=(dir+2)%4 end
        x=x+(dir==0 and 1 or dir==2 and -1 or 0)
        y=y+(dir==1 and 1 or dir==3 and -1 or 0)
      end
      local r,b,c=rgb(i*1.7)
      for j=math.max(2,#points-24),#points do
        local a,z=points[j-1],points[j]
        local f=j==#points and age*3%1 or 1
        local zx,zy=a[1]+(z[1]-a[1])*f,a[2]+(z[2]-a[2])*f
        color(r*.22,b*.22,c*.22,alpha);g.setLineWidth(15);g.line(a[1],a[2],zx,zy)
        color(r*.8+.1,b*.8+.1,c*.8+.1,alpha);g.setLineWidth(10);g.line(a[1],a[2],zx,zy)
        color(r*.45+.5,b*.45+.5,c*.45+.5,alpha*.8);g.setLineWidth(3);g.line(a[1]-2,a[2]-2,zx-2,zy-2)
        color(r*.8+.1,b*.8+.1,c*.8+.1,alpha);g.circle('fill',zx,zy,5)
      end
    end
  end
  effects[14]=function(t,w,h,alpha)
    local shapes=math.max(2,math.min(6,math.floor(w/480)))
    local span=w/shapes
    for shape=1,shapes do
      for tail=18,0,-1 do
        local time=t-tail*.07
        local points={}
        for corner=1,4 do
          points[#points+1]=(shape-1)*span+15+fold(time*(33+corner*9)+corner*173+shape*251,span-30)
          points[#points+1]=15+fold(time*(25+corner*7)+corner*101+shape*137,h-30)
        end
        local r,b,c=rgb(shape*1.8+t*.12-tail*.04)
        color(r,b,c,alpha*(1-tail/20)*.7);g.setLineWidth(1.4);g.polygon('line',points)
      end
    end
  end
  effects[15]=function(t,w,h,alpha)
    local n=math.max(24,math.min(96,math.floor(24*w*h/(960*540))))
    for i=1,n do
      local radius=18+i%5*9
      local x=((i*.754877666+t*.008)%1)*(w+radius*2)-radius
      local y=((i*.56984029-t*(.025+i%4*.008))%1)*(h+radius*2)-radius
      local r,b,c=rgb(i*1.6+t*.08)
      color(r,b,c,alpha*.045);g.circle('fill',x,y,radius)
      color(r,b,c,alpha*.6);g.setLineWidth(1.5);g.circle('line',x,y,radius)
      color(.7+.3*r,.7+.3*b,.7+.3*c,alpha*.3);g.circle('line',x,y,radius-3)
      color(1,1,1,alpha*.5);g.ellipse('line',x-radius*.3,y-radius*.46,radius*.23,radius*.12)
    end
  end
  effects[16]=function(t,w,h,alpha)
    for stream=1,5 do
      for i=1,120 do
        local age=(i/120+t*.11)%1
        local phase=i*2.39996323+stream*1.8
        local cx=w*(.5+.36*sin(t*.12+stream*1.3))
        local cy=h*(.5+.35*cos(t*.15+stream*1.7))
        local x=cx+sin(phase+t*.9)*w*.38*age
        local y=cy+cos(phase*.8+t*.7)*h*.47*age
        local r,b,c=rgb(stream*1.4+age*3+t*.25)
        local a=alpha*(1-age)*.65
        local behind=math.max(0,age-.035)
        color(r,b,c,a*.5);g.setLineWidth(1.2)
        g.line(cx+sin(phase+(t-.15)*.9)*w*.38*behind,
          cy+cos(phase*.8+(t-.15)*.7)*h*.47*behind,x,y)
        color(r,b,c,a*.12);g.circle('fill',x,y,7*(1-age)+2)
        color(r,b,c,a);g.circle('fill',x,y,2.5*(1-age)+.5)
      end
    end
  end
  local function toaster(x,y,s,t,alpha)
    g.push();g.translate(x,y);g.scale(s,s)
    local flap=sin(t*5)*9
    color(.7,.85,1,alpha*.85)
    g.polygon('fill',-23,0,-48,-20-flap,-42,4,-25,12)
    g.polygon('fill',23,0,48,-20-flap,42,4,25,12)
    color(.23,.29,.38,alpha);g.rectangle('fill',-26,-20,52,45,8,8)
    color(.75,.8,.87,alpha);g.rectangle('fill',-22,-18,44,38,7,7)
    color(.95,.97,1,alpha);g.rectangle('fill',-18,-14,33,8,4,4)
    color(.1,.14,.22,alpha);g.rectangle('fill',-14,-11,26,4,2,2)
    color(.28,.35,.45,alpha);g.circle('fill',13,9,4)
    g.rectangle('fill',-18,20,9,5);g.rectangle('fill',10,20,9,5)
    g.pop()
  end
  effects[17]=function(t,w,h,alpha)
    local n=math.max(14,math.min(56,math.floor(14*w*h/(960*540))))
    for i=1,n do
      local x=((i*.754877666-t*.025)%1)*(w+180)-90
      local y=((i*.56984029+t*.018)%1)*(h+140)-70
      local s=.65+i%3*.2
      if i%4==0 then
        g.push();g.translate(x,y);g.rotate(sin(t*.3+i)*.15);g.scale(s,s)
        color(.65,.32,.12,alpha);g.rectangle('fill',-17,-22,34,44,8,8)
        color(1,.8,.4,alpha);g.rectangle('fill',-13,-18,26,35,6,6);g.pop()
      else toaster(x,y+sin(t+i)*5,s,t+i,alpha) end
    end
  end
  return function(id,t,w,h,alpha)effects[id](t,w,h,alpha)end
end
