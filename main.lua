return function(mod)
  local ID='screensaver'
  local names={'STAR WARP','AURORA VEIL','NEON POKEBALLS','PRISM GARDEN','MOONLIT RIPPLES','MATRIX RAIN','POKEMON RAIN'}
  local matrixNames={'GREEN','AMBER','CYAN','RED','VIOLET','WHITE','RAINBOW FLOW','OCEAN FLOW','SUNSET FLOW','AURORA FLOW'}
  -- Keep the original saved indices stable when adding shorter delays.
  local delays={15,30,60,120,300,600,1,5,10}
  local delayOrder={7,8,9,1,2,3,4,5,6}
  local speeds={.5,1,1.5,2}
  local shades={0,.25,.5,.75,1}
  local defaults={enabled=1,effect=1,delay=3,speed=2,pause=1,shade=3,matrix=1}
  local limits={enabled=1,effect=7,delay=9,speed=4,pause=1,shade=5,matrix=10}
  local function setting(k)
    local n=tonumber(mod.options:get(k)) or tonumber(mod.save:get(k)) or defaults[k]
    if n~=n or n==math.huge or n==-math.huge then n=defaults[k] end
    return math.max((k=='enabled' or k=='pause') and 0 or 1,math.min(limits[k],math.floor(n)))
  end
  local idle,active,time,fade=0,false,0,0
  local keys,buttons,axes,swallowedKeys,swallowedButtons={},{},{},{},{}
  local waking,previewRequested=false,false
  local pointers={}
  local function module(name)return assert(load(assert(mod:read(name..'.lua')),'@screensaver/'..name..'.lua'))()end
  local rain=module('pokemon_rain')(mod,love.graphics)
  local matrix=module('matrix')(love.graphics)
  local draw=module('effects')(love.graphics,{matrix=matrix,pokemon=rain.draw})
  local loadedSave
  local function wake()
    local was=active
    idle,active,time,fade=0,false,0,0
    if was then waking=true;rain.reset() end
    return was
  end
  mod.events:on('save.loaded',function(payload)
    loadedSave=payload and payload.save
    wake();waking=false;previewRequested=false
  end)
  mod.events:on('save.created',function()
    loadedSave=nil;wake();waking=false;previewRequested=false
  end)
  local function inLoadedGame(game)
    if not game or not loadedSave then return false end
    if mod.generation==3 then return game.session==loadedSave and game.phase=='field' end
    if game.save~=loadedSave then return false end
    if mod.generation==2 then return game.phase=='play' end
    -- Gen 1 retains its save at the title. Require the actual overworld
    -- beneath gameplay/menu states rather than trusting that save exists.
    for _,state in ipairs(game.stack and game.stack.states or {}) do
      if game.overworld and state==game.overworld then return true end
    end
    return false
  end
  local function held(game)
    if next(keys) or next(buttons) or next(axes) or next(pointers) then return true end
    local input=game and game.input
    if input and input.isDown then
      for _,k in ipairs({'up','down','left','right','a','b','start','select'}) do
        if input:isDown(k) then return true end
      end
    end
    return false
  end
  mod.hooks:wrap('input.key',function(nextFn,game,ev)
    local key=ev.key
    if ev.phase=='pressed' then
      keys[key]=true
      if wake() then swallowedKeys[key]=true;return true end
      if swallowedKeys[key] then return true end
    else
      keys[key]=nil;wake()
      if swallowedKeys[key] then swallowedKeys[key]=nil;return true end
    end
    return nextFn(game,ev)
  end,900)
  mod.hooks:wrap('input.gamepad',function(nextFn,game,ev)
    local id=tostring(ev.joystick)..':'..tostring(ev.button or ev.axis)
    if ev.phase=='axis' then
      -- Resting triggers report -1 on some devices; only sticks wake on axes.
      if ev.axis=='leftx' or ev.axis=='lefty' or ev.axis=='rightx' or ev.axis=='righty' then
        axes[id]=math.abs(ev.value or 0)>.25 and true or nil
        if axes[id] and wake() then return true end
        if waking then return true end
      end
    elseif ev.phase=='pressed' then
      buttons[id]=true
      if wake() then swallowedButtons[id]=true;return true end
      if swallowedButtons[id] then return true end
    else
      buttons[id]=nil;wake()
      if swallowedButtons[id] then swallowedButtons[id]=nil;return true end
    end
    return nextFn(game,ev)
  end,900)
  mod.hooks:wrap('input.pointer',function(nextFn,game,ev)
    local id=ev.id or ev.source or 'mouse'
    if ev.phase=='pressed' then pointers[id]=true
    elseif ev.phase=='released' or ev.phase=='cancelled' then pointers[id]=nil end
    local moved=ev.phase~='moved' or math.abs(ev.dx or 0)+math.abs(ev.dy or 0)>1
    if moved and wake() then return true end
    if waking then return true end
    return nextFn(game,ev)
  end,900)
  mod.hooks:wrap('input.wheel',function(nextFn,game,dy)
    if wake() or waking then return true end
    return nextFn(game,dy)
  end,900)
  mod.hooks:wrap('core.update',function(nextFn,game,dt)
    -- Frame time, never game speed or fixed simulation ticks.
    dt=math.max(0,tonumber(dt) or 0)
    if not inLoadedGame(game) then
      wake();waking=false;previewRequested=false
      return nextFn(game,dt)
    end
    if setting('enabled')==0 then wake();waking=false;return nextFn(game,dt) end
    if love.window and love.window.hasFocus and not love.window.hasFocus() then
      wake();keys={};buttons={};axes={};pointers={};swallowedKeys={};swallowedButtons={}
      return nextFn(game,dt)
    end
    if held(game) then wake() end
    if waking then
      -- Virtual controls bypass raw hooks. Discard their queued edges while
      -- waiting for release, so a wake tap cannot confirm an in-game choice.
      if game.input and game.input.step then game.input:step();game.input:step() end
      if not held(game) then waking=false end
      return -- Drain wake input before permitting another simulation frame.
    end
    if not held(game) then idle=idle+dt end
    if previewRequested and not held(game) then
      previewRequested=false;idle=delays[setting('delay')]
    end
    if idle>=delays[setting('delay')] then active=true end
    if active then
      time=time+dt*speeds[setting('speed')];fade=math.min(1,fade+dt/.8)
      if setting('effect')==7 then rain.update(game,dt) end
      if setting('pause')==1 then return end
    end
    return nextFn(game,dt)
  end,-10000) -- Sprite providers must advance before we pause game:update.
  mod.hooks:wrap('render.hud',function(nextFn,game,viewport)
    local result=nextFn(game,viewport)
    if active and inLoadedGame(game) then draw(setting('effect'),time,viewport.width,viewport.height,fade,shades[setting('shade')],setting('matrix')) end
    return result
  end,900)
  local function persist(ctx,k,value)
    local game=ctx.game or ctx
    local options=ctx.options or game.options or (game.save and game.save.options)
    if not options then return false end
    options.modOptions=options.modOptions or {}
    local bucket=options.modOptions[ID] or {}
    for key in pairs(defaults) do bucket[key]=setting(key) end
    bucket[k]=value;options.modOptions[ID]=bucket
    if game.mods then game.mods.modOptions[ID]=bucket end
    if game.save and game.save.options then game.save.options.modOptions=options.modOptions end
    mod.save:set(k,value);wake()
    if game.writeOptions then game:writeOptions() end
    return false
  end
  local function rows(out)
    local function add(k,label,value)
      out[#out+1]={id=ID..':'..k,label=label,value=value,step=function(ctx,dir)
        if k=='delay' then
          for i,index in ipairs(delayOrder) do
            if index==setting(k) then
              return persist(ctx,k,delayOrder[1+(i-1+(dir and dir<0 and -1 or 1))%#delayOrder])
            end
          end
        end
        local low=(k=='enabled' or k=='pause') and 0 or 1
        return persist(ctx,k,low+(setting(k)-low+(dir and dir<0 and -1 or 1))%(limits[k]-low+1))
      end}
    end
    add('enabled','SCREENSAVER',function()return setting('enabled')==1 and 'ON' or 'OFF'end)
    add('effect','EFFECT',function()return names[setting('effect')]end)
    add('delay','IDLE DELAY',function()return tostring(delays[setting('delay')])..' SEC'end)
    add('speed','ANIMATION SPEED',function()return tostring(speeds[setting('speed')])..'X'end)
    add('pause','PAUSE GAME',function()return setting('pause')==1 and 'ON' or 'OFF'end)
    add('shade','BACKGROUND DIM',function()return tostring(shades[setting('shade')]*100)..'%'end)
    add('matrix','MATRIX COLOR',function()return matrixNames[setting('matrix')]end)
    local function preview(ctx)
      if not inLoadedGame(ctx.game or ctx) then return false end
      if setting('enabled')==0 then persist(ctx,'enabled',1) end
      previewRequested=true;return false
    end
    out[#out+1]={id=ID..':preview',label='PREVIEW',value=function()return 'START'end,
      step=preview,activate=preview}
    return out
  end
  local settings=assert(load(assert(mod:read('settings.lua')),'@screensaver/settings.lua'))()(mod,rows)
  local marker=function(nextFn,game,out)return settings.root(nextFn(game,out),game)end
  mod.hooks:wrap('ui.options.rows',marker,900)
  -- Gen 3 builds option rows outside the shared hook. Check hook ownership so
  -- disabling/reloading the mod leaves no active behavior in this adapter.
  if mod.generation==3 then
    local Rows=require('src.ui.game3.option_rows')
    local native=Rows.build
    Rows.build=function(ctx,...)
      local out=native(ctx,...)
      local runtime=require('src.mods.Runtime')
      for _,entry in ipairs(runtime.hooks.chains['ui.options.rows'] or {}) do
        if entry.owner==mod.id and entry.callback==marker then return settings.root(out,ctx and ctx.game) end
      end
      return out
    end
  end
end
