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

abstract Bits(Array<Bool>)
{
    public var length (get, never): Int;
    
    inline function get_length()
    {
        return this.length;
    }
    
    public inline function new() 
    {
        this = [];
    }
    
    public inline function writeBit( bit :  Bool ) : Void
    {
        this.push(bit);
    }
    
    public function writeBits( bits : Bits ) : Void
    {
        for(i in 0 ... bits.length) {
            writeBit(bits[i]);
        }
    }
    
    public function writeIntBits( value : Int, bitLength : Int ) : Void
    {
        for (i in 0 ... bitLength) {
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
                if (this[i * 8 + bitPos]) {
                    value += 1 << bitPos;
                }
            }
            bytesOutput.writeByte(value);
        }
        
        var rest = length % 8;
        if (rest != 0) {
            var value : Int = 0;
            for (bitPos in 0 ... 8) {
                if (this[numBytes * 8 + bitPos]) {
                    value += 1 << bitPos;
                }
            }
            bytesOutput.writeByte(value);
        }
        
        return bytesOutput.getBytes();
    }
    
    public function copy() : Bits
    {
        var bits = new Bits();
        
        for(i in 0 ... length) {
            bits.writeBit(this[i]);
        }
        
        return bits;
    }
    
    public function subBits( position:Int, length:Int ) : Bits
    {
        var bits = new Bits();
        
        for(i in 0 ... length) {
            bits.writeBit(this[position + i]);
        }
        
        return bits;
    }
    

    @:arrayAccess public inline function arrayAccess( key:Int ) : Bool
    {
        return this[key];
    }
    
    @:to public function toString() : String
    {
        var str = "";
        for(i in 0 ... length) {
            str += this[length - i - 1] ? "1" : "0";
        }
        return str;
    }
    
    @:op(A + B) static public function add( a:Bits, b:Bits ) : Bits
    {
        var bits = a.copy();
        bits.writeBits(b);
        return bits;
    }
    
    public static function marge(a:Bits, b:Bits) : Bits
    {
        var bits = new Bits();
        
        for(i in 0 ... a.length) {
            bits.writeBit(a[i]);
        }
        
        for (i in 0 ... b.length) {
            bits.writeBit(b[i]);
        }
        
        return bits;
    }
    
    public static function fromIntBits( value : Int, bitLength : Int ) : Bits
    {
        var bits = new Bits();
        bits.writeIntBits(value, bitLength);
        return bits;
    }
    
    @:to public function toInt() : Int
    {
        var value = 0;
        for(i in 0 ... length) {
            if (this[i]) {
                value += 1 << i;
            }
        }
        return value;
    }
}