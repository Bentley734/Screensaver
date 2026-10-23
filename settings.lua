return function(mod, buildRows)
  local ID='screensaver:settings'
  local TITLE='SCREENSAVER'
  local function open(game)
    if mod.generation==3 then
      local name=({ruby=true,sapphire=true,emerald=true})[require('src.core.GameVersion').get()]
        and 'src.ui.game3.rse.option_menu' or 'src.ui.game3.option_menu'
      local menu=require(name)
      local pages=menu._pages or (menu._st and menu._st.pages)
      if type(pages)~='table' then return false end
      pages[#pages+1]={title=TITLE,rows=buildRows({}),index=1,scroll=0}
      menu.cursor=1
      return true
    end
    mod.ui.push(game,ID)
    return true
  end
  if mod.generation~=3 then
    mod.content.screens:register(ID,{isModOptions=true,new=function(game)
      local controls=buildRows({})
      local menu
      local function refresh()
        local items={}
        for _,row in ipairs(controls) do
          items[#items+1]={id=row.id,label=row.label,right=row.value(),control=row}
        end
        items[#items+1]={id=ID..':back',label='BACK',back=true}
        menu.items=items
      end
      local function step(item,dir)
        if item and item.control then item.control.step(game,dir);refresh() end
      end
      menu=mod.ui.ListMenu.new(game,TITLE,{}, {wrap=true,keyRepeat=true,
        onChoose=function(item,m)
          if item and item.back then m:close() else step(item,1) end
        end})
      refresh()
      local update=menu.update
      menu.update=function(self,dt)
        local input=self.game.input
        local item=self.items[self.index]
        if item and item.control then
          if input:wasPressed('left') then step(item,-1);return end
          if input:wasPressed('right') then step(item,1);return end
        end
        return update(self,dt)
      end
      return menu
    end})
  end
  return {root=function(out,game)
    if type(out)~='table' then return out end
    for _,row in ipairs(out) do if row.id==ID then return out end end
    out[#out+1]={id=ID,label=TITLE,text=function()return 'OPEN' end,
      value=function()return 'OPEN' end,activate=function(ctx)open(ctx and (ctx.game or ctx) or game)end}
    return out
  end}
end

