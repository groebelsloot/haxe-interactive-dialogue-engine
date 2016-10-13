package trog.model.dialogue;

import trog.engine.Reg;
import trog.model.Actor;

//Whenever an actor needs to speak
class ActorSpeakCommand extends DialogueCommand {

	public var actorId:String;
	public var text:String;

	public function new(precondition:String, actorId:String, text:String, optionId:Int=-1, optionIndex=-1) {
		super(precondition, optionId, optionIndex);
		this.actorId = actorId;
		this.text = text;
	}

	override public function run():Void {
		if(Reg.currentRoomState != null) {
			var actor:Actor = cast(Reg.currentRoomState.currentroom.objects[actorId], Actor);
			Reg.currentRoomState.actorSays(actor, [text]);
		}
	}

	override public function toLuaString():String {
		var s:String = "\tactorSays(\""+actorId+"\", {\""+text+"\"})\n";
		s += "\twaitSignal(\"finishedspeaking_"+actorId+"\")";
		return s;
	}
}