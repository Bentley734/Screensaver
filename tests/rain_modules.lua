-- Exercise the production text batching and palette clock without GPU pixels.
local batches,colors=0,{}
local text={clear=function()colors={}end,add=function(_,value)colors[#colors+1]=value[1]end}
local g={newFont=function()return {}end,newText=function()return text end,
  setColor=function()end,draw=function()batches=batches+1 end}
local matrix=assert(load(files['mods/screensaver/matrix.lua']))()(g)
local function rgb(palette,t)
  matrix(t,960,540,1,palette)
  assert(#colors>100,'dense Matrix glyph field')
  local sum={0,0,0}
  for _,c in ipairs(colors)do for i=1,3 do sum[i]=sum[i]+c[i]end end
  return sum
end
for palette=1,6 do
  matrix(1,960,540,1,palette)
  for _,c in ipairs(colors)do assert(c[4]>=0 and c[4]<=1)end
end
for palette=7,10 do
  local a,b=rgb(palette,1),rgb(palette,3)
  assert(math.abs(a[1]-b[1])+math.abs(a[2]-b[2])+math.abs(a[3]-b[3])>1,'gradient changes over time')
end
local before=batches;matrix(4,1920,540,.5,7)
assert(batches==before+1,'one text batch per Matrix draw')
for _,c in ipairs(colors)do assert(c[4]<=.5,'fade alpha applies to glyphs')end
print('PASS Matrix: batched glyphs, four animated gradients, fade alpha')
local staticImage={getDimensions=function()return 64,64 end}
local images,notices=0,0
local rainGraphics={setColor=function()end,printf=function()notices=notices+1 end,
  setLineWidth=function()end,ellipse=function()end,line=function()end,circle=function()end,rectangle=function()end,
  draw=function(img)assert(img==staticImage,'static sprite is not replaced');images=images+1 end}
local rain=assert(load(files['mods/screensaver/pokemon_rain.lua']))()({generation=3},rainGraphics)
local game={data={gen3Pokemon={_names={[1]='BULBASAUR'},frontPic=function()return {image=staticImage}end}}}
rain.update(game,.1);rain.draw(1,960,540,1)
rain.update(game,.1);rain.draw(2,1920,540,1)
assert(images==24+48,'static sprites remain static at adaptive density')
for _,mode in ipairs({'orbit','constellation','mosaic'}) do
  local before=images
  rain.draw(1,960,540,1,mode);rain.draw(2,1920,540,1,mode)
  assert(images>before,'static art is rendered by '..mode)
end
rain.reset();rain.update({data={gen3Pokemon={_names={}}}},.1);rain.draw(0,960,540,1)
assert(notices==1,'missing artwork degrades to a loading notice')
print('PASS Pokemon rain: static art, adaptive density and missing-art fallback')
local recorded={}
local classicGraphics={push=function()end,pop=function()end,setLineWidth=function()end}
local function record(...)
  for _,v in ipairs({...}) do
    if type(v)=='number' then
      assert(v==v and math.abs(v)<1e8,'finite classic geometry')
      if #recorded<1000 then recorded[#recorded+1]=string.format('%.4f',v) end
    elseif type(v)=='table' then record((unpack or table.unpack)(v)) end
  end
end
for _,name in ipairs({'translate','scale','rotate','line','polygon','circle','ellipse','rectangle'}) do classicGraphics[name]=record end
classicGraphics.setColor=function(r,g,b,a)assert(a>=0 and a<=.5,'classic fade alpha');record(r,g,b,a)end
local classic=assert(load(files['mods/screensaver/classic.lua']))()(classicGraphics)
for id=13,17 do
  recorded={};classic(id,1,1920,540,.5);local a=table.concat(recorded,',')
  assert(#recorded>20,'classic draws geometry '..id)
  recorded={};classic(id,2,1920,540,.5);assert(a~=table.concat(recorded,','),'classic animates '..id)
end
print('PASS five classic effects: animated geometry, finite coordinates and fade alpha')
