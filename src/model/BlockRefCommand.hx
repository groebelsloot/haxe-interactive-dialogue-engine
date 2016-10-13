package trog.model.dialogue;

//Whenever the next dialogue block must be executed (usually switching speaker)
class BlockRefCommand extends DialogueCommand {

	public var ref:String;

	public function new(precondition:String, ref:String, optionId:Int=-1, optionIndex=-1) {
		super(precondition, optionId, optionIndex);
		this.ref = ref;
	}

	override public function run() {
		trace('This is not a real command');
	}

	override public function toLuaString():String {
		var s:String = "\tcontinueDialogue(\""+ref.substring(1)+"\")";
		return s;
	}
}