package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.data.DataSource;
import haxe.ui.graphics.ComponentGraphics;
import haxe.ui.util.Color;

class Canvas extends Component implements IDataComponent {
    @:clonable @:behaviour(DataSourceBehaviour)                             public var dataSource:DataSource<Dynamic>;
    
    public function new() {
        super();
        _componentGraphics = new ComponentGraphics(this);
    }
    
    private override function onDestroy() {
        super.onDestroy();
        _componentGraphics = null;
    }

    private var _componentGraphics:ComponentGraphics;
    public var componentGraphics(get, never):ComponentGraphics;
    private function get_componentGraphics():ComponentGraphics {
        if (_componentGraphics == null && _isDisposed) {
            trace("WARNING: trying to access component graphics on a disposed component");
            return null;
        }
        return _componentGraphics;
    }
    

    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        if (width <= 0  || height <= 0) {
            return b;
        }
        componentGraphics.resize(width, height);
        return b;
    }
    
    public override function cloneComponent():Canvas {
        @:privateAccess c.componentGraphics._drawCommands = this.componentGraphics._drawCommands.copy();
        @:privateAccess c.componentGraphics.replayDrawCommands();
        return c;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class DataSourceBehaviour extends DataBehaviour {
    private var _canvas:Canvas;
    
    public function new(canvas:Canvas) {
        super(canvas);
        _canvas = canvas;
    }
    
    private override function validateData() {
        if (_value != null) {
            var ds:DataSource<Dynamic> = _value;
            var g:ComponentGraphics = _canvas.componentGraphics;
            for (i in 0...ds.size) {
                var item:Dynamic = ds.get(i);
                switch (item.id) {
                    case "clear":
                        g.clear();
                    case "moveTo" | "move-to":
                        var x:Null<Float> = (item.x != null) ? Std.parseFloat(item.x) : 0;
                        var y:Null<Float> = (item.y != null) ? Std.parseFloat(item.y) : 0;
                        g.moveTo(x, y);
                    case "lineTo" | "line-to":
                        var x:Null<Float> = (item.x != null) ? Std.parseFloat(item.x) : 0;
                        var y:Null<Float> = (item.y != null) ? Std.parseFloat(item.y) : 0;
                        g.lineTo(x, y);
                    case "curveTo" | "curve-to":
                        var controlX:Null<Float> = (item.controlX != null) ? Std.parseFloat(item.controlX) : 0;
                        var controlY:Null<Float> = (item.controlY != null) ? Std.parseFloat(item.controlY) : 0;
                        var anchorX:Null<Float> = (item.anchorX != null) ? Std.parseFloat(item.anchorX) : 0;
                        var anchorY:Null<Float> = (item.anchorY != null) ? Std.parseFloat(item.anchorY) : 0;
                        g.curveTo(controlX, controlY, anchorX, anchorY);
                    case "cubicCurveTo" | "cubic-curve-to":
                        var controlX:Null<Float> = (item.controlX != null) ? Std.parseFloat(item.controlX) : 0;
                        var controlY:Null<Float> = (item.controlY != null) ? Std.parseFloat(item.controlY) : 0;
                        var controlX2:Null<Float> = (item.controlX2 != null) ? Std.parseFloat(item.controlX2) : 0;
                        var controlY2:Null<Float> = (item.controlY2 != null) ? Std.parseFloat(item.controlY2) : 0;
                        var anchorX:Null<Float> = (item.anchorX != null) ? Std.parseFloat(item.anchorX) : 0;
                        var anchorY:Null<Float> = (item.anchorY != null) ? Std.parseFloat(item.anchorY) : 0;
                        g.cubicCurveTo(controlX, controlY, controlX2, controlY2, anchorX, anchorY);
                    case "strokeStyle" | "stroke-style":
                        var color:String = item.color;
                        var thickness:Null<Float> = (item.thickness != null) ? Std.parseFloat(item.thickness) : 1;
                        var alpha:Null<Float> = (item.alpha != null) ? Std.parseFloat(item.alpha) : 1;
                        g.strokeStyle(Color.fromString(color), thickness, alpha);
                    case "fillStyle" | "fill-style":
                        var color:String = item.color;
                        var alpha:Null<Float> = (item.alpha != null) ? Std.parseFloat(item.alpha) : 1;
                        g.fillStyle(Color.fromString(color), alpha);
                    case "rectangle":
                        var x:Null<Float> = (item.x != null) ? Std.parseFloat(item.x) : 0;
                        var y:Null<Float> = (item.y != null) ? Std.parseFloat(item.y) : 0;
                        var width:Null<Float> = (item.width != null) ? Std.parseFloat(item.width) : _canvas.width;
                        var height:Null<Float> = (item.height != null) ? Std.parseFloat(item.height) : _canvas.height;
                        g.rectangle(x, y, width, height);
                    case "image":
                        var resource:String = item.resource;
                        var x:Null<Float> = Std.parseFloat(item.x);
                        var y:Null<Float> = Std.parseFloat(item.y);
                        var width:Null<Float> = Std.parseFloat(item.width);
                        var height:Null<Float> = Std.parseFloat(item.height);
                        g.image(resource, x, y, width, height);
                    case "circle":
                        var x:Null<Float> = Std.parseFloat(item.x);
                        var y:Null<Float> = Std.parseFloat(item.y);
                        var radius:Null<Float> = Std.parseFloat(item.radius);
                        g.circle(x, y, radius);
                    case "beginPath" | "begin-path":
                        g.beginPath();
                    case "closePath" | "close-path":
                        g.closePath();
                    case _:
                        trace("unrecognised draw command: " + item);
                }
            }
        }
    }
}