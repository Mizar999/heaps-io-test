class Entity {
    public var position: h3d.Vector;
    public var originalPosition: h3d.Vector;

    public function new(x: Int, y: Int) {
        position = new h3d.Vector(x, y);
        originalPosition = new h3d.Vector(x, y);
    }
}