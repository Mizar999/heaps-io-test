class Main extends hxd.App {
    var floor: Array<Array<Bool>>;
    var player: Entity;
    var crates: Array<Entity>;
    var targets: Array<Entity>;

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

        floor = [];
        crates = [];
        targets = [];
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
                        crates.push(new Entity(x, y));
                    case "x":
                        targets.push(new Entity(x, y));
                    case "@":
                        player = new Entity(x, y);
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

        for(entity in targets) {
            objectGroup.add(entity.position.x * tileWidth, entity.position.y * tileHeight, tiles[120]);
        }
        for(entity in crates) {
            objectGroup.add(entity.position.x * tileWidth, entity.position.y * tileHeight, tiles[35]);
        }
        objectGroup.add(player.position.x * tileWidth, player.position.y * tileHeight, tiles[64]);
    }

    function reset() {
        for(entity in targets) {
            entity.position = entity.originalPosition.clone();
        }
        for(entity in crates) {
            entity.position = entity.originalPosition.clone();
        }
        player.position = player.originalPosition.clone();
    }

    function onEvent(event: hxd.Event) {
        var isDirty = false;
        if(event.kind == EKeyDown) {
            if(event.keyCode == hxd.Key.A || event.keyCode == hxd.Key.NUMPAD_4 || event.keyCode == hxd.Key.LEFT) {
                player.position.x -= 1;
                isDirty = true;
            }
            if(event.keyCode == hxd.Key.D || event.keyCode == hxd.Key.NUMPAD_6 || event.keyCode == hxd.Key.RIGHT) {
                player.position.x += 1;
                isDirty = true;
            }
            if(event.keyCode == hxd.Key.W || event.keyCode == hxd.Key.NUMPAD_8 || event.keyCode == hxd.Key.UP) {
                player.position.y -= 1;
                isDirty = true;
            }
            if(event.keyCode == hxd.Key.S || event.keyCode == hxd.Key.NUMPAD_2 || event.keyCode == hxd.Key.DOWN) {
                player.position.y += 1;
                isDirty = true;
            }
            if(event.keyCode == hxd.Key.R) {
                reset();
                isDirty = true;
            }
        }

        if(isDirty) {
            drawObjects();
        }
    }
}