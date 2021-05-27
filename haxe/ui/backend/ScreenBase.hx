package haxe.ui.backend;

import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;

class ScreenBase {
    private var _topLevelComponents:Array<Component> = [];
    public var rootComponents:Array<Component>;

    private var _focus:Component = null;
    public var focus(get, set):Component;
    private function get_focus():Component {
        return _focus;
    }
    private function set_focus(value:Component):Component {
        _focus = value;
        return _focus;
    }

    private var _options:ToolkitOptions;
    public var options(get, set):ToolkitOptions;
    private function get_options():ToolkitOptions {
        return _options;
    }
    private function set_options(value:ToolkitOptions):ToolkitOptions {
        _options = value;
        return value;
    }

    public var dpi(get, null):Float;
    private function get_dpi():Float {
        return 72;
    }

    public var title(get, set):String;
    private function get_title():String {
        return null;
    }
    private function set_title(s:String):String {
        return s;
    }

    public var width(get, null):Float;
    private function get_width():Float {
        return 0;
    }

    public var height(get, null):Float;
    private function get_height():Float {
        return 0;
    }

    public var actualWidth(get, null):Float;
    private function get_actualWidth():Float {
        return width * Toolkit.scaleX;
    }

    public var actualHeight(get, null):Float;
    private function get_actualHeight():Float {
        return height * Toolkit.scaleY;
    }
    
    public var isRetina(get, null):Bool;
    private function get_isRetina():Bool {
        return false;
    }

    public function addComponent(component:Component):Component {
        return component;
    }

    public function removeComponent(component:Component):Component {
        return component;
    }

    private function handleSetComponentIndex(child:Component, index:Int) {
    }

    private function resizeComponent(c:Component) {
        var cx:Null<Float> = null;
        var cy:Null<Float> = null;

        if (c.percentWidth > 0) {
            cx = (this.width * c.percentWidth) / 100;
        }
        if (c.percentHeight > 0) {
            cy = (this.height * c.percentHeight) / 100;
        }
        c.resizeComponent(cx, cy);
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function supportsEvent(type:String):Bool {
        return false;
    }

    private function mapEvent(type:String, listener:UIEvent->Void) {
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {
    }
}