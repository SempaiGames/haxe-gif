package gif;

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import gif.images.GifDecoder;
import gif.images.GifFrameInfo;
import flash.utils.Timer;

class AnimatedGif extends Sprite{

	private var bmaps:Array<Bitmap>;
	private var frames:Array<GifFrameInfo>;
	var pos:Int=0;
	public var playing(default,null):Bool;
	private var timer:Timer;

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	public function new(data){
		super();
		bmaps = new Array<Bitmap>();
		frames = GifDecoder.decode(data).frameList;
		for(gifFrameInfo in frames){
			var bitmapData=new BitmapData(gifFrameInfo.imageWidth,gifFrameInfo.imageHeight);
			var rgbaImageData = gifFrameInfo.getRgbaImageData();
			var index = 0;
			if (gifFrameInfo.interlaceFlag)
			{
				var startingLine = 0;
				var lineIncrement = 8;
				var line = 0;
				for (pass in 0...4)
				{
					switch (pass)
					{
						case 0: { startingLine = 0; lineIncrement = 8; }
						case 1: { startingLine = 4; lineIncrement = 8; }
						case 2: { startingLine = 2; lineIncrement = 4; }
						case 3: { startingLine = 1; lineIncrement = 2; }
					}
					line = startingLine;
					while (line < gifFrameInfo.imageHeight)
					{
						for (xIndex in 0...gifFrameInfo.imageWidth)
						{
							var rgba = rgbaImageData[index];
							bitmapData.setPixel32(xIndex, line, rgba);
							index++;
						}
						line += lineIncrement;
					}
				}
			}
			else
			{
				for (i in 0...rgbaImageData.length)
				{
					var rgba = rgbaImageData[i];
					bitmapData.setPixel32(Std.int(i % gifFrameInfo.imageWidth), Std.int(i/gifFrameInfo.imageWidth), rgba);
				}
			}
			
			var bitmap=new Bitmap(bitmapData);
			bitmap.x=gifFrameInfo.imageLeftPosition;
			bitmap.y=gifFrameInfo.imageTopPosition;
			this.addChild(bitmap);
			bitmap.visible=false;
			bmaps.push(bitmap);
			gifFrameInfo.clearBinaryData();
		}
		bmaps[0].visible=true;
		pos=-1;
		playing=false;
		timer=null;
	}

	public function play():AnimatedGif{
		if(playing) return this;
		playing=true;
		timer=new Timer(0,1);
		timer.addEventListener(flash.events.TimerEvent.TIMER, timerTick);
		timer.delay=nextFrame();
		timer.start();
		return this;
	}

	public function stop():AnimatedGif{
		if(!playing) return this;
		playing=false;
		timer.stop();
		timer.removeEventListener(flash.events.TimerEvent.TIMER, timerTick);
		timer=null;
		return this;
	}

	private function nextFrame():Int{
		if(pos>=0) bmaps[pos].visible=(frames[pos].disposalMethod==1);
		pos=(pos+1)%bmaps.length;
		if(pos==0) for(i in 1 ... bmaps.length) bmaps[i].visible=false;
		bmaps[pos].visible=true;
		return frames[pos].delayTime>10?frames[pos].delayTime*10:100;
	}

	private function timerTick(_){
		timer.stop();
		timer.delay=nextFrame();
		timer.start();
	}

}