/*
 * Copyright (c) 2013 Heriet [http://heriet.info/].
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package gif.images;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Input;
import gif.bytes.BitReader;
import gif.bytes.Bits;
import gif.bytes.BitWriter;
import gif.bytes.BytesInputWrapper;
import gif.color.Rgb;

enum Error {
    InvalidFormat;
    UnsupportedFormat;
}

class GifDecoder
{
    public static function decode(bytes:Bytes): GifInfo
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.LittleEndian);
        var gifInfo = new GifInfo();
        
        readHeader(bytesInput, gifInfo);
        
        if(gifInfo.globalColorTableFlag) {
            readGlobalColorTable(bytesInput, gifInfo);
        }
        
        var gifFrameInfo = new GifFrameInfo(gifInfo);
        
        while (true) {
            var signature = bytesInput.readByte();
			
			switch (signature) {
				case 0x21: {					
					var label = bytesInput.readByte();
					switch (label) {
						case 0xf9:	readGraphicControlExtension(bytesInput, gifFrameInfo);
						case 0xFF:	readApplicationExtension(bytesInput, gifFrameInfo);
						case 0xfE:	readComment(bytesInput, gifFrameInfo);
					}
				}
				case 0x2C: {
					readImageDescriptor(bytesInput, gifFrameInfo);
					if (gifFrameInfo.localColorTableFlag) {
						readLocalColorTable(bytesInput, gifFrameInfo);
					}
					readImageData(bytesInput, gifFrameInfo);
					gifInfo.frameList.push(gifFrameInfo);
					gifFrameInfo = new GifFrameInfo(gifInfo);
				}
				case 0x3b: {					
					break;
				}
				default: {
					throw Error.InvalidFormat;
				}
			}
        }
        
        return gifInfo;
    }
    
    static function readHeader(input:Input, gifInfo:GifInfo)
    {
        validateSignature(input.read(3));
        readVersion(input.read(3), gifInfo);
        
        gifInfo.logicalScreenWidth = input.readInt16();
        gifInfo.logicalScreenHeight = input.readInt16();
        
        var packedFields = input.readByte();
        gifInfo.globalColorTableFlag = (packedFields & 0x80) == 0x80; // 0b10000000
        gifInfo.colorResolution = (packedFields & 0x70) >> 4; // 0b01110000
        gifInfo.sortFlag = (packedFields & 0x08) == 0x08; // 0b00001000
        gifInfo.sizeOfGlobalTable = (packedFields & 0x07); // 0b00000111
        
        gifInfo.backgroundColorIndex = input.readByte();
        gifInfo.pixelAspectRaito = input.readByte();
        
    }
    
    static function validateSignature(bytes:Bytes)
    {
        if (bytes.toString() != "GIF") {
            throw Error.InvalidFormat;
        }
    }
    
    static function readVersion(bytes:Bytes, gifInfo:GifInfo)
    {
        switch(bytes.toString()) {
            case "87a":
                gifInfo.version = Gif87a;
                throw Error.UnsupportedFormat;
            case "89a":
                gifInfo.version = Gif89a;
            default:
                throw Error.InvalidFormat;
        }
    }
    
    static function readGlobalColorTable(input:Input, gifInfo:GifInfo)
    {
        var tableLength = 1 << (gifInfo.sizeOfGlobalTable + 1);
        
        for (i in 0 ... tableLength) {
            gifInfo.globalColorTable.push(readRgb(input));
        }
    }
    
    static function readGraphicControlExtension(input:Input, gifFrameInfo:GifFrameInfo)
    {
        var blockSize = input.readByte();
        if (blockSize != 0x04) {
            throw Error.InvalidFormat;
        }
        var packedFields = input.readByte();
        
        gifFrameInfo.disposalMethod = (packedFields & 0x1C) >> 2; // 0b00011100
        gifFrameInfo.userInputFlag = (packedFields & 0x02) == 0x02; // 0b00000010
        gifFrameInfo.transparentColorFlag = (packedFields & 0x01) == 0x01; // 0b00000001
        
        gifFrameInfo.delayTime = input.readInt16();
        gifFrameInfo.transparentColorIndex = input.readByte();
        
        var terminator = input.readByte();
        if (terminator != 0) {
            throw Error.InvalidFormat;
        }
    }
    
    static function readComment(input:Input, gifFrameInfo:GifFrameInfo)
    {
    	//chomp the comment
    	var b;
    	do {
			b=input.readByte()&0xFF;
			if (b>0) input.read(b);
		} while(b>0);
    }
    
    static function readApplicationExtension(input:Input, gifFrameInfo:GifFrameInfo)
    {
        var blockSize = input.readByte();
        if (blockSize != 0x0b) {
            throw Error.InvalidFormat;
        }
        
        // Application Identifier
        var id1 = input.readInt32();
        var id2 = input.readInt32();
        
        // Application Authentication Code
        var auth1 = input.readByte();
        var auth2 = input.readByte();
        var auth3 = input.readByte();
        
        if (id1==1346454355 && id2==808333893 && //NETSCAPE
        	auth1 == 0x32 && auth2 == 0x2e && auth3 == 0x30) //2.0
        {
        	var applicationBlockSize = input.readByte();
	        if (applicationBlockSize == 0x03) {
	            input.readByte();
	            
	            gifFrameInfo.parent.animationLoopCount = input.readInt16();
	            
	        } else {
	        	throw UnsupportedFormat;
	        }
	        
	        var terminator = input.readByte();
	        if (terminator != 0) {
	            throw Error.InvalidFormat;
	        }
        }
        else //unknown application extension
        {
        	//chomp the unknown extension and try to continue
        	var b;
	    	do{
				b=input.readByte()&0xFF;
				if (b>0) input.read(b);
			}
			while(b>0);
        }
    }
    
    static function readImageDescriptor(input:Input, gifFrameInfo:GifFrameInfo) 
    {
        gifFrameInfo.imageLeftPosition = input.readInt16();
        gifFrameInfo.imageTopPosition = input.readInt16();
        gifFrameInfo.imageWidth = input.readInt16();
        gifFrameInfo.imageHeight = input.readInt16();
        
        var packedFields = input.readByte();
        
        gifFrameInfo.localColorTableFlag = (packedFields & 0x80) == 0x80; // 0b10000000
        gifFrameInfo.interlaceFlag = (packedFields & 0x40) == 0x40; // 0b01000000
        gifFrameInfo.sortFlag = (packedFields & 0x20) == 0x20; // 0b00100000
        gifFrameInfo.sizeOfLocalColorTable = (packedFields & 0x07); // 0b00000111
        
    }
    
    static function readLocalColorTable(input:Input, gifFrameInfo:GifFrameInfo) 
    {
        var tableLength = 1 << (gifFrameInfo.sizeOfLocalColorTable + 1);
        
        for (i in 0 ... tableLength) {
            gifFrameInfo.localColorTable.push(readRgb(input));
        }
    }
	
	/**
	 * Reads next variable length block from input.
	 */
	static function readBlock(input : Input) : { block : Bytes, bytesWritten : Int }
	{
		var blockSize = input.readByte();
		var block = Bytes.alloc(blockSize);
		var n = 0;
		if (blockSize > 0) 
		{
			try 
			{
				var count = 0;
				while (n < blockSize) 
				{
					input.readBytes(block, n, blockSize - n);
					if ( (blockSize - n) == -1) break;
					n += (blockSize - n);
				}
			} 
			catch (e:Error) 
			{
				trace('Error: $e');
			}
			/*
			if (n < blockSize) 
			{
				status = STATUS_FORMAT_ERROR;
			}
			*/
		}
		return { block : block, bytesWritten : n };
	}

	static function readImageData(input : Input, gifFrameInfo : GifFrameInfo)
	{
		
		var NullCode = -1;
		var MaxStackSize = 4096;
		
		var npix:Int = gifFrameInfo.imageWidth * gifFrameInfo.imageHeight;
		var available:Int;
		var clear:Int;
		var code_mask:Int;
		var code_size:Int;
		var end_of_information:Int;
		var in_code:Int;
		var old_code:Int;
		var bits:Int;
		var code:Int;
		var count:Int;
		var i:Int;
		var datum:Int;
		var data_size:Int;
		var first:Int;
		var top:Int;
		var bi:Int;
		var pi:Int;
		var block : Bytes = null;
		
		var prefix = new Vector<Int>(MaxStackSize);
		var suffix = new Vector<Int>(MaxStackSize);
		var pixelStack = new Vector<Int>(MaxStackSize+1);
		
		//  Initialize GIF data stream decoder.
		data_size = input.readByte();
		clear = 1 << data_size;
		end_of_information = clear + 1;
		available = clear + 2;
		old_code = NullCode;
		code_size = data_size + 1;
		code_mask = (1 << code_size) - 1;
		for (code in 0...clear)
		{
			prefix[code] = 0;
			suffix[code] = code;
		}
		
		//  Decode GIF pixel stream.
		datum = bits = count = first = top = pi = bi = 0;
		
		i = 0;
		while (i < npix)
		{
			if (top == 0)
			{
				if (bits < code_size)
				{
					//  Load bytes until there are enough bits for a code.
					if (count == 0) 
					{
						// Read a new data block.
						var readResult = readBlock(input);
						count = readResult.bytesWritten;
						block = readResult.block;
						if (count <= 0)	break;
						bi = 0;
					}
					datum += (block.get(bi) & 0xff) << bits;
					bits += 8;
					bi++;
					count--;
					continue;
				}
				
				//  Get the next code.
				code = datum & code_mask;
				datum >>= code_size;
				bits -= code_size;
				//  Interpret the code
				if ((code > available) || (code == end_of_information))	break;
				
				if (code == clear) 
				{
					//  Reset decoder.
					code_size = data_size + 1;
					code_mask = (1 << code_size) - 1;
					available = clear + 2;
					old_code = NullCode;
					continue;
				}
				if (old_code == NullCode) 
				{
					pixelStack[top++] = suffix[code];
					old_code = code;
					first = code;
					continue;
				}
				in_code = code;
				if (code == available) 
				{
					pixelStack[top++] = first;
					code = old_code;
				}
				while (code > clear) 
				{
					pixelStack[top++] = suffix[code];
					code = prefix[code];
				}
				first = (suffix[code]) & 0xff;
				
				//  Add a new string to the string table,
				
				if (available >= MaxStackSize) break;
				pixelStack[top++] = first;
				prefix[available] = old_code;
				suffix[available] = first;
				available++;
				if (((available & code_mask) == 0) && (available < MaxStackSize)) 
				{
					code_size++;
					code_mask += available;
				}
				old_code = in_code;
				
			}
			
			// Pop a pixel off the pixel stack.
			top--;
			gifFrameInfo.imageData[pi++] = pixelStack[top];
			i++;
			
		}
		
		for (i in pi...npix)
		{
			gifFrameInfo.imageData[i] = 0;	// clear missing pixels
		}
		
		input.readByte();
		
	}
	
    static function createInitialDictionary(lzwMinimumCodeSize : Int) : Map<Int, Bits>
    {
        var dictionary = new Map<Int, Bits>();
        var len = 1 << lzwMinimumCodeSize;
        for (i in 0 ... len) {
            dictionary[i] = Bits.fromIntBits(i, lzwMinimumCodeSize);
        }
        
        return dictionary;
    }
    
    static function readRgb(input: Input) : Rgb
    {
        var red = input.readByte();
        var green = input.readByte();
        var blue = input.readByte();
        
        return Rgb.fromComponents(red, green, blue);
    }
}
