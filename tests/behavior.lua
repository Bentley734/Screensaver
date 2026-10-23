package.path='./?.lua;./?/init.lua;'..package.path
love=require('tests.love_stub')
local draws=0
local circleLines=0
local circleCount,waveLines=0,0
local glyphCount,imageFrames=0,{}
for _,name in ipairs({'origin','setShader','setScissor','setBlendMode','scale','rotate','translate','setLineWidth','ellipse','polygon','line','circle','rectangle'}) do
  love.graphics[name]=function()draws=draws+1 end
end
love.graphics.line=function()draws=draws+1;waveLines=waveLines+1 end
love.graphics.print=function(text)if #tostring(text)==1 then glyphCount=glyphCount+1 end end
love.graphics.draw=function(img)
  draws=draws+1
  if type(img)=='table' and img.fixtureFrame then imageFrames[img.fixtureFrame]=true end
end
love.graphics.circle=function(mode)
  draws=draws+1
  circleCount=circleCount+1
  if mode=='line' then circleLines=circleLines+1 end
end
love.window={hasFocus=function()return true end}
local GV=require('src.core.GameVersion');GV.set(arg[1])
local fs={}
function fs.getInfo(p)
  if p=='mods' or p=='mods/screensaver' then return {type='directory'} end
  if files[p] then return {type='file'} end
end
function fs.getDirectoryItems(p)if p=='mods' then return {'screensaver'}end;return {}end
function fs.read(p)return files[p]end
function fs.write(p,v)files[p]=v;return true end
function fs.createDirectory()return true end
function fs.load(p)return (loadstring or load)(files[p] or '')end
local Loader=require('src.mods.Loader')
local loader=Loader.new({fs=fs,generation=GV.generation(),version=arg[1],dev=false})
local data={pokemon={},moves={},items={},maps={},tilesets={}}
loader:load(data)
assert(loader.mods.screensaver.state=='loaded',table.concat(loader.errors,'\n'))
local R=require('src.mods.Runtime')
local options={enabled=1,delay=1,effect=1,speed=2,pause=1}
loader.modOptions.screensaver=options
local game={data=data,stack={push=function(self,s)self.topScreen=s end},options={modOptions={screensaver=options}},mods=loader,input={isDown=function()return false end},writeOptions=function()end}
game.save={};game.session=game.save;game.overworld={}
local function gameplay(on)
  game.phase=on and (GV.generation()==3 and 'field' or 'play') or 'boot'
  game.stack.states=on and {game.overworld} or {{screenId='TitleState'}}
end
local ticks=0
local function update(n)
  for _=1,n do R.call('core.update',function()ticks=ticks+1 end,game,.25)end
end
local function render()
  local before=draws
  R.call('render.hud',function()end,game,{width=960,height=540})
  return draws>before
end
local function event(h,ev)
  local passed=false
  R.call(h,function()passed=true end,game,ev)
  return passed
