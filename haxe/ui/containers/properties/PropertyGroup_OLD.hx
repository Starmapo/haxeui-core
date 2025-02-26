package haxe.ui.containers.properties;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.TextField;
import haxe.ui.containers.properties.Property_OLD.PropertyBuilder;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class PropertyGroup_OLD extends VBox {
    @:clonable @:behaviour(TextBehaviour)               public var text:String;
    @:clonable @:behaviour(DisabledBehaviour)           public var disabled:Bool;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent("property-group-header-label");
        label.text = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DisabledBehaviour extends DefaultBehaviour {
    public override function set(value:Variant) {
        var contents = _component.findComponent("property-group-contents", Component);
        if (contents != null) {
            contents.disabled = value;
        }
        var label:Label = _component.findComponent("property-group-header-label");
        if (label != null) {
            label.disabled = value;
        }
    }
    
    public override function get():Variant {
        var contents = _component.findComponent("property-group-contents", Component);
        if (contents != null) {
            return contents.disabled;
        }
        return false;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Events extends haxe.ui.events.Events {
    public override function register() {
        var header = _target.findComponent("property-group-header", Component);
        if (header.hasEvent(MouseEvent.CLICK) == false) {
            header.registerEvent(MouseEvent.CLICK, onHeaderClicked);
        }
    }

    public override function unregister() {
        var header = _target.findComponent("property-group-header", Component);
        header.unregisterEvent(MouseEvent.CLICK, onHeaderClicked);
    }

    private function onHeaderClicked(event:MouseEvent) {
        var interactives = _target.findComponentsUnderPoint(event.screenX, event.screenY, InteractiveComponent);
        if (interactives.length > 0) {
            return;
        }
        var header = _target.findComponent("property-group-header", Component);
        var contents = _target.findComponent("property-group-contents", Component);
        if (header.hasClass(":expanded")) {
            header.swapClass(":collapsed", ":expanded", true, true);
            contents.hideInternal();
        } else {
            header.swapClass(":expanded", ":collapsed", true, true);
            contents.showInternal();
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _propertyGroup:PropertyGroup_OLD;

    private var _propertyGroupHeader:HBox;
    private var _propertyGroupContents:Grid;
    private var _editorMap:Map<Component, Property_OLD> = new Map<Component, Property_OLD>();

    public function new(propertyGroup:PropertyGroup_OLD) {
        super(propertyGroup);
        _propertyGroup = propertyGroup;
    }

    public override function onReady() {
        var propGrid = _component.findAncestor(PropertyGrid_OLD);
        for (c in _propertyGroupContents.findComponents(DropDown)) {
            c.handlerStyleNames = propGrid.popupStyleNames;
        }
        for (editor in _editorMap.keys()) {
            var prop = _editorMap.get(editor);
            if (prop.hidden) {
                applyForPropertyRow(prop, function(label, container) {
                    if (label != null) {
                        label.hide();
                    }
                    if (container != null) {
                        container.hide();
                    }
                });
            }
                
            editor.registerEvent(UIEvent.SHOWN, onPropertyShown);
            editor.registerEvent(UIEvent.HIDDEN, onPropertyHidden);
            editor.registerEvent(UIEvent.ENABLED, onPropertyEnabled);
            editor.registerEvent(UIEvent.DISABLED, onPropertyDisabled);

            prop.registerEvent(UIEvent.SHOWN, onPropertyShown);
            prop.registerEvent(UIEvent.HIDDEN, onPropertyHidden);
            prop.registerEvent(UIEvent.ENABLED, onPropertyEnabled);
            prop.registerEvent(UIEvent.DISABLED, onPropertyDisabled);
        }
    }

    public override function create() {
        _propertyGroupHeader = new HBox();
        _propertyGroupHeader.addClass("property-group-header_o-l-d");
        _propertyGroupHeader.addClass(":expanded");
        _propertyGroupHeader.id = "property-group-header";

        var image = new Image();
        image.addClass("property-group-header-icon_o-l-d");
        _propertyGroupHeader.addComponent(image);

        var label = new Label();
        label.addClass("property-group-header-label_o-l-d");
        label.id = "property-group-header-label";
        _propertyGroupHeader.addComponent(label);

        _propertyGroup.addComponent(_propertyGroupHeader);

        _propertyGroupContents = new Grid();
        _propertyGroupContents.addClass("property-group-contents_o-l-d");
        _propertyGroupContents.id = "property-group-contents";
        _propertyGroup.addComponent(_propertyGroupContents);
    }

    public override function addComponent(child:Component):Component {
        if ((child is Property_OLD)) {
            var prop = cast(child, Property_OLD);

            var labelContainer = new Box();
            labelContainer.addClass("property-group-item-label-container_o-l-d");
            _propertyGroupContents.addComponent(labelContainer);

            var label = new Label();
            label.text = prop.label;
            label.addClass("property-group-item-label_o-l-d");
            labelContainer.addComponent(label);
            labelContainer.hidden = prop.hidden;
            if (prop.disabled) {
                labelContainer.disabled = prop.disabled;
            }
            cast(prop._compositeBuilder, PropertyBuilder).label = label;

            var editorContainer = new Box();
            editorContainer.addClass("property-group-item-editor-container_o-l-d");
            _propertyGroupContents.addComponent(editorContainer);

            var editor = buildEditor(prop);
            editor.disabled = prop.disabled;

            editor.id = child.id;
            editor.addClass("property-group-item-editor_o-l-d");
            editorContainer.addComponent(editor);
            editorContainer.hidden = prop.hidden;
            editor.registerEvent(UIEvent.CHANGE, onPropertyEditorChange);
            if ((editor is Button)) {
                var b = cast(editor, Button);
                if (b.toggle == false) {
                    editor.registerEvent(MouseEvent.CLICK, onPropertyEditorClick);
                }
            }
            cast(prop._compositeBuilder, PropertyBuilder).editor = editor;

            _propertyGroup.registerInternalEvents(Events, true);
            _editorMap.set(editor, prop);

            return editor;
        } else if (child != _propertyGroupHeader && child != _propertyGroupContents) {
            _propertyGroupHeader.addComponent(child);
            return child;
        }

        return null;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if ((child is Property_OLD)) {
            var target = cast(child._compositeBuilder, PropertyBuilder).actualEditor;
            var container = target.findAncestor("property-group-item-editor-container", Box, "css");
            var index = _propertyGroupContents.getComponentIndex(container);
            var label = _propertyGroupContents.getComponentAt(index - 1);
            _propertyGroupContents.removeComponent(label, dispose, invalidate);
            _propertyGroupContents.removeComponent(container, dispose, invalidate);
            _editorMap.remove(target);
            return child;
        }
        return null;
    }

    private function onPropertyShown(event:UIEvent) {
        applyForPropertyRow(event.target, function(label, container) {
            if (label != null) {
                label.show();
            }
            if (container != null) {
                container.show();
            }
        });
    }
    
    private function onPropertyHidden(event:UIEvent) {
        applyForPropertyRow(event.target, function(label, container) {
            if (label != null) {
                label.hide();
            }
            if (container != null) {
                container.hide();
            }
        });
    }

    private function onPropertyEnabled(event:UIEvent) {
        applyForPropertyRow(event.target, function(label, container) {
            if (label != null) {
                label.disabled = false;
            }
        });
    }
        
    private function onPropertyDisabled(event:UIEvent) {
        applyForPropertyRow(event.target, function(label, container) {
            if (label != null) {
                label.disabled = true;
            }
        });
    }
    
    private function applyForPropertyRow(target:Component, cb:Component->Component->Void) {
        if ((target is Property_OLD)) {
            target = cast(target._compositeBuilder, PropertyBuilder).actualEditor;
        }
        var container = target.findAncestor("property-group-item-editor-container", Box, "css");
        var index = _propertyGroupContents.getComponentIndex(container);
        var label = _propertyGroupContents.getComponentAt(index - 1);
        cb(label, container);
    }

    private function onPropertyEditorChange(event:UIEvent) {
        var newEvent = new UIEvent(UIEvent.CHANGE);
        newEvent.target = event.target;
        newEvent.data = event.data;
        var prop = _editorMap.get(event.target);
        if (prop != null) {
            if ((event.target is Button)) {
                newEvent.data = cast(event.target, Button).selected;
            } else {
                newEvent.data = prop.value;
            }
            prop.dispatch(newEvent);
        }
        _component.dispatch(newEvent);
        var pg:PropertyGrid_OLD = _component.findAncestor(PropertyGrid_OLD);
        pg.dispatch(newEvent);
    }

    private function onPropertyEditorClick(event:UIEvent) {
        var newEvent = new UIEvent(UIEvent.CHANGE);
        newEvent.target = event.target;
        newEvent.data = event.data;
        var prop = _editorMap.get(event.target);
        if (prop != null) {
            newEvent.data = prop.value;
            prop.dispatch(newEvent);
        }
        _component.dispatch(newEvent);
        var pg:PropertyGrid_OLD = _component.findAncestor(PropertyGrid_OLD);
        pg.dispatch(newEvent);
    }

    private function buildEditor(property:Property_OLD):Component {
        if (cast(property._compositeBuilder, PropertyBuilder).editor != null) {
            var editor = cast(property._compositeBuilder, PropertyBuilder).editor;
            editor.value = property.value;
            return editor;
        }
        
        var c:Component = null;
        if (c == null) {
            var type = property.type;
            switch (type) {
                case "text":
                    c = new TextField();
                    c.value = property.value;

                case "boolean":
                    c = new CheckBox();
                    c.value = property.value;

                case "int" | "float" | "number":
                    var stepper = new NumberStepper();
                    c = stepper;
                    c.value = property.value;
                    if (property.min != null) {
                        stepper.min = property.min;
                    }
                    if (property.max != null) {
                        stepper.max = property.max;
                    }
                    if (property.step != null) {
                        stepper.step = property.step;
                    }
                    if (property.forceStep != null) {
                        stepper.forceStep = property.forceStep;
                    }
                    if (property.precision != null) {
                        stepper.precision = property.precision;
                    }

                case "list":
                    c = new DropDown();
                    cast(c, DropDown).dataSource = property.dataSource;
                    switch (Type.typeof(property.value)) {
                        case TInt:
                            cast(c, DropDown).selectedIndex = property.value;
                        case _:   
                            c.value = property.value;
                    }

                case "date":
                    c = new DropDown();
                    cast(c, DropDown).type = "date";

                case "action":
                    c = new Button();
                    c.value = property.value;

                case "toggle":
                    c = new Button();
                    cast(c, Button).toggle = true;
                    c.value = property.value;

                default:
                    c = new TextField();
                    c.value = property.value;
            }
        }

        return c;
    }
}