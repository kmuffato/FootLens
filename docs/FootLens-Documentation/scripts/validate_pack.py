#!/usr/bin/env python3
"""Validate documentation/reference examples only. No application or DB claim."""
from pathlib import Path
from decimal import Decimal, getcontext
import json, re, math, sys
ROOT=Path(__file__).resolve().parents[1]
checks=[]
def check(name, fn):
 try:
  detail=fn();checks.append({'name':name,'status':'Passed','detail':detail})
 except Exception as ex:
  checks.append({'name':name,'status':'Failed','detail':str(ex)})
def links():
 count=0
 for p in ROOT.rglob('*.md'):
  s=re.sub(r'```[\s\S]*?```','',p.read_text())
  for link in re.findall(r'\[[^\]]*\]\(([^)]+)\)',s):
   if re.match(r'^[a-zA-Z]+:',link) or link.startswith('#'):continue
   target=(p.parent/link.split('#')[0]).resolve()
   assert target.is_file(),f'{p.relative_to(ROOT)} -> {link}'
   count+=1
 return f'{count} internal file links resolved; remote URLs and rendered anchors not checked'
def jsons():
 paths=list(ROOT.rglob('*.json'))
 for p in paths:json.loads(p.read_text())
 packet=json.loads((ROOT/'templates/task-packet.json').read_text())
 assert all(k in packet for k in ['taskId','status','read','acceptance','commands','connectors','budget'])
 assert packet['budget']['maxRepairCycles']==2
 return f'{len(paths)} JSON documents parse; task packet required fields checked'
def tasks():
 a=json.loads((ROOT/'reference/backlog.json').read_text())['tasks'];d={t['id']:t for t in a}
 assert len(a)==len(d)==34
 active=set();done=set()
 def visit(x):
  assert x in d,f'Unknown dependency {x}'
  assert x not in active,f'Cycle {x}'
  if x in done:return
  active.add(x)
  for y in d[x]['dependencies']:visit(y)
  active.remove(x);done.add(x)
 for x in d:visit(x)
 covered=set(r for t in a for r in t['requirements'])
 assert covered=={f'R{i:02}' for i in range(1,21)},covered
 for t in a:
  assert t['acceptance'] and t['tests'] and t['story'] and t['implementationTasks']
  assert t['status']=='NotStarted'
 assert len([x for x in a if x['priority']=='Must'])==32
 return '34 tasks, 32 Must, acyclic dependencies; all R01–R20 covered with acceptance/tests'
def sqlrefs():
 sql=(ROOT/'reference/schema.sql').read_text()
 names=re.findall(r'CREATE TABLE ([a-z_]+\.[a-z_]+)',sql)
 assert len(names)==len(set(names))
 refs=re.findall(r'REFERENCES ([a-z_]+\.[a-z_]+)',sql)
 assert set(refs)<=set(names)
 declared=json.loads((ROOT/'reference/table-catalog.json').read_text())
 assert {t['table'] for t in declared}==set(names)
 for stmt in sql.split('CREATE TABLE ')[1:]:
  table=stmt.split(' ',1)[0]
  block=stmt.split('\n);',1)[0]
  for field in ['id uuid PRIMARY KEY','created_at','created_by','correlation_id']:assert field in block,(table,field)
 assert sql.count('BEGIN;')==sql.count('COMMIT;')==1
 return f'{len(names)} table declarations, {len(refs)} FK references and common audit fields checked statically; SQL NOT executed or parsed by PostgreSQL'
def layout():
 paths=list(ROOT.rglob('*.md'))
 diagrams=0
 for p in paths:
  lines=p.read_text().splitlines()
  assert sum(l.startswith('```') for l in lines)%2==0,f'Unbalanced fences: {p}'
  diagrams+=sum(l.startswith('```mermaid') for l in lines)
 assert len(list((ROOT/'prompts').glob('[0-9]*.md')))==14
 assert len(list((ROOT/'loops').glob('L*.md')))==10
 assert len(list((ROOT/'docs/adr').glob('ADR-*.md')))==13
 return f'{len(paths)} Markdown files, {diagrams} Mermaid blocks; fences and expected prompt/loop/ADR counts checked; Mermaid not rendered'
