package trog.model.dialogue;

//We use Luxe
import phoenix.Vector;
import phoenix.Rectangle;
import luxe.tween.Actuate;
import luxe.Text.TextAlign;
import luxe.Color;
import luxe.Text;

import trog.engine.Reg;//not in this repo
import trog.model.Actor;//not in this repo

//A dialogue line represents a line of text in the DialogueHUD
class DialogueLine {
	public var actor(default, default):Actor;
	public var speech(default, default):Array<String>;
	public var speechIndex(default, default):Int;
	public var active(default, default):Bool = false;
	private var onFinished:DialogueLine->Dynamic;
	private var maxframes:Int = 65;
	private var nrframes:Int = 0;
	private var fontSize:Int = 38;
	private var curText:Text;

	public function new() {

	}

	public function newLine(actor:Actor, speech:Array<String>, speechIndex:Int, onFinished:DialogueLine->Dynamic, ?framestoshow:Int = 70) {
		this.actor = actor;
		this.speech = speech;
		this.speechIndex = speechIndex;
		this.onFinished = onFinished;
		this.maxframes = framestoshow;
		this.nrframes = 0;
		this.active = true;
		drawText();
	}

	public function skipText() {
		if(this.active) {
			cleanup();
		}
	}

	public function drawText() {
		var text = this.speech[this.speechIndex];
		var actorPos:Vector = Luxe.camera.world_point_to_screen(actor.pos, new Rectangle(0,0, Reg.screen_w, Reg.screen_h));
		var posX:Float = actorPos.x + (actor.size.x / 2);
		var posY:Float = actorPos.y - 40;
		if (actor == Reg.hero) {
			posX = actorPos.x;//- (actor.size.x / 6);
			posY = actorPos.y - (actor.size.y);
		}
		posY -= (fontSize * 2);
		if(posX <= 5) {
			posX = 5;
		}
		var words:Array<String> = text.split(' ');
		var line:String = '';
		var lines:Array<String> = new Array<String>();
		var rows:Int = 0;
		for(i in 0...words.length) {
			line += words[i] + ' ';
			if(line.length >= 32 || i == words.length -1) {
				lines.push(line);
				line = '';
			}
		}
		if(curText == null) {
			curText = new Text({
				pos : new Vector(posX, posY + (rows++ * fontSize)),
				point_size : fontSize,
				font: Reg.dialogueFont,
				align: TextAlign.center,
				text : lines.join('\n'),
				color : new Color(1, 1, 1, 1.0),
				batcher : Reg.batcher_DIALOGUE,
				visible : true
			});
		} else {
			curText.visible = true;
			curText.pos = new Vector(posX, posY + (rows++ * fontSize));
			curText.text = lines.join('\n');
			curText.color = new Color(1, 1, 1, 1.0);
		}
	}

	public function update() {
		this.nrframes++;
		if (this.nrframes >= this.maxframes) {
			this.active = false;//deactivate so the update won't be called by the playstate
			this.curText.color.tween(0.3, {a:0.0} ).onComplete(cleanup);
		}
	}

	public function cleanup() {
		curText.visible = false;
		this.onFinished(this);
	}

}