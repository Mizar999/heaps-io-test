class Main extends hxd.App {
    var floor: Array<Array<Bool>>;
    var objects: Map<String, String>;
    var player: {x: Int, y: Int}

    var spritesheet: h2d.Tile;
    var tiles: Array<h2d.Tile>;
    var tileWidth: Float;
    var tileHeight: Float;

    var mapGroup: h2d.TileGroup;
    var objectGroup: h2d.TileGroup;

    static function main() {
        hxd.Res.initEmbed();
        new Main();
    }

    override function init() {
        super.init();
        initTiles();
        createMap();
        hxd.Window.getInstance().addEventTarget(onEvent);
    }

    function initTiles() {
        spritesheet = hxd.Res.hack_square_black_64x64.toTile();
        tileWidth = 64;
        tileHeight = 64;
        
        tiles = [
            for(y in 0...Std.int(spritesheet.height / tileHeight))
                for(x in 0...Std.int(spritesheet.width / tileWidth))
                    spritesheet.sub(x * tileWidth, y * tileHeight, tileWidth, tileHeight)
        ];
    }

    function createMap() {
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

        objects = new Map<String, String>();
        floor = [];
        player = {x: 0, y: 0};
        mapGroup = new h2d.TileGroup(spritesheet, s2d);
        var isFloor = false;
        for(y in 0...map.length) {
            floor.push([]);
            for(x in 0...map[y].length) {
                isFloor = true;
                switch(map[y][x]) {
                    case ".":
                        { }
                    case "c":
                            objects['${x};${y}'] = "crate";
                    case "x":
                            objects['${x};${y}'] = "target";
                    case "@":
                        {
                            player.x = x;
                            player.y = y;
                        }
                    default:
                        isFloor = false;
                }

                if(isFloor)
                    mapGroup.add(x * tileWidth, y * tileHeight, tiles[46]);
                floor[y].push(isFloor);
            }
        }

        objectGroup = new h2d.TileGroup(spritesheet, s2d);
        drawObjects();
    }

    function drawObjects() {
        objectGroup.clear();
        
        var x, y, tileIndex;
        var arr: Array<String>;
        for(pos => type in objects) {
            arr = pos.split(";");
            x = Std.parseInt(arr[0]);
            y = Std.parseInt(arr[1]);
            switch(type) {
                case "crate":
                    tileIndex = 35;
                case "target":
                    tileIndex = 120;
                default:
                    tileIndex = 1;
            }
            objectGroup.add(x * tileWidth, y * tileHeight, tiles[tileIndex]);
        }

        objectGroup.add(player.x * tileWidth, player.y * tileHeight, tiles[64]);
    }

    function onEvent(event: hxd.Event) {
        var isDirty = false;
        if(event.kind == EKeyDown) {
            if(event.keyCode == hxd.Key.A || event.keyCode == hxd.Key.LEFT) {
                player.x -= 1;
                isDirty = true;
            }
            if(event.keyCode == hxd.Key.D || event.keyCode == hxd.Key.RIGHT) {
                player.x += 1;
                isDirty = true;
            }
            if(event.keyCode == hxd.Key.W || event.keyCode == hxd.Key.UP) {
                player.y -= 1;
                isDirty = true;
            }
            if(event.keyCode == hxd.Key.S || event.keyCode == hxd.Key.DOWN) {
                player.y += 1;
                isDirty = true;
            }
            
        }

        if(isDirty) {
            drawObjects();
        }
    }
}