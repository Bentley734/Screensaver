"""Run from the workspace: python Screensaver/tools/test.py [engine-directory]."""
from pathlib import Path
import os, sys
root=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(root/'.tools/python'))
engine=root/(sys.argv[1] if len(sys.argv)>1 else 'gen1recomp-0.3.54')
os.chdir(engine)
for runtime in ('luajit21','lua53'):
    LuaRuntime=__import__('lupa.'+runtime,fromlist=['LuaRuntime']).LuaRuntime
    for version in ('red','blue','yellow','gold','silver','crystal','firered','leafgreen','ruby','sapphire','emerald'):
        lua=LuaRuntime(unpack_returned_tuples=True)
        lua.execute('unpack=unpack or table.unpack')
        if runtime=='lua53':
            lua.execute('''package.preload.bit=function()
              return {band=function(a,b)return a & b end,bor=function(a,b)return a | b end,
                bxor=function(a,b)return a ~ b end,bnot=function(a)return ~a end,
                lshift=function(a,b)return (a << b) & 0xffffffff end,
                rshift=function(a,b)return (a & 0xffffffff) >> b end,
                rol=function(a,b)return ((a << b) | ((a & 0xffffffff) >> (32-b))) & 0xffffffff end,
                tobit=function(a)return a & 0xffffffff end}
            end; bit32=require('bit')''')
        lua.globals().arg=lua.table_from([version])
        lua.globals().files=lua.table_from({'mods/screensaver/'+p.name:p.read_text(encoding='utf-8-sig') for p in (root/'Screensaver').iterdir() if p.is_file()})
        lua.execute((root/'Screensaver/tests/behavior.lua').read_text())
    print('PASS runtime '+runtime)
