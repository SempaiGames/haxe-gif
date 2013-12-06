/**
 * MMedia Ad Network - Haxe Open API
 * Implementation of a generic Millennial Media Ad Request for Mobile Integrations in HAXE.
 * This library is intended to be used either by OpenFL or Flash output, and provides you with a Sprite that you can placed wherever you need on your app.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License (LGPL) as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
 * 
 * Millennial Media is a registered trademark of Millennial Media, Inc.
 * 
 * @link      https://github.com/fbricker/haxe-mmedia
 * 
 * @license   http://www.gnu.org/licenses/lgpl.html
 * @author    Federico Bricker <fbricker@gmail.com>
 * @copyright Copyright (c) 2013 SempaiGames (http://www.sempaigames.com)
 */

package ;

import flash.net.URLLoader;
import flash.events.Event;
import gif.AnimatedGif;

class Main extends Sprite {
	
	public function new () {		
		super ();
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
