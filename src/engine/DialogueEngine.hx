package trog.engine.dialogue;//does not match this repo

import lua.Lua;//not in this repo
import trog.model.Actor;//not in this repo
import trog.util.Util;//not in this repo

import trog.engine.dialogue.DialogueUtil;
import trog.model.dialogue.Dialogue;
import trog.model.dialogue.DialogueBlock;
import trog.model.dialogue.DialogueCommand;
import trog.model.dialogue.ActorSpeakCommand;

class DialogueEngine {

	private var playState:PlayState;
	public var currentDialogue:Dialogue;
	private var currentBlock(default, default):DialogueBlock;
	private var currentOptions:Array<Array<DialogueCommand>>;//deze commands worden uitgevoerd als de hero een keuze maakt
	private var currentCommand:DialogueCommand;

	public function new(playState) {
		this.playState = playState;
	}

	//This function gets called from the PlayState, which in turn is wired up via Lua scripting
	public function runDialogue(actorId:String) {
		//only load the data once per dialogue
		if(currentDialogue == null) {
			currentDialogue = DialogueUtil.loadDialogue(actorId, null);
		}
		//if loaded successfully run the first_encounter dialogue block
		if(currentDialogue != null) {
			playState.currentGameState = Util.DIALOGUESTATE;
			runDialogueBlock(currentDialogue.blocks.get('first_encounter'));
		}
	}


	//Runs a single dialogue block. If it's a 'decision block' generate the options for the player and show the HUD.
	//Otherwise generate Lua code from the NPC's dialogue block and run it
	public function runDialogueBlock(block:DialogueBlock):Void {
		currentBlock = block;
		if(block.blockId == 'exit') {
			dialogueDone();
		} else if(block.isHeroDecision == true) {

			//generate the current options to be chosen and store them in a new global variable
			this.currentOptions = new Array<Array<DialogueCommand>>();
			var texts:Array<String> = new Array<String>();
			var optionText:String = '';
			for(c in block.commands) {
				//filter out commands that do not meet the precondition
				if(validatePreconditionString(c.precondition, c.optionId, c.optionIndex)) {

					//relate the list of commands to the correct dialogue option nr
					if(this.currentOptions[c.optionId -1] == null) {
						this.currentOptions[c.optionId-1] = new Array<DialogueCommand>();
					}
					this.currentOptions[c.optionId-1].push(c);

					//add speak commands in a separate array for the HUD
					if(Std.is(c, ActorSpeakCommand)) {
						optionText = cast(c, ActorSpeakCommand).text;
						if(texts[c.optionId-1] == null) {
							texts[c.optionId-1] = optionText;
						} else {
							texts[c.optionId-1] += optionText;
						}
					}
				}
			}
			//remove all empty options, so the UI does not show empty rows of options
			this.currentOptions = this.currentOptions.filter(function(v) {
				return v != null;
			});
			//prepare the PlayState and show the DialogueHUD
			playState.setDialogueHUDOptions(texts.filter(function(v){return v != null;}));
			playState.setHUD(Reg.DIALOGUE_HUD);
		} else {
			//clear the dialogueHUD (if visible)
			playState.clearDialogueHUDOptions();
			var luaFunction:String = 'function temp()\n';
			for(c in block.commands) {
				if(validatePreconditionString(c.precondition)) {
					luaFunction += c.toLuaString() + '\n';
				}
			}
			luaFunction += 'end';
			playState.lua.execute(luaFunction);
			playState.lua.execute('runProcess(temp)');
		}
	}

	//Validates whether a DialogueCommand meets the precondition
	private function validatePreconditionString(precondition:String, optionId:Int=-1, optionIndex:Int=-1):Bool {
		if(precondition != null) {
			var arr = precondition.split('==');
			//simply check whether the condition is true
			if(arr.length == 2) {
				return Reg.gamestate.preconditionMet(arr[0], arr[1]);
			} else if(precondition == 'once') {
				//validate the 'once' precondition by checking whether the game state has
				//recored this dialogue command to be executed earlier
				var stateVar:String = getDialogueOptionGameStateVarName(optionId);
				var lastIndex:Dynamic = Reg.gamestate.getGameState(stateVar);
				if(lastIndex == null && optionIndex == 0) {
					Reg.gamestate.setGameState(stateVar, optionIndex);
					return true;
				} else if(Std.parseInt(lastIndex) == optionIndex) {
					return true;
				}
				return false;
			} //TODO the 'random' behavioral pattern should/could be implemented
		}
		return true;
	}

	//generates a game state variable name for recording information about a particular dialogue line
	//(currently needed for supporting the 'once' precondition)
	private function getDialogueOptionGameStateVarName(optionId:Int=-1) {
		return 'dialogue_' + currentDialogue.id + '_block_' + currentBlock.blockId + '_' + optionId + '_index';
	}

	//generates the Lua code for the selected option and runs it
	public function chooseOption(index:Int):Void {
		if(this.currentOptions[index] != null) {
			var commands:Array<DialogueCommand> = this.currentOptions[index];//FIXME this index might not match in theory!
			var luaFunction:String = 'function temp()\n';
			var optionId:Int = -1;
			var optionIndex:Int = -1;
			for(c in commands) {
				optionId = c.optionId;
				optionIndex = c.optionIndex;
				if(validatePreconditionString(c.precondition, c.optionId, c.optionIndex)) {
					luaFunction += c.toLuaString() + '\n';
				}
			}
			if(optionIndex != -1) {
				luaFunction += "\tsetGameState(\""+getDialogueOptionGameStateVarName(optionId)+"\", \""+(++optionIndex)+"\")\n";
			}
			luaFunction += 'end';
			trace(luaFunction);
			playState.lua.execute(luaFunction);
			playState.lua.execute('runProcess(temp)');
		} else {
			trace('index error in option choice');
		}
	}

	//Stops the dialogue and sets the current game state to IDLE (the actor is standing still)
	public function dialogueDone():Void {
		currentDialogue = null;
		playState.setHUD(Reg.GAME_HUD);
		playState.currentGameState = Util.IDLESTATE;
		playState.finishedDialogue();
	}

}