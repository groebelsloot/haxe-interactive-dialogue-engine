package trog.ui ;

//we use the Luxe engine
import luxe.Sprite;
import phoenix.Texture.FilterType;
import luxe.Vector;
import luxe.Text.TextAlign;
import luxe.Color;
import luxe.Text;

import trog.engine.PlayState;//not in this repo
import trog.engine.Reg;//not in this repo
import trog.util.RoomUtil;//not in this repo
import trog.util.Util;//not in this repo
import trog.ui.HUD;//not in this repo
import trog.model.Actor;//not in this repo

import trog.engine.dialogue.DialogueEngine;

class DialogueHUD implements HUD
{
    public var id:String;
	private var hudsize:Int = 50;
    private var HUDBackground:Sprite;
	private var optionTexts:Array<Dynamic> = new Array<Dynamic>();
    private var playState:PlayState;
    private var dialogueEngine:DialogueEngine;
    private var fontSize = 32;
    public var speakingInProgress(default, default):Bool = false;
    public var currentOptions:Array<Text> = new Array<Text>();
    public var overOption:Int = -1;
    public var height:Int;
    public var width:Int;

    public function new(playState:PlayState, dialogueEngine:DialogueEngine) {
        this.id = Reg.DIALOGUE_HUD;
        this.playState = playState;
        this.dialogueEngine = dialogueEngine;

        var texture = Luxe.resources.texture("assets/game/UI/dialogue_background.png");
        this.height = texture.height;
        this.width = texture.width;

        texture.filter_mag = FilterType.nearest;
        HUDBackground = new Sprite( {
            name : 'dialogue_background',
            texture : texture,
            centered: false,
            pos: new Vector(0,Reg.screen_h-texture.height),
            batcher: Reg.batcher_HUD,
            depth:100,
        });
        setVisible(false);
    }

    //Removes all options from the HUD
    public function removeOptions():Void {
        for(opt in currentOptions) {
            opt.visible = false;
        }
    }

    //Sets the options to the HUD
    public function setOptions(options:Array<String>):Void {
    	removeOptions();
        var row:Int = 1;
        for(i in 0...options.length) {
            if(currentOptions[i] == null) {
                currentOptions[i] = new Text({
                    pos : new Vector(25, Reg.screen_h-this.height + (30 * row++)),
                    point_size : fontSize,
                    text : options[i],
                    font : Reg.dialogueFont,
                    color : new Color(0, 0, 0, 1).rgb(0xe3e3e3),
                    batcher : Reg.batcher_DIALOGUE
                });
            } else {
                currentOptions[i].pos = new Vector(25, Reg.screen_h-this.height + (30 * row++));
                currentOptions[i].text = options[i];
                currentOptions[i].color = new Color(0, 0, 0, 1).rgb(0xe3e3e3);
                currentOptions[i].visible = true;
            }
        }
    }

    //Calls the dialogue engine to execute the chosen option
    public function selectOption(index:Int) {
        if (playState.currentGameState == Util.DIALOGUESTATE && !speakingInProgress) {
            dialogueEngine.chooseOption(index);
        }
    }

    //Highlights options that the mouse is hovering over
    public function update() {
        if(playState.currentGameState == Util.DIALOGUESTATE) {
            if(this.currentOptions != null) {
                var i:Int = 1;
                for(n in this.currentOptions) {
                    if(this.overOption == i) {
                        n.color = new Color(0, 0, 0, 1).rgb(0x1e90ff);
                    } else {
                        n.color = new Color(0, 0, 0, 1).rgb(0xe3e3e3);
                    }
                    i++;
                }
            }
        }
    }

    //Hides/shows this HUD
    public function setVisible(visible:Bool) {
        if(HUDBackground != null) {
           HUDBackground.visible = visible;
        }
    }
}