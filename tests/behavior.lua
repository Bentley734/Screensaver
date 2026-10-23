package.path='./?.lua;./?/init.lua;'..package.path
love=require('tests.love_stub')
local draws=0
local circleLines=0
for _,name in ipairs({'origin','setShader','setScissor','setBlendMode','scale','rotate','translate','setLineWidth','ellipse','polygon','line','circle','rectangle'}) do
  love.graphics[name]=function()draws=draws+1 end
end
love.graphics.circle=function(mode)
  draws=draws+1
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
update(59);assert(not render(),'does not start early')
update(5);assert(render(),'starts after idle deadline')
local paused=ticks;update(8);assert(ticks==paused,'pauses simulation')
for i=1,5 do options.effect=i;assert(render(),'effect renders')end
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
  assert(#game.stack.topScreen.items==8,'seven controls and back')
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
assert(#loader.errors==0,table.concat(loader.errors,'\n'))
R.hooks:removeOwner('screensaver');R.events:removeOwner('screensaver')
local after=ticks;update(1);assert(ticks==after+1,'unload restores normal update')
print('PASS '..arg[1]..': loader, five effects, deadline, pause, held input, wake, focus, disable, unload')