end
gameplay(false);update(3000);assert(not render(),'no screensaver during intro/title even with save skeleton')
R.emit('save.created',{save=game.save});gameplay(true)
update(3000);assert(not render(),'new game does not count as loaded save')
gameplay(false);R.emit('save.loaded',{save=game.save})
update(3000);assert(not render(),'loaded save preview on boot screen is not gameplay')
gameplay(true)
update(59);assert(not render(),'does not start early after entering loaded game')
update(5);assert(render(),'starts after idle deadline')
local paused=ticks;update(8);assert(ticks==paused,'pauses simulation')
for i=1,5 do options.effect=i;assert(render(),'effect renders')end
options.effect=2
local circlesBeforeAurora,linesBeforeAurora=circleCount,waveLines
assert(render())
assert(circleCount==circlesBeforeAurora and waveLines>linesBeforeAurora,'Aurora is animated waves only: no moon or stars')
options.effect=3
local circlesBefore=circleLines
assert(render());assert(circleLines-circlesBefore==24*3,'24 Pokeballs at 16:9')
circlesBefore=circleLines
R.call('render.hud',function()end,game,{width=1920,height=540})
assert(circleLines-circlesBefore==48*3,'48 Pokeballs at 32:9')
assert(not event('input.key',{phase='pressed',key='z'}),'wake key consumed')
assert(not render(),'wake hides immediately')
update(70);assert(not render(),'held key prevents activation')
assert(not event('input.key',{phase='released',key='z'}),'matching release consumed')
update(2);assert(ticks>paused,'simulation resumes')
update(65);assert(render())
assert(not event('input.gamepad',{phase='axis',joystick='p1',axis='leftx',value=.8}))
assert(not render(),'stick wakes')
event('input.gamepad',{phase='axis',joystick='p1',axis='leftx',value=0});update(2)
update(65);assert(render())
event('input.pointer',{phase='moved',source='mouse',dx=5,dy=0});assert(not render(),'mouse wakes')
update(2);options.pause=0;update(65);assert(render())
local running=ticks;update(4);assert(ticks==running+4,'optional live simulation')
options.enabled=0;update(1);assert(not render(),'disable exits')
options.enabled=1;options.pause=1
local rows=R.call('ui.options.rows',function(_,out)return out end,game,{})
assert(#rows==1 and rows[1].id=='screensaver:settings','settings entry')
-- Exercise settings with the actual registered list screen for Gen 1/2.
if GV.generation()~=3 then
  rows[1].activate(game)
  assert(#game.stack.topScreen.items==9,'eight controls and back')
  local controls=game.stack.topScreen.items
  for _,expected in ipairs({{9,'10 SEC'},{8,'5 SEC'},{7,'1 SEC'},{6,'600 SEC'}}) do
    controls[3].control.step(game,-1)
    assert(loader.modOptions.screensaver.delay==expected[1],'delay saved index')
    assert(controls[3].control.value()==expected[2],'delay label and chronological wrap')
  end
  controls[3].control.step(game,1)
  assert(loader.modOptions.screensaver.delay==7,'600 wraps forward to 1 second')
  for _=1,3 do controls[3].control.step(game,1) end
  assert(loader.modOptions.screensaver.delay==1,'returns to original 15-second setting')
  controls[5].control.step(game,1)
  assert(loader.modOptions.screensaver.pause==0,'pause choice persisted')
  controls[6].control.step(game,-1)
  assert(loader.modOptions.screensaver.shade==2,'background dim choice persisted')
  controls[7].control.step(game,1)
  assert(loader.modOptions.screensaver.matrix==2,'Matrix color saved')
  controls[8].control.step(game,1)
  update(1);assert(render(),'preview activates without idle delay')
  event('input.key',{phase='pressed',key='x'})
  event('input.key',{phase='released',key='x'});update(2)
else
  require('src.core.game3.rom_text').at=function(_,i)return 'FIXTURE '..tostring(i)end
  local built=require('src.ui.game3.option_rows').build({game=game,options=game.options})
  local found=false
  for _,r in ipairs(built)do if r.id=='screensaver:settings' then found=true end end
  assert(found,'Gen 3 options adapter')
end
update(65);assert(render())
love.window.hasFocus=function()return false end
update(1);assert(not render(),'focus loss dismisses')
love.window.hasFocus=function()return true end
update(2);assert(not render(),'focus recovery restarts timer')
update(65);assert(render())
for slot,seconds in ipairs({15,30,60,120,300,600,1,5,10}) do
  loader.modOptions.screensaver.delay=slot
  event('input.key',{phase='pressed',key='x'})
  event('input.key',{phase='released',key='x'});update(1)
  update(seconds*4-1);assert(not render(),'no early activation for '..seconds..' seconds')
  update(1);assert(render(),'activation at '..seconds..' seconds')
end
options=loader.modOptions.screensaver
options.effect=6
for palette=1,10 do
  options.matrix=palette
  local before=glyphCount
  assert(render());assert(glyphCount>before,'Matrix glyphs for palette '..palette)
end
-- Animated sprite fixture: provider changes frames while the game is paused.
local frameTick=0
local frameA={fixtureFrame='A',getDimensions=function()return 64,64 end}
local frameB={fixtureFrame='B',getDimensions=function()return 64,64 end}
local function fixtureFrame()return frameTick%2==0 and frameA or frameB end
R.hooks:wrap('core.update',function(nextFn,g,dt)frameTick=frameTick+1;return nextFn(g,dt)end,0,'sprite-fixture')
if GV.generation()==3 then
  data.gen3Pokemon={_names={[1]='BULBASAUR',[2]='IVYSAUR'},frontPic=function()return {image=fixtureFrame()}end}
else
  data.pokemon={BULBASAUR={spriteFront='fixture/bulbasaur'},IVYSAUR={spriteFront='fixture/ivysaur'}}
  local Assets=require('src.render.Assets')
  Assets.image=function(path)assert(path:find('selected/'),'current sprite path hook used');return frameA end
  R.hooks:wrap('pokemon.sprite',function(_,path)return 'selected/'..path end,0,'sprite-fixture')
  R.hooks:wrap('battle.mon_pic',function(_,img,ctx)
    assert(ctx.mon.species and ctx.side=='front');return fixtureFrame()
  end,0,'sprite-fixture')
end
event('input.key',{phase='pressed',key='x'})
event('input.key',{phase='released',key='x'});update(1)
options.effect=7;options.delay=7;options.pause=1
update(4);local simulationBefore=ticks
for _=1,4 do update(1);render() end
assert(ticks==simulationBefore,'game remains paused during animated rain')
assert(imageFrames.A and imageFrames.B,'sprite animation advances while paused')
gameplay(false)
assert(not render(),'title blocks stale overlay before another update')
local beforeTitle=ticks;update(100)
assert(ticks==beforeTitle+100 and not render(),'title remains unpaused with no activation')
game.save={};game.session=game.save
R.emit('save.created',{save=game.save});gameplay(true)
update(100);assert(not render(),'new game after loaded session is blocked')
R.emit('save.loaded',{save=game.save})
update(3);assert(not render(),'loading another save starts a fresh one-second timer')
update(1);assert(render(),'loaded game activates after full idle delay')
R.hooks:removeOwner('sprite-fixture')
assert(#loader.errors==0,table.concat(loader.errors,'\n'))
R.hooks:removeOwner('screensaver');R.events:removeOwner('screensaver')
local after=ticks;update(1);assert(ticks==after+1,'unload restores normal update')
print('PASS '..arg[1]..': seven effects, ten Matrix palettes, live animated sprite providers, nine delays, pause and wake')
