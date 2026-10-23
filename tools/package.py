"""Validate and build the single installable release ZIP; publish no other assets."""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys,tempfile,zipfile
mod=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--engine',type=Path,default=mod.parent/'gen1recomp-0.3.54')
parser.add_argument('--output',type=Path)
args=parser.parse_args()
version=json.loads((mod/'manifest.json').read_text(encoding='utf-8-sig'))['version']
output=args.output or mod.parent/f'Screensaver-v{version}.zip'
with tempfile.TemporaryDirectory(prefix='screensaver-package-') as temporary:
    package=Path(temporary)/'screensaver.modpkg'
    subprocess.run([sys.executable,str(args.engine/'tools/modkit.py'),'pack',str(mod),'-o',str(package)],check=True)
    with zipfile.ZipFile(package) as source,zipfile.ZipFile(output,'w',zipfile.ZIP_DEFLATED) as target:
        for name in source.namelist():
            if not name.startswith('.modkit/'):
                target.writestr('screensaver/'+name,source.read(name))
with zipfile.ZipFile(output) as result:
    assert result.testzip() is None
    assert json.loads(result.read('screensaver/manifest.json'))['version']==version
print(f'Release asset: {output.resolve()}')
print('SHA-256 (local verification only): '+hashlib.sha256(output.read_bytes()).hexdigest())
