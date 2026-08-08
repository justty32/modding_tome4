# Fall from Heaven import investigation

Source installer: `/home/lorkhan/Downloads/FallfromHeaven2041n.exe`

Unpacked working copy for this session: `/tmp/ffh2_unpack.ecgdxe/Fall from Heaven 2`

Generated inventories:

- `resource-inventory.tsv`: every unpacked file, categorized.
- `resource-summary.tsv`: counts and sizes by category/extension.
- `maps-scenarios.tsv`: Civ4 WBSave map/scenario dimensions and top terrain/resource tokens.
- `wb-tokens.tsv`: tokens found in WBSave fields.
- `art-media-index.tsv`: art/audio/font/media files by extension and path.
- `text-code-index.tsv`: XML/Python/text files by path.
- `xml-systems.tsv`: XML subsystem summary.
- `xml-type-lookup.tsv`: map-relevant XML type identifiers for terrain/features/bonuses/improvements/civs/units.

Important first finding: FFH2 is a Civilization IV mod. Static scenario maps are `Assets/XML/Scenarios/*.CivBeyondSwordWBSave`; the procedural Erebus generator is `PrivateMaps/Erebus.py`. The large packed art file `Assets/Pak0.FPK` is not readable by 7z directly and needs a Civ4 FPK unpacker or a custom parser.
