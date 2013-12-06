haxe-gif
========

Haxe Animated Gif Support Library

Implementation of a generic Animated GIF decoder in HAXE.
This library is intended to be used either by OpenFL or Flash output, and provides you with a Sprite with the GIF frames and a simple API to play/stop the animation.

Use Example:
============

import flash.net.URLLoader;
import flash.events.Event;
import gif.AnimatedGif;

class YourClass extends Sprite {
	
	public function addGifImage() {		
		loader = new URLLoader();
		loader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
		loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.load(new URLRequest('http://www.anikaos.com/anime_animated_gifs/hamtaro_anime_animated.gif'));
	}

	private function onComplete(e){
		this.addChild(new AnimatedGif(loader.data).play());
	}

	public function onError(e){
		trace('Error: '+e);
	}
	
}

Licence
=======
http://www.gnu.org/licenses/lgpl.html

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License (LGPL) as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.
  
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
  
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
  

  WebSite: https://github.com/fbricker/haxe-gif
   Author: Federico Bricker
copyright: Copyright (c) 2013 SempaiGames (http://www.sempaigames.com)
