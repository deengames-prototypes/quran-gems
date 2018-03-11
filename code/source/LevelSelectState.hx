package;

import flixel.FlxG;
import flixel.tweens.FlxTween;

import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;
import helix.core.HelixState;
import helix.core.HelixText;
using haxesharp.collections.Linq;

import model.Level;
import utils.LevelPersister;
import utils.LevelMaker;
import view.Gem;
import view.LevelButton;

class LevelSelectState extends HelixState
{   
    private static inline var Y_PADDING = 65;
    private static inline var PADDING:Int = 16;
    private static inline var NUM_COLUMNS:Int = 3;
    private static inline var FONT_SIZE:Int = 32;
    private static inline var GEM_SPEED:Int = 300;
    
    private var showAnimation:Bool = false;
    private var gemsText:HelixText;
    private var levels:Array<Level>;
    private var masjid:HelixSprite;

    private var currentGems:Int = 0;
    private var totalGems:Int = 0;

    public function new(showAnimation:Bool = false) {
        super();
        this.showAnimation = showAnimation;
    }

	override public function create():Void
	{
		super.create();

        this.levels = new LevelMaker().createLevels();
        var levelReached = LevelPersister.getMaxLevelReached();
        var buttons = this.createButtons(this.levels, levelReached);
        this.addMasjidAndGauge(buttons);

        var gemsPerLevel = PlayState.NUM_GEMS_TO_WIN;
        this.currentGems = levelReached * gemsPerLevel;
        this.totalGems = this.levels.length * gemsPerLevel;
        this.gemsText = new HelixText(PADDING, Std.int(PADDING / 2), "", FONT_SIZE);

        if (this.showAnimation) {
            // Pretend we have one level less in gems because the animation will
            // show and increment/update this value.
            this.currentGems -= gemsPerLevel; 
            this.showGemAnimation();
        }

        this.updateGemsText();        
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

    private function createButtons(levels:Array<Level>, maxLevelReached:Int):Array<LevelButton>
    {
        var levelsPerRow = Std.int(Math.ceil(levels.length / NUM_COLUMNS)); // three types of levels
        var buttons = new Array<LevelButton>();

        for (levelNum in 0 ... levels.length)
        {
            var level = levels[levelNum];
            var isEnabled = maxLevelReached >= levelNum;

            var button = new LevelButton(levelNum, level, isEnabled);
            button.move(
                PADDING + (levelNum % levelsPerRow) * (PADDING + button.width),
                Y_PADDING + Std.int(levelNum / levelsPerRow) * (PADDING + button.height));
            buttons.add(button);
        }

        return buttons;
    }

    private function addMasjidAndGauge(buttons:Array<LevelButton>):Void
    {
        var maxX:Float = 0;
        for (button in buttons) {
            if (button.x + button.width > maxX) {
                maxX = button.x + button.width;
            }
        }
        
        // Center horizontally in available space
        this.masjid = new HelixSprite("assets/images/masjid-large.png");
        var freeSpace = FlxG.width - maxX - masjid.width - (2 * PADDING);
        masjid.move(maxX + PADDING + (freeSpace / 2), Y_PADDING);
    }

    private function showGemAnimation():Void
    {
        for (i in 0 ... PlayState.NUM_GEMS_TO_WIN) {
            var gem = new Gem(i + 1);
            gem.showAsGem();

            // Off-screen bottom-left
            gem.x = -(gem.width + PADDING) * (i + 1);
            gem.y = FlxG.height - gem.height;
            // Stop here (centered under the masjid)
            var stopX = masjid.x + ((masjid.width - gem.width) / 2);
            // Move up here (centered in the masjid)
            var absorbtionY = masjid.y + ((masjid.height - gem.height) / 2);

            // Israa
            FlxTween.linearMotion(gem, gem.x, gem.y, stopX, gem.y, GEM_SPEED, false)
                // Mi'raaj
                .then(FlxTween.linearMotion(gem, stopX, gem.y, stopX, absorbtionY, GEM_SPEED, false,
                {
                    onComplete: function(tween:FlxTween):Void {                        
                        gem.destroy();
                        this.currentGems += 1;
                        this.updateGemsText();
                    }
                }));
        }
    }

    private function updateGemsText():Void
    {
        this.gemsText.text = '${currentGems}/${totalGems} gems';
    }
}