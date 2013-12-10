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

package gif.bytes;

import haxe.io.Bytes;
import haxe.io.BytesInput;

enum Endian {
    BigEndian;
    LittleEndian;
}
 

class BytesInputWrapper extends BytesInput
{
    
    public function new( b : Bytes, ?endian : Endian, ?pos : Int, ?len : Int ) 
    {
        super( b, pos, len );
        
        if(endian != null) {
            switch(endian) {
                case BigEndian: bigEndian = true;
                case LittleEndian: bigEndian = false;
            }
        }
    }
    
    public function getAbailable() {
        #if flash9
            return b.bytesAvailable;
        #else
            return len;
        #end
    }
    
}
