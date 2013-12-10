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
        
        while(true) {
            var signature = bytesInput.readByte();            
            if (signature == 0x21) {
                var label = bytesInput.readByte();
                
                if (label == 0xF9) {
                    readGraphicControlExtension(bytesInput, gifFrameInfo);
                } else if (label == 0xFF) {
                    readApplicationExtension(bytesInput, gifFrameInfo);
                }
                else {
                    throw Error.UnsupportedFormat;
                }
            } else if (signature == 0x2C) {

                readImageDescriptor(bytesInput, gifFrameInfo);
                if (gifFrameInfo.localColorTableFlag) {
                    readLocalColorTable(bytesInput, gifFrameInfo);
                }

                readImageData(bytesInput, gifFrameInfo);
                
                gifInfo.frameList.push(gifFrameInfo);
                gifFrameInfo = new GifFrameInfo(gifInfo);
                
            } else if (signature == 0x3b) {
                break;
            } else {
                throw Error.InvalidFormat;
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
        
        gifFrameInfo.disposalMothod = (packedFields & 0x1C) >> 2; // 0b00011100
        gifFrameInfo.userInputFlag = (packedFields & 0x02) == 0x02; // 0b00000010
        gifFrameInfo.transparentColorFlag = (packedFields & 0x01) == 0x01; // 0b00000001
        
        gifFrameInfo.delayTime = input.readInt16();
        gifFrameInfo.transparentColorIndex = input.readByte();
        
        var terminator = input.readByte();
        if (terminator != 0) {
            throw Error.InvalidFormat;
        }
    }
    
    static function readApplicationExtension(input:Input, gifFrameInfo:GifFrameInfo)
    {
        var blockSize = input.readByte();
        if (blockSize != 0x0b) {
            throw Error.InvalidFormat;
        }
        
        // Application Identifier
        input.readInt32();
        input.readInt32();
        
        // Application Authentication Code
        input.readByte();
        input.readByte();
        input.readByte();
        
        var applicationBlockSize = input.readByte();
        if (applicationBlockSize == 3) {
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
    
    static function readImageData(input:Input, gifFrameInfo:GifFrameInfo) 
    {
        var lzwMinimumCodeSize = input.readByte();
        var size:Int=0;
        var joinOutput = new BytesOutput();
        while (true) {
            var blockSize = input.readByte();
            if (blockSize == 0) {
                break;
            }
            size+=blockSize;
            var bytes = input.read(blockSize);
            joinOutput.writeBytes(bytes, 0, bytes.length);
        }
        
        var joinBytes = joinOutput.getBytes();
        var bitReader = new BitReader(joinBytes);
        
        var codeLength = lzwMinimumCodeSize + 1;
        var clearCode = 1 << lzwMinimumCodeSize;
        var endCode = clearCode + 1;
        var registerNum = endCode + 1;
        
        var bitWriter = new BitWriter();
        var pixelNum = gifFrameInfo.imageWidth * gifFrameInfo.imageHeight;
        
        var dictionary = createInitialDictionary(lzwMinimumCodeSize);
        
        var firstCode = bitReader.readBits(codeLength);
        var prefix;
        
        if (firstCode.toInt() == clearCode) {
            prefix = bitReader.readBits(codeLength).subBits(0, lzwMinimumCodeSize);
        } else {
            prefix = firstCode.subBits(0, lzwMinimumCodeSize);
        }
        
        var suffix = prefix.copy();
        var readedPixel = 0;
        
        while (readedPixel < pixelNum) {
            var code;
            try{
                code = bitReader.readIntBits(codeLength);
            }catch(e:Dynamic){
                break;
            }
            if (code == clearCode) {
                dictionary = createInitialDictionary(lzwMinimumCodeSize);
                codeLength = lzwMinimumCodeSize + 1;
                registerNum = endCode + 1;
                
                bitWriter.writeBits(prefix);
                prefix = bitReader.readBits(codeLength).subBits(0, lzwMinimumCodeSize);
                
                continue;
            }
            
            if (!dictionary.exists(code)) {
                bitWriter.writeBits(prefix);
                
                suffix = prefix + prefix.subBits(0, lzwMinimumCodeSize);
                dictionary[registerNum] = suffix;
                registerNum++;
                
                if (registerNum >= (1 << codeLength) && codeLength <= 12) {
                    codeLength++;
                }
                
                prefix = suffix.copy();
                
            } else {
                bitWriter.writeBits(prefix);
                suffix = dictionary[code];
                
                dictionary[registerNum] = prefix + suffix.subBits(0, lzwMinimumCodeSize);
                registerNum++;
                
                if (registerNum >= (1 << codeLength) && codeLength <= 12) {
                    codeLength++;
                }
                
                prefix = suffix.copy();
            }
            
            readedPixel = Std.int(bitWriter.length / lzwMinimumCodeSize);
        }
        
        bitWriter.writeBits(prefix);
        
        var bytes = bitWriter.getBytes();
        var decodedBitReader = new BitReader(bytes);
        for(i in 0 ... readedPixel) {
            gifFrameInfo.imageData[i] = decodedBitReader.readIntBits(lzwMinimumCodeSize);
        }
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
