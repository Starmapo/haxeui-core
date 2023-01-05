package haxe.ui.geom;

class Point {
    public var x:Float;
    public var y:Float;
    
    public function add(addend:Point) {
        this.x += addend.x;
        this.y += addend.y;
    }
    
    public function subtract(subtrahend:Point) {
        this.x -= subtrahend.x;
        this.y -= subtrahend.y;
    }
    
    public function sum(addend:Point):Point {
        return new Point(this.x + addend.x, this.y + addend.y);
    }
    
    public function diff(subtrahend:Point):Point {
        return new Point(this.x - subtrahend.x, this.y - subtrahend.y);
    }

    public function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
    }
}
