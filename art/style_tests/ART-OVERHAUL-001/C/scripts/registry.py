"""Records Stage C's PixelLab jobs in pixellab-assets.json (run once from the repository root)."""
import json

p = 'pixellab-assets.json'
d = json.load(open(p))
STONE = '22-colour cave stone palette (Stage B palette subset plus three warm greys)'
C = '8178e6bc-10d1-4842-89e0-79b668817e66'   # set C's floor base tile, shared by E, F and G


def ts(key, id_, kept, lower, upper, trans, seed, rag, amp, rnd, note, base=None):
    j = {'key': key, 'tool': 'create_topdown_tileset', 'tileset_id': id_, 'size': [16, 16], 'cost': 15,
         'settings': {'mode': 'pro', 'transition_size': 1.0, 'view': 'high top-down', 'raggedness': rag,
                      'boundary_amplitude': amp, 'boundary_seed': seed, 'roundness': rnd,
                      'palette': '25-colour Stage B palette subset' if key in ('tileset_a', 'tileset_b') else STONE},
         'prompt': {'lower': lower, 'upper': upper, 'transition': trans}, 'kept': kept, 'note': note}
    if base:
        j['settings']['lower_base_tile_id'] = base
    return j


def img(key, job, asset, size, seed, prompt, kept, note, style='rock_ref64 (crop of Stage B cliff_e.png)'):
    return {'key': key, 'tool': 'create_image_pro', 'job_id': job, 'asset_id': asset, 'size': size, 'candidates': 64,
            'seed': seed, 'cost': 10,
            'settings': {'no_background': key != 'steps_a', 'style_image': style,
                         'style_copy': ['outline', 'detail', 'shading'], 'palette': 'forced, muted cave/moss/ore colours'},
            'prompt': prompt, 'kept': kept, 'note': note}


