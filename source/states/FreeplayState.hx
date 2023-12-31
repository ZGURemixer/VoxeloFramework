package states;

#if desktop
import backend.Discord.DiscordClient;
#end
import states.editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.sound.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

// Imports external libraries
import states.FreeplaySelectState;
import haxe.Json;
import haxe.format.JsonParser;
import backend.Paths;

#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

// Placeholders
var currentWeekDifficultiesSplit = ["Easy", "Normal", "Hard"];
var currentWeekDifficulties2 = "";


class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	// var scoreBG:FlxSprite;
	// var scoreText:FlxText;
	// var diffText:FlxText;
	// var lerpScore:Int = 0;
	// var lerpRating:Float = 0;
	// var intendedScore:Int = 0;
	// var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<objects.HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	// Variable initialization
	public var packList = JsonParser.parse(Paths.getTextFromFile("data/packlist.json"));
	public var selPack:String = "tutorial";
	public var seldifficulties:Array<String> = [];
	public var selcharacter:String = "test";
	public var selcolor:Dynamic = "poop";
	public var selsong:Dynamic = "poop";

	// Array initialization
	public var packdiffs:Array<Array<String>> = [];
	public var packchars:Array<String> = [];
	public var packcolors:Array<Dynamic> = [];
	public var packsongs:Array<String> = [];

	override function create()
	{
		selPack = FreeplaySelectState.selectedPack;
		var selPack2 = Reflect.field(packList.packs, selPack);
		// Iterate through data within the pack

        for (songName in Reflect.fields(selPack2.songs))
			{
				selsong = Reflect.field(selPack2.songs, songName);
				seldifficulties = selsong.diffs;
				selcharacter = selsong.info[0];
				selcolor = selsong.info[1];

				// Pushing the data into the array
				packsongs.push(songName);
				packdiffs.push(seldifficulties);
				packchars.push(selcharacter);
				packcolors.push(selcolor);
			}

		// trace(packsongs);
		trace(packdiffs);
		// trace(packchars);
		// trace(packcolors);

		curDifficulty = -1;
		
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		// for (i in 0...WeekData.weeksList.length) {
		// for (i in 0...theNumberOne) {
			// if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(FreeplaySelectState.selectedPack);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			// for (j in 0...leWeek.songs.length)
			
			var sp2songs:Array<Dynamic> = Reflect.fields(selPack2.songs);
			for (j in 0...Reflect.fields(selPack2.songs).length)
			{
				// leSongs.push(leWeek.songs[j][0]);
				// leChars.push(leWeek.songs[j][1]);
				leSongs.push(packsongs[j]);
			}

			// trace(leSongs);

			WeekData.setDirectoryFromWeek(leWeek);
			for (csgo in 0...packsongs.length)
			{
				var colors:Array<Int> = packcolors[csgo];
				// var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				// addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				addSong(packsongs[csgo], 1, packchars[csgo], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		// }
		backend.WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = backend.CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		// bg.antialiasing = backend.ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			// Taken from Mic'd Up
			songText.isMenuItem = true;
			songText.isCustomMenuItem = true;
			songText.itemType = "D-Shape";
			songText.targetY = i - curSelected;
			grpSongs.add(songText);

			var maxWidth = 980;
			if (songText.width > maxWidth)
			{
				songText.scaleX = maxWidth / songText.width;
			}
			songText.snapToPosition();

			backend.Mods.currentModDirectory = songs[i].folder;
			var icon:objects.HealthIcon = new objects.HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		// scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, RIGHT);

		// scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		// scoreBG = new FlxSprite((FlxG.width * 0.7) - 6, 0).makeGraphic(1, 66, 0xFF000000);
		// scoreBG.alpha = 0.6;
		// add(scoreBG);

		// diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		// diffText.font = scoreText.font;
		// add(diffText);

		// add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		/* if(lastDifficultyName == '')
		{
			lastDifficultyName = backend.CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, backend.CoolUtil.defaultDifficulties.indexOf(lastDifficultyName))); */
		
		changeSelection();
		// // changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("comic.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		
		currentWeekDifficultiesSplit = packdiffs[0];
		backend.CoolUtil.difficulties = currentWeekDifficultiesSplit;
		// THIS FIXES THE DIFFICULTY BUG
/* 		var currentWeekData = WeekData.weeksLoaded.get(FreeplaySelectState.selectedPack);
		var currentWeekDifficulties = currentWeekData.difficulties;


		if (currentWeekDifficulties != null) {
			if (currentWeekDifficulties != "") {
				currentWeekDifficultiesSplit = currentWeekDifficulties.split(', ');
				backend.CoolUtil.difficulties = currentWeekDifficultiesSplit;
			} else {
				backend.CoolUtil.difficulties = ["Easy", "Normal", "Hard"];
			}
		} else {
			backend.CoolUtil.difficulties = ["Easy", "Normal", "Hard"];
		};
		
		// trace(currentWeekDifficultiesSplit); */

		// var firstDiffUppercase = currentWeekDifficultiesSplit[0].toUpperCase();

		// diffText.text = '< ' + firstDiffUppercase + ' >';

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		/* lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, backend.CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, backend.CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		} */

		// scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		// positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					// changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				// changeDiff();
			}
		}

		/* if (controls.UI_LEFT_P)
			// changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			// changeDiff(1);
		else if (upP || downP) // changeDiff(); */

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new FreeplaySelectState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new substates.GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			// var poop:String = "fresh-hard";
			//var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			var poop:String = songLowercase;
			curDifficulty = 1;
			trace(poop);
			#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				// poop = songLowercase;
				// curDifficulty = 1;
				// trace('Couldnt find file');
			}
			// trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			// PlayState.storyDifficulty = curDifficulty;
			PlayState.storyDifficulty = 1;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new substates.ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	/* function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = currentWeekDifficultiesSplit.length-1;
		if (curDifficulty >= currentWeekDifficultiesSplit.length)
			curDifficulty = 0;

		lastDifficultyName = currentWeekDifficultiesSplit[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + backend.CoolUtil.difficultyString() + ' >';
		// positionHighscore();

		// trace("The current difficulty selected is:");
		// trace(curSelected);
	} */

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		// intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		// backend.CoolUtil.difficulties = currentWeekDifficultiesSplit;
		// var diffStr:String = WeekData.getCurrentWeek().difficulties;

		// currentWeekDifficulties2 = WeekData.weeksLoaded.get(FreeplaySelectState.selectedPack).difficulties;

/* 		var diffStr:String = currentWeekDifficulties2;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			//var diffs:Array<String> = diffStr.split(',');
			var diffs:Array<String> = packdiffs[1];
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				backend.CoolUtil.difficulties = currentWeekDifficultiesSplit;
			}
		} */
		
		// if(backend.CoolUtil.difficulties.contains(backend.CoolUtil.defaultDifficulty))
		// {
		// 	curDifficulty = Math.round(Math.max(0, currentWeekDifficultiesSplit.indexOf(backend.CoolUtil.defaultDifficulty)));
		// }
		// else
		// {
		// 	curDifficulty = 0;
		// }

		// var newPos:Int = currentWeekDifficultiesSplit.indexOf(lastDifficultyName);
		// //trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		// if(newPos > -1)
		// {
		// 	curDifficulty = newPos;
		// }
	}

	/* private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	} */
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = backend.Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}