def math_examples():
 getcontext().prec=60;D=Decimal
 v=json.loads((ROOT/'reference/golden-vectors.json').read_text())
 odds=[D(x) for x in v['odds']['decimal']];q=[1/x for x in odds];Q=sum(q)
 def close(a,b):assert abs(a-b)<D('1e-50'),(str(a),str(b))
 close(Q,D(v['odds']['bookSum']));close(Q-1,D(v['odds']['overround']))
 fair=[x/Q for x in q]
 for a,b in zip(fair,v['odds']['fair']):close(a,D(b))
 close(D('.52')-fair[0],D(v['odds']['homeValueDelta']))
 close(D('.52')*2-1,D(v['odds']['grossBinaryEV']))
 close(D('.52')*D('.98')-D('.48'),D(v['odds']['netBinaryEV']))
 close(D(-2).exp(),D(v['poisson']['p00']))
 close(1-5*D(-2).exp(),D(v['poisson']['over2_5']))
 close((1-D('-1.2').exp())*(1-D('-.8').exp()),D(v['poisson']['btts']))
 p=[D(x) for x in v['metrics']['probabilities']]
 close(sum((x-(1 if i==0 else 0))**2 for i,x in enumerate(p)),D('.38'))
 close(-p[0].ln(),D(v['metrics']['logLoss']))
 # Independent hand-contract settlement: compare counts/differences to quarter-unit half components.
 for t in v['settlement']:
  line=t['lineQuarter'];components=[line] if line%2==0 else [line-1,line+1]
  values=[]
  for c in components:
   if t['market']=='HomeHandicap':delta=t['goalDifference']*4+c
   else:delta=(t['total']*4-c)*(1 if t['market']=='Over' else -1)
   values.append(D(t['odds'])-1 if delta>0 else (D(-1) if delta<0 else D(0)))
  close(sum(values)/len(values),D(t['expectedNet']))
 # Source probability table display agrees with exact values.
 body=(ROOT/'PROBABILITY_ENGINE.md').read_text()
 for n in fair:assert f'{n:.6f}' in body
 # Conditional-binomial allocation sums to each FT atom.
 for n in range(15):
  for f in [.1,.45,.8]:assert abs(sum(math.comb(n,k)*f**k*(1-f)**(n-k) for k in range(n+1))-1)<1e-12
 return 'High-precision odds/EV/Poisson/Brier/log-loss examples, five settlement vectors and conditional-period normalization verified; no C# engine tested'
for name,fn in [('Internal links',links),('JSON and packet fields',jsons),('Backlog traceability',tasks),('SQL proposal static references',sqlrefs),('Markdown inventory',layout),('Mathematical examples',math_examples)]:check(name,fn)
result={'scope':'Documentation and reference example checks only','status':'Passed' if all(x['status']=='Passed' for x in checks) else 'Failed','checks':checks,'notPerformed':['C# compilation/application tests','PostgreSQL DDL execution/provider tests','Rendered Mermaid validation','Empirical model/backtest validation','Deployment/restore rehearsal','Independent external reviewer']}
(ROOT/'evidence/validation-results.json').write_text(json.dumps(result,indent=2)+'\n')
report=['# Documentation pack validation','','Status: **'+result['status']+'**. Command: `python scripts/validate_pack.py`.','','| Check | Result | Scope |','|---|---|---|']+[f"| {x['name']} | {x['status']} | {x['detail']} |" for x in checks]
report+=['','## Not performed','']+['- '+x for x in result['notPerformed']]+['','All implementation backlog tasks remain NotStarted. These results validate the document pack and selected analytic examples; they do not certify an application, database migration, predictive performance or deployment.']
(ROOT/'evidence/PACK_VALIDATION.md').write_text('\n'.join(report)+'\n')
print(json.dumps(result,indent=2))
sys.exit(0 if result['status']=='Passed' else 1)
