class Main extends hxd.App {
    static function main() {
        hxd.Res.initEmbed();
        new Main();
    }

    override function init() {
        super.init();

        var map = [
            ['#','#','#','#','#','#','#','#','#','#','#','#'],
            ['#','#','#','#','.','.','.','.','#','#','#','#'],
            ['#','#','#','#','.','x','x','.','#','#','#','#'],
            ['#','#','#','#','.','.','.','.','#','#','#','#'],
            ['#','#','#','#','.','.','.','.','#','#','#','#'],
            ['#','#','#','#','.','c','c','.','#','#','#','#'],
            ['#','#','#','#','.','.','.','.','#','#','#','#'],
            ['#','#','#','#','.','@','.','.','#','#','#','#'],
            ['#','#','#','#','.','.','.','.','#','#','#','#'],
            ['#','#','#','#','#','#','#','#','#','#','#','#']
        ];

        var spritesheet = hxd.Res.hack_square_64x64.toTile();
        var tileWidth = 64;
        var tileHeight = 64;
        
        // Create sub tiles
        var tiles = [
            for(y in 0...Std.int(spritesheet.height / tileHeight))
                for(x in 0...Std.int(spritesheet.width / tileWidth))
                    spritesheet.sub(x * tileWidth, y * tileHeight, tileWidth, tileHeight)
        ];

        var group = new h2d.TileGroup(spritesheet, s2d);
        for(y in 0...map.length) {
            for(x in 0...map[y].length) {
                trace(map[y][x]);
                switch(map[y][x]) {
                    case ".":
                        group.add(x * tileWidth, y * tileHeight, tiles[46]);
                    case "c":
                        group.add(x * tileWidth, y * tileHeight, tiles[35]);
                    case "x":
                        group.add(x * tileWidth, y * tileHeight, tiles[120]);
                    case "@":
                        group.add(x * tileWidth, y * tileHeight, tiles[64]);
                }
            }
        }
    }
}