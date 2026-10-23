-- Borrow current engine/mod images. Never release, mutate or copy their pixels.
return function(mod,g)
  local Runtime=require('src.mods.Runtime')
  local pool,data,provider,loaded,clock={},nil,nil,0,0
  local elapsed=0
  local function reset()
    pool,data,provider,loaded,clock,elapsed={},nil,nil,0,0,0
  end
  local function discover(game)
    local d=game and game.data
    if not d then return end
    local ids={}
    if mod.generation==3 then
      provider=d.gen3Pokemon or require('src.core.game3.pokemon')
      for id,name in pairs(provider._names or {}) do
        if type(id)=='number' and id>0 and type(name)=='string'
            and name~='' and not name:find('%?') and name~='EGG' then
          local nat=provider.national and provider.national(id) or id
          if nat and nat>0 and nat<=1025 then ids[#ids+1]=id end
        end
      end
    else
      for id,def in pairs(d.pokemon or {}) do
        if type(def)=='table' and def.spriteFront and id~='EGG' then ids[#ids+1]=id end
      end
    end
    table.sort(ids)
    if #ids==0 then return end
    data=d
    for i=1,math.min(16,#ids) do
      local j=math.random(i,#ids);ids[i],ids[j]=ids[j],ids[i]
      pool[i]={species=ids[i],mon={species=ids[i],level=50,shiny=false},quads={}}
    end
  end
  local function resolve(p,dt)
    local image,path
    local ctx={species=p.species,side='front',kind='battle',mon=p.mon,data=data,box=64,maxH=64,shiny=false}
    if mod.generation==3 then
      if Runtime.wantsHook('battle.mon_pic') then
        local current=Runtime.call('battle.mon_pic',function(img)return img end,nil,ctx)
        if current~=nil then
          p.image,p.quad,p.size=current or nil,nil,nil;return
        end
      end
      local pic=provider.frontPic(p.species,0,false,0)
      image=pic and pic.image
    else
      local Sprites=require('src.pokemon.Sprites')
      local Assets=require('src.render.Assets')
      path=Sprites.path(data,p.species,'front',{mon=p.mon,kind='battle'})
      if path~=p.basePath then
        local ok,img=pcall(Assets.image,path)
        p.basePath,p.baseImage=path,ok and img or false
      end
      image=p.baseImage or nil
      local current=Runtime.call('battle.mon_pic',function(img)return img end,image,ctx)
      -- false means the selected pack is baking. Do not flash vanilla art.
      if current==false then p.image=nil;return end
      if current then image=current end
      local def=data.pokemon[p.species]
      -- Crystal's own frame sheets also stay animated when no replacement wins.
      if mod.generation==2 and def.anim and current==image and path==def.spriteFront
          and not Runtime.wantsHook('battle.mon_pic') and Assets.resolve(path)==path then
        local anim=def.anim
        local MonAnim=require('src.render.MonAnim')
        p.runner=p.runner or MonAnim.new(anim,'battle')
        if p.runner then
          p.frameTime=(p.frameTime or 0)+dt
          p.frameTime=math.min(p.frameTime,.25)
          while p.frameTime>=1/60 do
            p.frameTime=p.frameTime-1/60;p.runner:update()
            if p.runner:finished() then p.runner=MonAnim.new(anim,'battle') end
          end
          local frame=p.runner:currentFrame()
          local size=(anim.tiles or 7)*8
          local sheet=require('src.pokemon.Sprites').pic(anim.sheet,{species=p.species,side='front',kind='battle_anim',data=data})
          local img=sheet and Assets.image(sheet)
          if img and frame>0 then
            local iw,ih=img:getDimensions()
            if (frame+1)*size<=ih then
              p.quads[frame]=p.quads[frame] or g.newQuad(0,frame*size,size,size,iw,ih)
              p.image,p.quad,p.size=img,p.quads[frame],size;return
            end
          end
        end
      end
    end
    p.image,p.quad,p.size=image,nil,nil
  end
  local api={reset=reset}
  function api.update(game,dt)
    elapsed=elapsed+dt
    if not data then
      clock=clock-dt
      if clock<=0 then discover(game);clock=1 end
    end
    if not data then return end
    -- Admit at most one new species per frame; animated packs can bake in
    -- their normal background update before we request another frame.
    loaded=math.min(#pool,loaded+1)
    for i=1,loaded do
      local p=pool[i]
      if not p.retryAfter or elapsed>=p.retryAfter then
        local ok=pcall(resolve,p,dt)
        if not ok then p.image=nil;p.retryAfter=elapsed+1 end
      end
    end
  end
  function api.draw(t,w,h,alpha)
    local ready={}
    for i=1,loaded do if pool[i].image then ready[#ready+1]=pool[i] end end
    if #ready==0 then
      g.setColor(.7,.85,1,alpha);g.printf('LOADING CURRENT POKEMON SPRITES',0,h/2,w,'center');return
    end
    local count=math.max(24,math.min(96,math.floor(24*w*h/(960*540))))
    for i=1,count do
      local speed=26+(i*.618033989%1)*45
      local distance=t*speed+(i*.56984029%1)*(h+160)
      local cycle=math.floor(distance/(h+160))
      local p=ready[1+math.floor(((i*.618033989+cycle*.414213562)%1)*#ready)]
      local iw,ih=p.image:getDimensions()
      local size=p.size or math.max(iw,ih)
      local scale=(38+(i%4)*9)/size
      local x=(i*.754877666%1)*w+math.sin(t*.35+i)*12
      local y=distance%(h+160)-80
      g.setColor(1,1,1,alpha*(.65+.35*(i%3)/2))
      local pw,ph=p.size or iw,p.size or ih
      if p.quad then g.draw(p.image,p.quad,x,y,0,scale,scale,pw/2,ph/2)
      else g.draw(p.image,x,y,0,scale,scale,pw/2,ph/2) end
    end
  end
  return api
end
