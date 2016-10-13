package trog.model.dialogue;

import trog.engine.Reg;

//Whenever a specific Lua function must be executed during dialogue
class ExecCommand extends DialogueCommand {

	public var actor:String;
	public var gameFunction:String;

	public function new(precondition:String, actor:String, gameFunction:String, optionId:Int=-1, optionIndex:Int=-1) {
		super(precondition, optionId, optionIndex);
		this.actor = actor;
		this.gameFunction = gameFunction;
	}

	override public function run() {
		trace('Executing lua function!');
	}

	override public function toLuaString():String {
		if (Reg.currentRoomState.luaFunctionExists(gameFunction)) {
			var s:String = "\t" + gameFunction+ "()";
			return s;
		}
		return '';
	}
}