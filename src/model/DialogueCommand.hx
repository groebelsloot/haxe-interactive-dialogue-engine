package trog.model.dialogue;

//A dialogue command represents each line in a dialogue block, has an optional precondition
//and optional optionId/optionIndex in case this line represents a choice for the player/hero
class DialogueCommand {

	public var precondition(default, default):String;
	public var optionId(default, default):Int;
	public var optionIndex(default, default):Int;

	public function new(precondition:String, optionId:Int = -1, optionIndex = -1) {
		this.precondition = precondition;
		this.optionId = optionId;
		this.optionIndex = optionIndex;
	}

	//Each dialogue command can be executed, but actually I don't use this, since I always
	//translate & call everything via Lua
	public function run():Void {

	}

	//Each dialogue command can be expressed in Lua
	public function toLuaString():String {
		return null;
	}

}