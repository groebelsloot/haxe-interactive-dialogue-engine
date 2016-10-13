package trog.model.dialogue;

//Each dialogue block contains a list of dialogue commands
class DialogueBlock {

	public var blockId:String;
	public var isHeroDecision(default, default):Bool;//does this block reflect choices for the player or simply an NPC response?
	public var commands(default, default):Array<DialogueCommand> = new Array<DialogueCommand>();

	public function new(blockId:String, isHeroDecision:Bool) {
		this.blockId = blockId;
		this.isHeroDecision = isHeroDecision;
	}

}