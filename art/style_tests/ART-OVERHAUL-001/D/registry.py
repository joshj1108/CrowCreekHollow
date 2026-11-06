"""Writes the ART-OVERHAUL-001/D entry of pixellab-assets.json (every Stage D job, kept or not).
Run from the repository root: python art/style_tests/ART-OVERHAUL-001/D/registry.py"""
import json, os, re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
picks_src = open(os.path.join(ROOT, 'tools/aoh_trek.py')).read()
PAL = 'D/palette.json (Stage B palette minus 3 near-duplicates, plus autumn rust, creek blues, bone and hollow greys); a subset per job'
TS = [
    ('forest', 'f80722e3-6725-4a34-8a76-9a7bcef6edf5', 'dark temperate forest floor: mossy loam, fallen rust and ochre leaves ...', 'worn packed dirt footpath through woods ...', 4101, False,
     'rejected: the trail came out orange; its floor tile (base 25d5f971-8be9-4b06-b6ba-1099990e5420) is the floor of forest2 and creek'),
    ('pasture', '49ee01c5-5a29-4575-b5e5-17eb565eee2d', 'overgrown abandoned pasture: rough tall meadow grass ...', 'neglected muddy cart track ...', 4102, False,
     'rejected: grass too yellow and bright, sawtooth edges'),
    ('hollow', 'caf71755-d818-423b-9c63-5b9a27aa0e32', 'very dark old-growth forest floor ... cold violet-grey shadow', 'pale worn footpath ...', 4103, False,
     'rejected: violet floor, path too pale'),
    ('creek', 'b6d36b24-720c-4654-9bfb-e1f97228d4ae', 'dark still creek water, muted blue-grey ...', 'forest floor (the forest base tile)', 4104, True,
     'kept: ground_creek.png (transition 0.25, step_slope 1: low muddy banks with wet stones and reeds)'),
    ('forest2', '1ee52946-6bb0-4376-8954-bf68b9c45c87', 'forest floor (the forest base tile)', 'muted grey-brown packed earth footpath through woods ...', 4111, True,
     'kept: ground_forest.png; the trail greys recoloured to warm path browns (TRAIL_BROWN in tools/aoh_trek.py)'),
    ('hollow2', '830d504a-9804-49ab-a2a1-6e174fb7394a', 'very dark old-growth forest floor: deep dark moss and black loam ...', 'dim grey-brown worn earth footpath with flat sunken stones', 4113, True,
     'kept: ground_hollow.png; the path greys darkened a step (HOLLOW_PATH)'),
    ('pasture2', 'f7de5990-353a-43f8-ae80-015f5396ab44', 'overgrown abandoned pasture: rough dark olive meadow grass ...', 'neglected muddy cart track ...', 4112, True,
     'kept: ground_pasture.png'),
]
IM = [
    ('fir', 'd34dcd5d-b28e-40e2-94f3-300ec3de6592', [32, 48], 4201, 'style_trees (farm src_fir and src_maple, Stage B fern, boulder, bramble, litter)', 'single dark evergreen fir, narrow conical shadowed blue-green canopy, root flare'),
    ('maple', '18a5af1a-7d91-40da-8c85-4c30485d7333', [32, 48], 4202, 'style_trees', 'single autumn broadleaf maple or oak, rust, ochre and dull orange canopy'),
    ('dead', 'c31c2940-2add-4cda-a946-40c12dd1ae9e', [32, 48], 4203, 'style_trees', 'single dead bare tree snag, crooked broken branches, peeling bark'),
    ('ancient', '28941256-35d9-4761-9dcc-90d6a3736d84', [48, 64], 4204, 'style_trees', 'single ancient old-growth tree, massive gnarled trunk, twisted roots, dark canopy, no glow'),
    ('apple', 'bc6be369-7e17-44ca-b279-c580a7e04c5f', [32, 48], 4205, 'art/farm/concept/w4_orchard_apple_a.png', 'neglected gone-wild old apple tree, crooked trunk, sparse olive canopy, a few red apples'),
    ('dec_forest', 'a1bbb530-09a4-45ea-809c-1dd94beda5a5', [32, 32], 4301, 'cave_ext/litter_0.png', 'forest floor details: toadstools, roots, moss, autumn leaves, twigs, cones, mossy stones, fern'),
    ('dec_creek', '7129d41d-b1b2-422f-b9d3-dc3bcc14e814', [32, 32], 4302, 'cave_ext/litter_0.png', 'creek bank details: reeds, cattails, stepping stones, wet rocks, mud'),
    ('dec_pasture', '3c408e85-726f-4976-9af9-9f539e05b559', [32, 32], 4303, 'style_trees', 'pasture details: dry grass, bramble, thistle, nettles, broken fence, fallen rail, mossy stone'),
    ('dec_hollow', '656ba2ea-e807-4707-9d98-8c5cc34d2efc', [32, 32], 4304, 'cave_ext/mouth.png', 'hollow details: twisted roots, standing stone fragments, carved blocks, pale toadstools, moss mounds (pale toadstools dropped: they read as glowing at night)'),
    ('mill', 'fcdad7bc-2a9d-4f97-8557-eb9bb13903db', [128, 96], 4401, 'cave_ext/mouth.png', 'old watermill with wheel', False, 'rejected: angled three-quarter view, not straight-on'),
    ('chapel', 'e13cae4e-f86f-483f-a8d9-7f6cee6e670a', [96, 96], 4402, 'cave_ext/mouth.png', 'small grey stone hill chapel, empty bell-cote', False, 'rejected: angled three-quarter view'),
    ('stile', '7b1ad80d-44b0-4f67-8fee-91b16898104a', [96, 48], 4403, 'style_trees', 'split-rail fence with a step stile and a one-armed fingerpost'),
    ('log', '3c6dc472-8bdb-456c-af5f-a4e576f72573', [96, 40], 4404, 'style_trees', 'big fallen mossy trunk across a path, root plate and snapped end'),
    ('sign', '0f7d363e-b155-468f-908e-0e87bbc97db5', [32, 32], 4405, 'style_trees', 'weathered wooden fingerpost with two arms'),
    ('cairn', '49e9d14a-843b-4077-99e4-ef4c5a22d684', [32, 32], 4406, 'cave_ext/mouth.png', 'heap of pale crow skulls on mossy stones', False, 'rejected: about two tiles wide, covered the trail beside it; replaced by cairn2'),
    ('bridge', '99bd8829-8741-48dc-a594-e9ea654bda3c', [64, 32], 4407, 'style_trees', 'rough plank footbridge on log stringers'),
    ('stone', '0c05b5e5-7cd3-4254-bdbd-94d600a91c1b', [32, 48], 4408, 'cave_ext/mouth.png', 'ancient weathered standing stone, lichen, faint worn rings, no glow'),
    ('wheel', '0209a523-1f26-4ced-99db-5ded8665c52f', [32, 32], 4409, 'style_trees', 'wooden mill waterwheel, eight spokes and paddles'),
    ('mill2', 'd7f95d26-f1d1-4b48-b8ea-7b693ad13432', [96, 96], 4411, 'art/farm/barn.png', 'watermill in straight-on front view, no wheel', False, 'rejected for size: 89 px tall, pokes above the trek map; style image for mill3'),
    ('chapel2', '03ba6e8c-424b-4617-b478-307b220b9fd5', [96, 96], 4412, 'art/farm/barn.png', 'stone chapel in straight-on front view, empty bell-cote', False, 'rejected for size (as mill2); style image for chapel3'),
    ('mill3', 'c89206fd-73dc-4d78-8ec9-77834cab28dd', [64, 64], 4421, 'mill2 #0', 'small watermill, straight-on front view, no wheel'),
    ('chapel3', 'e84e1300-063f-496f-bb81-ad398297dd8b', [64, 64], 4422, 'chapel2 #2', 'small stone chapel, straight-on front view, empty bell-cote'),
    ('small', '679ab2ec-2a38-4431-9faf-13741aad2520', [16, 16], 4501, 'cave_ext/litter_0.png', 'one-tile undergrowth: stump, shrub, fern, rock, bramble, log end'),
    ('cairn2', 'c352bafe-cd33-45f0-bce8-9a256c203fcc', [24, 24], 4502, 'cave_ext/mouth.png', 'small heap of three or four crow skulls on a mossy stone'),
    ('logshort', '2c3c7342-c8f2-43a1-b320-cf82ba92843c', [64, 32], 4503, 'style_trees', 'shorter fallen mossy trunk, for blocked stretches the long log would overhang'),
]

