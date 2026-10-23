-- ASCII glyphs use the built-in font atlas; no external font is required.
return function(g)
  local glyphs='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ<>:/*+=#$%&'
  local solids={{.12,1,.3},{1,.65,.08},{.08,.85,1},{1,.12,.2},{.7,.25,1},{.85,.94,1}}
  local ramps={
    {{1,.15,.3},{1,.8,.1},{.1,1,.5},{.1,.5,1},{.8,.2,1}},
    {{.02,.2,.8},{.05,.9,1},{.3,1,.7}},
    {{.5,.08,.8},{1,.16,.35},{1,.7,.12}},
    {{.05,.9,.35},{.08,.75,1},{.65,.15,1}},
  }
  local font,batch,lastKey
  local function tint(palette,p)
    if palette<=6 then return solids[palette] end
    local ramp=ramps[palette-6] or ramps[1]
    local u=(p%1)*#ramp;local i=math.floor(u)+1;local f=u%1
    local a,b=ramp[i],ramp[i%#ramp+1]
    return {a[1]+(b[1]-a[1])*f,a[2]+(b[2]-a[2])*f,a[3]+(b[3]-a[3])*f}
  end
  return function(t,w,h,alpha,palette)
    palette=palette or 1
    if not font then font=g.newFont(16) end
    if not batch and g.newText then batch=g.newText(font) end
    local tick=math.floor(t*12)
    local key=table.concat({w,h,tick,palette,math.floor(alpha*100)},':')
    if key~=lastKey or not batch then
      if batch then batch:clear() else g.setFont(font) end
      local cols=math.ceil(w/18)
      for col=0,cols-1 do
        local seed=(col*.754877666)%1
        local length=12+col%13
        local speed=38+seed*58
        local head=(t*speed+seed*(h+length*20))%(h+length*20)
        for tail=0,length-1 do
          local y=head-tail*20
          if y>=-20 and y<=h then
            local n=1+(col*17+tail*13+tick*(1+col%3))%#glyphs
            local rgb=tint(palette,t*.075+col/cols*.42+y/h*.32)
            local light=tail==0 and 1 or (1-tail/length)^1.4
            local c={rgb[1],rgb[2],rgb[3],alpha*(.15+.85*light)}
            if tail==0 then c={.65+.35*rgb[1],.65+.35*rgb[2],.65+.35*rgb[3],alpha} end
            local ch=glyphs:sub(n,n)
            if batch then batch:add({c,ch},col*18,y)
            else g.setColor(c);g.print(ch,col*18,y) end
          end
        end
      end
      lastKey=key
    end
    if batch then g.setColor(1,1,1,1);g.draw(batch) end
  end
end
