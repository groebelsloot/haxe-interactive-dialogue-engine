package trog.model.dialogue;

//Each dialogue simply contains a map with dialogue blocks
class Dialogue {

	public var id:String;
	public var blocks(default, default):Map<String, DialogueBlock>;

	public function new(id:String) {
		this.id = id;
	}

}