package view;

import flash.geom.Rectangle;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.input.mouse.FlxMouseEventManager;

import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.core.HelixText;

class TutorialWindow extends FlxUI9SliceSprite {

    private static inline var TEXT_FIELD_OFFSET_X:Int = 30;
    private static inline var TEXT_FIELD_OFFSET_Y:Int = 20;
    private static inline var FONT_SIZE:Int = 24;
    
    private var textField:HelixText;
    private var extraImage:HelixSprite;

    public function new(x:Int, y:Int, width:Int, height:Int, text:String, extraImage:String = "") {       
        super(x, y, "assets/images/ui/button-9scale.png", 
            new Rectangle(0, 0, width, height),
            // The image is 50x50. Border gems are (20, 15).
            // Add/subtract appropriately; the center area goes from (20, 15) to (30, 35).
            [20, 15, 30, 35]);
        
        HelixState.current.add(this);

        var maxWidth:Int = width - 2 * TEXT_FIELD_OFFSET_X;
        this.textField = new HelixText(TEXT_FIELD_OFFSET_X, TEXT_FIELD_OFFSET_Y, text, FONT_SIZE, maxWidth);
        this.textField.wordWrap = true;

        if (extraImage != "") {
            this.extraImage = new HelixSprite(extraImage);
        }

        FlxMouseEventManager.add(this, function(me:TutorialWindow):Void {
            // TODO: add a callback so we can chain tutorial windows?
            this.destroy();
        });

        // Trigger setters to move text to correct location
        this.x = x;
        this.y = y;
    }

    override public function set_x(x:Float):Float
    {
        var toReturn = super.set_x(x);
        if (this.textField != null) {
            this.textField.x = x + TEXT_FIELD_OFFSET_X;
        }
        if (this.extraImage != null) {
            // Center image horizontally
            var space = this.width - 2 * TEXT_FIELD_OFFSET_X;
            this.extraImage.x = this.x + (space / 2);
        }
        return toReturn;
    }

    override public function set_y(y:Float):Float
    {
        var toReturn = super.set_y(y);
        if (this.textField != null) {
            this.textField.y = y + TEXT_FIELD_OFFSET_Y;
        }
        if (this.extraImage != null) {
            this.extraImage.y = y + TEXT_FIELD_OFFSET_Y;
            if (this.textField != null) {
                // locate image under the text
                this.extraImage.y += this.textField.height;
            }
        }
        return toReturn;
    }

    override public function destroy():Void {
        if (this.textField != null) {
            this.textField.destroy();
        }

        if (this.extraImage != null) {
            this.extraImage.destroy();
        }

        super.destroy();
    }
}