class Main extends hxd.App {
    static function main() {
        new Main();
    }

    override function init() {
        var text = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        text.text = "Hello World!";
    }
}