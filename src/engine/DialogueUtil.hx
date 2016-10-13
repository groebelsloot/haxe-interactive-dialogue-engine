package trog.engine.dialogue;

//for handling YAML
import yaml.Yaml;
import yaml.Parser;
import yaml.util.ObjectMap;

import trog.engine.Reg;//not in this repo
import trog.model.Actor;//not in this repo
import trog.model.dialogue.Dialogue;//not in this repo
import trog.model.dialogue.DialogueBlock;//not in this repo

//all types of dialogue commands
import trog.model.dialogue.DialogueCommand;
import trog.model.dialogue.ActorSpeakCommand;
import trog.model.dialogue.ExecCommand;
import trog.model.dialogue.SetGameStateCommand;
import trog.model.dialogue.BlockRefCommand;

class DialogueUtil {

	//These globals are used by parseCommandArray (which is pretty ugly... within the function they kept being reset somehow)
	private static var oldId:Int = 0;
	private static var optIndex:Int = 0;
	private static var curId:Int = 0;

	//Loads the dialogue from a .yaml file
	public static function loadDialogue(actorId: String, roomName:String):Dialogue {
		var data:AnyObjectMap = Yaml.parse(Luxe.resources.text("assets/game/dialogue/" + actorId + ".yaml").asset.text);
        var d:Dialogue = new Dialogue(actorId);
        var blocks:Map<String, DialogueBlock> = new Map<String, DialogueBlock>();
        oldId = 0;
        optIndex = 0;
        curId = 0;
        //each k is a DialogueBlock, make sure to distinguish between a hero block and another block
        for(k in data.keys()) {
			var commands = parseCommandArray(data.get(k), null);
			var block:DialogueBlock = new DialogueBlock(k, isHeroDecisionBlock(commands));
			block.commands = commands;
        	blocks.set(k, block);
        }
        d.blocks = blocks;
        return d;
	}

	//This is the embarrasing parse function, which is the heart of loading the dialogue into objects
	private static function parseCommandArray(arr:Array<Dynamic>, actor:Dynamic, optionId:Int = -1, optionIndex = -1):Array<DialogueCommand> {
		var commands:Array<DialogueCommand> = new Array<DialogueCommand>();
		var pre:String = null;
		for(o in 0...arr.length) {
			var n = arr[o];

			if(Std.is(n, String)) {//in case of a string (so no key/value pair)
    			var s:String = arr[o];
    			if(s.charAt(0) == ':') {//a reference command
    				commands.push(new BlockRefCommand(pre, s, optionId, optionIndex));
    			} else if(s.charAt(0) == '$') {//a set command
    				commands.push(new SetGameStateCommand(pre, s.substring(1), optionId, optionIndex));
    			} else if(s.charAt(0) == '_' && s.charAt(1) == '_') {//an execute command
    				commands.push(new ExecCommand(pre, actor, s.substring(2), optionId, optionIndex));
    			} else {//a speaking command
    				commands.push(new ActorSpeakCommand(pre, actor, s, optionId, optionIndex));
    			}
    		} else if (Std.is(n, ObjectMap)) {//whenever it's a line with a key/value pair
				//loop trough the keys of the object
				var om:ObjectMap<Dynamic, Dynamic> = arr[o];//FIXME somehow had trouble casting this
				for(x in om.keys()) {
					if (x == 'if') {//a precondition bit (should ALWAYS be the first in line)
						pre = om.get(x);
					} else if(Std.parseInt(x) != null) {//a hero dialogue option block (so whenever the key is a number)
						curId = Std.parseInt(x);
						if(oldId == curId) {
							optIndex++;
						} else {
							optIndex = 0;
						}
						oldId = curId;//it's ugly to use the global variable, but it works
						for(cmd in parseCommandArray(om.get(x), Reg.hero.objectid, curId, optIndex)) {
							commands.push(cmd);
						}
					} else { //an actor speaking line or block
						if(Std.is(om.get(x), String)) {
							commands.push(new ActorSpeakCommand(pre, x, om.get(x), optionId, optionIndex));
						} else {
							for(cmd in parseCommandArray(om.get(x), x, optionId, optionIndex)){
								commands.push(cmd);
							}
						}
					}
				}
    		}
		}
		return commands;
	}

	//The function that can check whether a line is an option for the hero to choose from
	private static function isHeroDecisionBlock(commands:Array<DialogueCommand>):Bool {
		for(c in commands) {
			if(Std.is(c, ActorSpeakCommand)) {
				var asc = cast(c);
				if(asc.optionId != -1) {
					return true;
				}
			}
		}
		return false;
	}

}