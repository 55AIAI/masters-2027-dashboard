import json,sys
tpl=open(sys.argv[1],encoding='utf-8').read()
cat=json.load(open(sys.argv[2],encoding='utf-8'))
js=json.dumps(cat,ensure_ascii=False,indent=1).replace('</','<\\/')
assert tpl.count('/*__CATALOG__*/')==1
open(sys.argv[3],'w',encoding='utf-8').write(tpl.replace('/*__CATALOG__*/',js))
