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
import haxe.io.BytesOutput;

class BitWriter
{
    var bitArray : Array<Bool>;
    public var length (get, never): Int;
    
    function get_length() : Int
    {
        return bitArray.length;
    }
    
    public function new() 
    {
        bitArray = [];
    }
    
    public function writeBit( bit :  Bool) : Void
    {
        bitArray.push(bit);
    }
    
    public function writeBits( bits : Bits ) : Void
    {
        for (i in 0 ... bits.length) {
            writeBit(bits[i]);
        }
    }
    
    public function writeIntBits( value : Int, numBits : Int ) : Void
    {
        for (i in 0 ... numBits) {
            writeBit(((value >> i) & 1) == 1);
        }
    }
    
    public function getBytes() : Bytes
    {
        var bytesOutput = new BytesOutput();
        
        var numBytes:Int = Std.int(length / 8);
        for (i in 0 ... numBytes) {
            var value : Int = 0;
            for (bitPos in 0 ... 8) {
                if (bitArray[i * 8 + bitPos]) {
                    value += 1 << bitPos;
                }
            }
            bytesOutput.writeByte(value);
        }
        
        var rest = length % 8;
        if (rest != 0) {
            var value : Int = 0;
            for (bitPos in 0 ... 8) {
                if (bitArray[numBytes * 8 + bitPos]) {
                    value += 1 << bitPos;
                }
            }
            bytesOutput.writeByte(value);
        }
        
        return bytesOutput.getBytes();
    }
}