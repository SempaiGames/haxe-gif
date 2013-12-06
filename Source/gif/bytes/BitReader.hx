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
package hxpixel.bytes;

import haxe.io.Bytes;
import haxe.io.BytesData;

class BitReader
{
    var bytesData : BytesData;
    var position : Int;
    var length : Int;
    
    public function new( bytes : Bytes ) 
    {
        this.bytesData = bytes.getData();
        this.length = bytes.length * 8;
        this.position = 0;
    }
    
    public function bitsAvailable() : Int
    {
        return length - position;
    }
    
    public function readBit() : Bool
    {
        if (position + 1 > length) {
            throw "OutOfRange";
        }
        
        var bytePositon = Std.int(position / 8);
        var byte = Bytes.fastGet(bytesData, bytePositon);
        var offset = position % 8;
        
        position++;
        
        return (byte & (1 << offset)) != 0;
    }
    
    public function readBits( numBits : Int ) : Bits
    {
        var bits = new Bits();
        for (i in 0 ... numBits) {
            bits.writeBit(readBit());
        }
        
        return bits;
    }
    
    public function readIntBits( numBits : Int ) : Int
    {
        if (position + numBits > length) {
            throw "OutOfRange";
        }
        
        var value = 0;
        var readed = 0;
        while (readed < numBits) {
            var bytePositon = Std.int(position / 8);
            var byte = Bytes.fastGet(bytesData, bytePositon);
            var offset = position % 8;
            var rest = 8 - offset;
            rest = readed + rest < numBits ? rest : numBits - readed;
            value += ((byte & generateMask(offset, rest)) >> offset) << readed;
            position += rest;
            readed += rest;
        }
        
        return value;
    }
    
    function generateMask( offset:Int, length:Int ) : Int
    {
        return (0xFF >> (8-length)) << offset;
    }
}