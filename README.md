#haxe-gif

Haxe Animated Gif Support Library

Implementation of a generic Animated GIF decoder in HAXE.
This library is intended to be used either by OpenFL or Flash output, and provides you with a Sprite with the GIF frames and a simple API to play/stop the animation.

###Use Example:

```haxe
import openfl.Assets;
import flash.display.Sprite;
import gif.AnimatedGif;
import haxe.io.Bytes;

class Main extends Sprite {	
	public function new () {		
		super ();
		var bytes:Bytes=Bytes.ofString(Assets.getText("images/anim1.gif"));
		var gif1=new AnimatedGif(bytes);
		this.addChild(gif1);
		gif1.y=100; gif1.x=200;
		gif1.play();
		gif1.rotation=32;

		bytes=haxe.io.Bytes.ofString(Assets.getText("images/anim2.gif"));
		this.addChild(new AnimatedGif(bytes).play());
	}
}
```

###How to install:

```bash
haxelib install haxe-gif
```

###License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy; 2013 SempaiGames (http://www.sempaigames.com)

Author: Federico Bricker


###Thanks to & Credits

* This library is based on Heriet's hxPixel library (https://github.com/heriet/hxPixel)
* The decoding algorithm was ported to haxe by Daniel Uranga (https://github.com/DanielUranga)
