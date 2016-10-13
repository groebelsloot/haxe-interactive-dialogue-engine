package trog.model.dialogue;

import trog.engine.Reg;

//Whenever the game state must be changed during dialogue
class SetGameStateCommand extends DialogueCommand {

	private var text:String;

	public function new(precondition:String, text:String, optionId:Int=-1, optionIndex:Int=-1) {
		super(precondition, optionId, optionIndex);
		this.text = text;
	}

	override public function run() {

	}

	override public function toLuaString():String {
		var s:String = '';
		if(text.indexOf('.') != -1) {
			var actor:String = text.substring(0, text.indexOf('.'));
			if(text.indexOf('=') != -1) {
				var arr = text.substring(actor.length + 1).split('=');
				s = "\tsetActorState(\""+actor+"\", \""+arr[0]+"\", \""+arr[1]+"\")";
			} else if (text.indexOf('++') != -1) {
				var key = text.substring(text.indexOf('.')+1, text.indexOf('++'));
				var value:Dynamic = Reg.gamestate.getActorState(actor, key);
				if(value == null) {
					value = 0;
				} else {
					value = Std.parseInt(value);
				}
				s = "\tsetActorState(\""+actor+"\", \""+key+"\", \""+(++value)+"\")";
			}
		} else {
			var arr = text.split('=');
			s = "\tsetGameState(\""+arr[0]+"\", \""+arr[1]+"\")";
		}
		return s;
	}

}