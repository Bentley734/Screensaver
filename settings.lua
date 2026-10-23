return function(mod, buildRows, buildRandomRows)
  local ID='screensaver:settings'
  local TITLE='SCREENSAVER'
  local pages={{id=ID,title=TITLE,build=buildRows},
    {id=ID..':random',title='RANDOM EFFECTS',build=buildRandomRows}}
  local function open(game,page)
    page=page or pages[1]
    if mod.generation==3 then
      local name=({ruby=true,sapphire=true,emerald=true})[require('src.core.GameVersion').get()]
        and 'src.ui.game3.rse.option_menu' or 'src.ui.game3.option_menu'
      local menu=require(name)
      local pages=menu._pages or (menu._st and menu._st.pages)
      if type(pages)~='table' then return false end
      pages[#pages+1]={title=page.title,rows=page.build({}),index=1,scroll=0}
      menu.cursor=1
      return true
    end
    mod.ui.push(game,page.id)
    return true
  end
  if mod.generation~=3 then
    for _,spec in ipairs(pages) do
    local page=spec
    mod.content.screens:register(page.id,{isModOptions=true,new=function(game)
      local controls=page.build({})
      local menu
      local function refresh()
        local items={}
        for _,row in ipairs(controls) do
          items[#items+1]={id=row.id,label=row.label,right=row.value(),control=row}
        end
        items[#items+1]={id=page.id..':back',label='BACK',back=true}
        menu.items=items
      end
      local function step(item,dir)
        if item and item.control then item.control.step(game,dir);refresh() end
      end
      menu=mod.ui.ListMenu.new(game,page.title,{}, {wrap=true,keyRepeat=true,
        onChoose=function(item,m)
          if item and item.back then m:close() else step(item,1) end
        end})
      refresh()
      local update=menu.update
      menu.update=function(self,dt)
        -- Returning from a child page must refresh the parent's selected count.
        for _,row in ipairs(self.items) do
          if row.control then row.right=row.control.value() end
        end
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
  end
  return {random=function(game)return open(game,pages[2])end,root=function(out,game)
    if type(out)~='table' then return out end
    for _,row in ipairs(out) do if row.id==ID then return out end end
    out[#out+1]={id=ID,label=TITLE,text=function()return 'OPEN' end,
      value=function()return 'OPEN' end,activate=function(ctx)open(ctx and (ctx.game or ctx) or game)end}
    return out
  end}
end

