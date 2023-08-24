// THIS CODE HAS BEEN PARTIALLY TAKEN FROM https://gamebanana.com/questions/29334?post=10099553

package states;

import haxe.ds.Map;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

#if desktop
import backend.Discord.DiscordClient;
#end

// IMPORTS THE LIST OF ALL THE WEEKS
import backend.WeekData;
import backend.Paths;
import backend.Highscore;

// IMPORTS THE NECESSARY MODULES FOR PARSING A JSON
import haxe.Json;
import haxe.format.JsonParser;
import backend.Paths;

// CONVERTS FREEPLAYCATS INTO AN EMPTY ARRAY.
var freeplayCats:Array<String> = [];

// INITIATES LIST OF PACKS
var packList:Array<String> = [];

class FreeplaySelectState extends MusicBeatState{

    // CHANGES THE INITIAL PACK LIST'S VALUES
    public var packList = JsonParser.parse(Paths.getTextFromFile("data/packlist.json"));

    // THIS VARIABLE FIXES THE DIFFICULTY GLITCH
    public var currentWeekDifficultiesAlt = ["Easy", "Normal", "Hard"];

    public static var curCategory:Int = 0;

    public var NameAlpha:Alphabet;

    var grpCats:FlxTypedGroup<Alphabet>;

    var curSelected:Int = 0;

    var BG:FlxSprite;

    var categoryIcon:FlxSprite;

    // ADDING THIS VARIABLE TO AVOID CRASHES
    public static var selectedPack = "";

    override function create(){

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting a pack", null);
		#end

        // RESETS FREEPLAYCATS
        freeplayCats = [];

        // MAKES THE GAME LOOK FOR WEEKS
        WeekData.reloadWeekFiles();

        // trace(WeekData.weeksLoaded);
        // for (i in WeekData.weeksLoaded.keys()) {
        //     freeplayCats.push(i);
        // };
    
        for (packName in Reflect.fields(packList.packs)) {
            freeplayCats.push(packName);
        };


        BG = new FlxSprite().loadGraphic(Paths.image('morie'));

        BG.updateHitbox();

        BG.screenCenter();

        add(BG);

        categoryIcon = new FlxSprite().loadGraphic(Paths.image('weekicons/week_icon_' + freeplayCats[curSelected].toLowerCase()));

        categoryIcon.updateHitbox();

        categoryIcon.screenCenter();

        add(categoryIcon);

        /*grpCats = new FlxTypedGroup<Alphabet>();

        add(grpCats);

        for (i in 0...freeplayCats.length)

        {

            var catsText:Alphabet = new Alphabet(0, (70 * i) + 30, freeplayCats[i], true, false);

            catsText.targetY = i;

            catsText.isMenuItem = true;

            grpCats.add(catsText);

        }*/

        NameAlpha = new Alphabet(40,(FlxG.height / 2) - 282,freeplayCats[curSelected],true);

        NameAlpha.screenCenter(X);

        // Highscore.load();

        add(NameAlpha);

        changeSelection();

        super.create();

    }

    override public function update(elapsed:Float){

       

        if (controls.UI_LEFT_P)

            changeSelection(-1);

        if (controls.UI_RIGHT_P)

            changeSelection(1);

        if (controls.BACK) {

            FlxG.sound.play(Paths.sound('cancelMenu'));

            MusicBeatState.switchState(new MainMenuState());

        }

        if (controls.ACCEPT){

            // SETS THE VARIABLE TO THE VALUE OF THE SELECTED PACK
            selectedPack = freeplayCats[curSelected];
            MusicBeatState.switchState(new FreeplayState());

        }

        curCategory = curSelected;

        super.update(elapsed);

    }

    function changeSelection(change:Int = 0) {

        curSelected += change;

        if (curSelected < 0)

            curSelected = freeplayCats.length - 1;

        if (curSelected >= freeplayCats.length)

            curSelected = 0;

        var bullShit:Int = 0;

        /*for (item in grpCats.members) {

            item.targetY = bullShit - curSelected;

            bullShit++;

            item.alpha = 0.6;

            if (item.targetY == 0) {

                item.alpha = 1;

            }

        }*/

        NameAlpha.destroy();

        NameAlpha = new Alphabet(40,(FlxG.height / 2) - 282,freeplayCats[curSelected],true);

        NameAlpha.screenCenter(X);

        add(NameAlpha);

        categoryIcon.loadGraphic(Paths.image('weekicons/week_icon_' + (freeplayCats[curSelected].toLowerCase())));

        FlxG.sound.play(Paths.sound('scrollMenu'));

        // THIS TRACES THE CURRENTLY LOADED WEEKS
        // if (WeekData.weeksLoaded[freeplayCats[curSelected]].difficulties != null) {
        //     if (WeekData.weeksLoaded[freeplayCats[curSelected]].difficulties != "") {
        //         currentWeekDifficultiesAlt = WeekData.weeksLoaded[freeplayCats[curSelected]].difficulties.split(", ");
        //     } else {
        //         currentWeekDifficultiesAlt = ["Easy", "Normal", "Hard"];
        //     };
        // } else {
        //     currentWeekDifficultiesAlt = ["Easy", "Normal", "Hard"];
        // };
        trace(currentWeekDifficultiesAlt);
    }

}