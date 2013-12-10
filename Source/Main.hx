/**
 * HaxeGif - Haxe AnimatedGIF for Flash and OpenFL
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
 * @link      https://github.com/fbricker/haxe-gif
 * 
 * @license   http://www.gnu.org/licenses/lgpl.html
 * @author    Federico Bricker <fbricker@gmail.com>
 * @copyright Copyright (c) 2013 SempaiGames (http://www.sempaigames.com)
 */

package ;

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

		bytes=haxe.io.Bytes.ofString(Assets.getText("images/anim2.gif"));
		this.addChild(new AnimatedGif(bytes).play());

		gif1.play();
		this.addEventListener(flash.events.Event.ENTER_FRAME,function(e){gif1.rotation+=3;});
	}
}