# Which candidate indices tools/aoh_trek.py keeps, per sheet.
kept = {}
for sheet, nums in re.findall(r"\('(\w+)', n\) for n in \(([\d, ]+)\)", picks_src):
    kept.setdefault(sheet, set()).update(int(x) for x in nums.split(',') if x.strip())
for sheet, n in re.findall(r"\('(\w+)', (\d+)\)", picks_src):
    kept.setdefault(sheet, set()).add(int(n))

jobs = []
for key, tid, lower, upper, seed, ok, note in TS:
    jobs.append({'key': key, 'tool': 'create_topdown_tileset', 'tileset_id': tid, 'size': [16, 16], 'cost': 15,
                 'settings': {'mode': 'pro', 'view': 'high top-down', 'boundary_seed': seed, 'palette': PAL},
                 'prompt': {'lower': lower, 'upper': upper}, 'kept': ok, 'note': note,
                 'raw': 'art/style_tests/ART-OVERHAUL-001/D/raw/%s/' % key})
for row in IM:
    key, jid, size, seed, style, prompt = row[:6]
    ok = row[6] if len(row) > 6 else True
    note = row[7] if len(row) > 7 else 'kept candidates: %s' % sorted(kept.get(key, []))
    if ok and not kept.get(key):
        ok, note = False, 'no candidate kept'
    jobs.append({'key': key, 'tool': 'create_image_pro', 'job_id': jid, 'size': size, 'cost': 10, 'seed': seed,
                 'settings': {'no_background': True, 'style_image': style, 'style_copy': ['outline', 'detail', 'shading'], 'palette': PAL},
                 'prompt': prompt, 'kept': ok, 'note': note, 'raw': 'art/style_tests/ART-OVERHAUL-001/D/raw/%s/' % key})

p = os.path.join(ROOT, 'pixellab-assets.json')
d = json.load(open(p))
d['ART-OVERHAUL-001/D'] = {
    'tool': 'tools/aoh_trek.py',
    'sources': 'art/style_tests/ART-OVERHAUL-001/D/raw/<key>/NN.png (candidates), raw/<key>/sheet.png and meta.json (tilesets); fetch.py downloads, registry.py writes this entry',
    'note': 'Stage D: the treks. Reuses Stage B pieces (cave_ext fern, bramble, boulder, litter, pebbles) as undergrowth and decals. Pieces are cropped to their main shape (fragments of neighbouring candidates dropped) with binary alpha.',
    'generations': sum(j['cost'] for j in jobs),
    'jobs': jobs,
    'game_files': ['art/farm/trek/ground_forest.png', 'art/farm/trek/ground_pasture.png', 'art/farm/trek/ground_hollow.png',
                   'art/farm/trek/ground_creek.png', 'art/farm/trek/atlas.png', 'art/farm/trek/trek.json'],
}
json.dump(d, open(p, 'w'), indent=1)
print('jobs', len(jobs), 'generations', d['ART-OVERHAUL-001/D']['generations'])
