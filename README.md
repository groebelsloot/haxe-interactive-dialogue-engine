#Trog's Interactive Dialogue Engine

This is the code for the interactive dialogue engine taken out of 'Trog': the 2D point 'n click adventure game engine. Trog was built by [Mic Uurloon](https://twitter.com/MicUurloon) and [myself](https://twitter.com/jacobjanblom)

All development related to this game engine can be followed on [Groebelsloot](http://groebelsloot.com), which we very sparsely update.
On our blog I wrote three ([part 1](http://www.groebelsloot.com/2016/01/04/interactive-dialogue-adventure-game-part-1/), [part 2](http://www.groebelsloot.com/2016/01/20/interactive-dialogue-part-2/), [part 3](http://www.groebelsloot.com/2016/10/14/interactive-dialogue-part-3/) ) posts about how this interactive dialogue engine works, so whenever trying to use this code, it's most useful to check out the ideas behind it there.

##Dialogue files

Check out the [resources](https://github.com/groebelsloot/haxe-interactive-dialogue-engine/tree/master/resources) directory for two example dialogue files (in [YAML](http://yaml.org/)) that this interactive dialogue engine can handle. The idea behind this format is:

- It tries to avoid mark-up to improve legibility (hence YAML)
- It supports/encourages topic-based clustering of dialogue lines/text, so it's easy to follow the dialogue flow without using any other tool or doing any in game testing
- (with a little help) it should be easy enough to use for non-technical persons, so it should be possible to have your dialogue written directly in this format
- It should be unnecessary to build a separate editor to review your dialogue (see previous points)

##Running the code

Well you can't... unless you build your own game engine using [Haxe](http://haxe.org/) and [Luxe](https://luxeengine.com/) and wire up the code in this repository. Or you can of course port this code and integrate it into your own game.


###Questions?

Feel free to ask anything

We hope this code can be useful to you