jobs = [
    ts('tileset_a', 'dff124a5-18f3-41b5-896c-e6ded79f2cbb', False, 'damp dark cave floor ...',
       'rough natural cave rock wall ... a little dark moss', 'tall vertical natural rock face of fractured stone',
       3101, 0.6, 0.2, 0.6, 'rejected: pale rock tops on a dark floor read inverted'),
    ts('tileset_b', 'e53db4d2-65bc-40f6-b443-f90b8d2936f1', False, 'dark wet cave floor ...',
       'solid mass of natural cave bedrock ...', 'tall rugged cliff face of layered broken rock',
       3102, 0.8, 0.25, 0.4, 'rejected: the floor repeats an arrow mark'),
    ts('tileset_c', '746bcbff-1198-4217-b387-b57023095ba1', False, 'natural cave floor of mid grey-brown packed stone and grit ...',
       'top of solid cave bedrock in deep shadow ...', 'tall natural vertical cave wall of fractured irregular rock slabs ...',
       3103, 0.7, 0.2, 0.5, 'faces read as brickwork; its floor tile (base %s) is the game floor, shared by E, F and G' % C),
    ts('tileset_d', '05463686-645d-4dbe-ab58-d1a11da5be15', False, 'damp cave floor ...', 'dark unlit rock mass ...',
       'rugged vertical rock face ... thin moss in crevices', 3104, 0.9, 0.3, 0.8, 'rejected: the floor pattern repeats'),
    ts('tileset_e', '7f3cfc3e-566d-484e-93ef-532f94f84afa', True, 'natural cave floor (set C base tile)',
       'top of solid cave bedrock in deep shadow ...',
       'natural vertical cave rock face, NOT bricks, NOT masonry: big irregular fractured boulders and jagged slabs ...',
       3105, 1.0, 0.3, 0.7, 'kept: one of the three face sets mixed per cell', C),
    ts('tileset_f', '7e3c4cac-3c72-4b7b-8581-04b933c5b791', True, 'natural cave floor (set C base tile)',
       'dark unlit rock mass ...', 'rough organic cliff of wild cave rock, lumpy weathered bulges, deep fissures, no blocks',
       3106, 0.8, 0.25, 1.0, 'kept', C),
    ts('tileset_g', 'f120e4aa-49d1-4a21-a30e-73151d916bf2', True, 'natural cave floor (set C base tile)',
       'top of solid cave bedrock in deep shadow ...', 'jagged natural cave wall face like a rocky hillside cliff ...',
       3107, 0.9, 0.3, 0.4, 'kept', C),
    {'key': 'floor_variants', 'tool': 'create_tiles_pro', 'tile_id': 'b99f3b83-316b-4e10-a5e4-ef45c5109ed0',
     'size': [16, 16], 'seed': 3801, 'cost': 10, 'settings': {'style_images': 'set C floor tile', 'palette': '17 stone colours'},
     'prompt': '16 numbered cave floor variants (plain, gravel, crack, pebbles, damp ...)', 'kept': False,
     'note': 'rejected: flat, X marks, tone off the base tile; the variety comes from decals instead'},
    img('decals', '50a84461-8eeb-4194-8913-3a0f362fa218', 'e85f37d2-cb17-58cc-af26-559c881beaf3', [32, 32], 3201,
        'Sheet of flat ground decals for a dark damp cave floor: gravel, cracks, rubble, puddle, stain, pebbles, root tips, timber',
        True, 'kept: cracks 00 02, gravel 08-11, roots 40 42 44'),
    img('copper', 'a335830a-24e8-433e-b78b-6eb7c4e5a4fa', '11e4a6e6-4d85-5e8f-9680-89e553b19601', [16, 16], 3301,
        'Copper ore deposit set into rough grey cave rock, orange-brown nuggets and green verdigris', True,
        'kept: 16, 22, 03 (the first picks 02 25 35 read too green under the lantern)'),
    img('iron', '9d8c5385-dcde-4f5e-89dc-39282608f0b9', '7b0f6daf-dda7-53ff-ab55-e502ce109646', [16, 16], 3401,
        'Iron ore deposit set into rough dark cave rock, rusty red-brown streaks, clearly darker than copper', True,
        'kept: 00, 07, 28'),
    img('dress', '399d3070-937e-436f-972f-74b510b084ff', 'd3ee237a-ab30-510c-851c-70d022ae884c', [32, 32], 3501,
        'Sheet of small cave wall dressings: moss, roots, stalactite tips, ferns', True,
        'kept: ferns 50 54 58 (its moss and drips are too big for a 16 px face)', 'Stage B mouth.png'),
    img('steps_a', 'ba9bc293-f3ed-48da-b78b-2db3f2ccdcbf', 'ede23513-6f39-5687-aafa-01622c0498a1', [32, 32], 3601,
        'Rough natural stone steps climbing up out of a cave toward daylight', False,
        'rejected: an opaque square with a frame, read as pasted in'),
    img('rocks', '5999109d-e0e7-4a59-9c00-e3d7bf489c95', '256cc56a-72bb-5cb0-b3bb-e5c618014e27', [32, 32], 3701,
        'Sheet of cave floor rocks: boulders, slabs, stalagmites, rubble heaps', True,
        'kept: pebbles 00 61, foot rubble 24 25 33 34, spires 16-19, boulders 01-03, mossy 49 51'),
    img('mossfringe', 'b2285893-3e13-4bdc-9f57-a554654c48a6', '30ea38d2-de33-5797-96d3-459e87494960', [16, 16], 3901,
        'Small dark green moss and thin roots hanging over the top edge of a rock face, 16 px wide', True,
        'kept: 48-51 (the rest have a solid backing)', 'Stage B mouth.png'),
    img('drip', 'ea03b54e-54d4-4f10-8608-deffdee87cce', 'ffd8706b-7d8c-5b11-8bf3-ad4d362391f3', [16, 16], 3902,
        'Short fringe of small grey-brown stalactites hanging from the top edge of a cave wall', True,
        'kept: 28 30 44 46, keyed off their opaque black backing and re-outlined by tools/aoh_cave_int.py'),
    img('small', '7a3ba06f-eea6-4e44-8fc5-5599045fd136', 'cb13af9e-1f40-5403-b163-b80e5ec098e7', [16, 16], 3903,
        'Small flat floor details: short crack, chips, damp patch, drip puddle, grit; subtle', True,
        'kept: cracks and grit 00 02 03 04 08 10 12 48 50 52 53 56 60, puddles 37 41 45', 'set C floor tile'),
    img('steps2', '421b1ecb-3418-4bf0-820e-5d6a30773324', '6dcfecd2-e50f-5ca7-abfe-dd490a68db7e', [32, 32], 3602,
        'Rough natural stone steps rising toward the viewer out of a cave, mossy, ragged edges, no frame', True, 'kept: 34'),
]
d['ART-OVERHAUL-001/C'] = {
    'tool': 'tools/aoh_cave_int.py', 'sources': 'art/style_tests/ART-OVERHAUL-001/C/',
    'note': "Stage C: the mining cave's interior. Candidates in C/raw/<key>/NN.png; tilesets in C/raw/tiles/ts_<a-g>.png and .json.",
    'generations': sum(j['cost'] for j in jobs), 'jobs': jobs,
    'game_files': ['res://art/farm/cave_int/walls.png', 'res://art/farm/cave_int/floor.png',
                   'res://art/farm/cave_int/atlas.png', 'res://art/farm/cave_int/cave_int.json']}
print(d['ART-OVERHAUL-001/C']['generations'])
json.dump(d, open(p, 'w'), indent=1)
