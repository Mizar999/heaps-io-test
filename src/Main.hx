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

    var font: h2d.Font;
    var controlsText: h2d.Text;
    var gameOverText: h2d.Text;

    var isGameOver: Bool;

    static function main() {
        hxd.Res.initEmbed();
        new Main();
    }

    override function init() {
        super.init();
        initGame();
        startNewGame();
        hxd.Window.getInstance().addEventTarget(onEvent);
    }

    function initGame() {
        initTiles();
        initText();
    }
    
    function startNewGame() {
        createMap();
        controlsText.text = "Move with arrow keys, press 'R' to reset.";
        gameOverText.text = "";
        isGameOver = false;
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

        mapGroup = new h2d.TileGroup(spritesheet, s2d);
        objectGroup = new h2d.TileGroup(spritesheet, s2d);
    }

    function initText() {
        font = hxd.res.DefaultFont.get();
        controlsText = new h2d.Text(font);
        s2d.addChild(controlsText);

        gameOverText = new h2d.Text(font);
        s2d.addChild(gameOverText);
    }

    function createMap() {
        var map = [
            "############",
            "####....####",
            "####.xx.####",
            "####....####",
            "####....####",
            "####.cc.####",
            "####....####",
            "####.@..####",
            "####....####",
            "############"
        ];

        floor = [];
        crates = [];
        targets = [];
        mapGroup.clear();
        var isFloor = false;
        for(y in 0...map.length) {
            floor.push([]);
            for(x in 0...map[y].length) {
                isFloor = true;
                switch(map[y].charAt(x)) {
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

    function checkGameOver() {
        var foundCrate: Bool;
        for(target in targets) {
            foundCrate = false;

            for(crate in crates) {
                if(crate.position.x == target.position.x && crate.position.y == target.position.y) {
                    foundCrate = true;
                    break;
                }
            }

            if(!foundCrate)
                return false;
        }
        return true;
    }

    function gameOver() {
        isGameOver = true;
        gameOverText.text = "You win! Press 'RETURN' to start again.";
        var textBounds = controlsText.getBounds();
        gameOverText.y = textBounds.y + textBounds.height + (gameOverText.textHeight / 2);
    }

    function isPassable(position: h3d.Vector, direction: h3d.Vector, ignoreCrates: Bool) {
        var newPosition = position.add(direction);
        var x = Std.int(newPosition.x);
        var y = Std.int(newPosition.y);
        var passable = floor[y][x];
        if(!ignoreCrates) {
            for(crate in crates) {
                if(crate.position.x == newPosition.x && crate.position.y == newPosition.y) {
                    passable = false;
                    break;
                }
            }
        }
        return passable;

    }

    function onEvent(event: hxd.Event) {
        var isDirty = false;
        if(event.kind == EKeyDown) {
            if(isGameOver) {
                if(event.keyCode == hxd.Key.ENTER || event.keyCode == hxd.Key.NUMPAD_ENTER || event.keyCode == hxd.Key.R)
                    startNewGame();
                return;
            }

            var direction: h3d.Vector = null;
            if(event.keyCode == hxd.Key.A || event.keyCode == hxd.Key.NUMPAD_4 || event.keyCode == hxd.Key.LEFT)
                direction = new h3d.Vector(-1, 0);
            else if(event.keyCode == hxd.Key.D || event.keyCode == hxd.Key.NUMPAD_6 || event.keyCode == hxd.Key.RIGHT)
                direction = new h3d.Vector(1, 0);
            else if(event.keyCode == hxd.Key.W || event.keyCode == hxd.Key.NUMPAD_8 || event.keyCode == hxd.Key.UP)
                direction = new h3d.Vector(0, -1);
            else if(event.keyCode == hxd.Key.S || event.keyCode == hxd.Key.NUMPAD_2 || event.keyCode == hxd.Key.DOWN)
                direction = new h3d.Vector(0, 1);
            else if(event.keyCode == hxd.Key.R) {
                reset();
                isDirty = true;
            }

            if(direction != null && (direction.x != 0 || direction.y != 0)) {
                if(isPassable(player.position, direction, true)) {
                    var newPosition = player.position.add(direction);
                    var blocked = false;
                    for(crate in crates) {
                        if(crate.position.x == newPosition.x && crate.position.y == newPosition.y) {
                            if(isPassable(crate.position, direction, false)) {
                                crate.position = crate.position.add(direction);
                            } else {
                                blocked = true;
                            }
                            break;
                        }
                    }

                    if(!blocked) {
                        player.position = newPosition;
                        isDirty = true;
                    }
                }
            }
        }

        if(isDirty) {
            drawObjects();
            if(checkGameOver())
                gameOver();
        }
    }
}