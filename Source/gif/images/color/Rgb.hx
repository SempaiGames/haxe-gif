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

package hxpixel.images.color;

abstract Rgb(Rgba)
{
    inline function new(a:Rgba)
    {
        this = a & 0xFFFFFF;
    }
    
    public var red(get, set) : Int;
    public var green(get, set) : Int;
    public var blue(get, set) : Int;
    
    inline function get_red() : Int
    {
        return this.red;
    }
    
	inline function set_red( red : Int ) : Int
    {
        return (this.red = red);
	}
    
    inline function get_green() : Int
    {
        return this.green;
    }
    
	inline function set_green( green : Int ) : Int
    {
        return (this.green = green);
	}
    
    inline function get_blue() : Int
    {
        return this.blue;
    }
    
	inline function set_blue( blue : Int ) : Int
    {
        return (this.blue = blue);
	}
    
    public static function fromComponents( red : Int, green : Int, blue : Int ) : Rgb
    {
        return new Rgb(   limitateComponent(red) << 16
                        | limitateComponent(green) << 8
                        | limitateComponent(blue)
                        );
    }
    
    @:op(A + B) static public function add( lhs:Rgb, rhs:Rgb ) : Rgb
    {
        var red:Int = lhs.red + rhs.red;
        var green:Int = lhs.green + rhs.green;
        var blue:Int = lhs.blue  + rhs.blue;
        
        return fromComponents(red, green, blue);
    }
    
    @:op(A - B) static public function sub( lhs:Rgb, rhs:Rgb ) : Rgb
    {
        var red:Int = lhs.red - rhs.red;
        var green:Int = lhs.green - rhs.green;
        var blue:Int = lhs.blue  - rhs.blue;
        
        return fromComponents(red, green, blue);
    }
    
    @:from static public inline function fromRgba( rgba : Rgba )
    {
        return new Rgb(rgba);
    }
    
    @:to public inline function toRgba() : Rgba
    {
        this.alpha = 0xFF;
        return this;
    }
    
    @:to public inline function toInt() : Int
    {
        return this & 0xFFFFFF;
    }
    
    @:to public inline function toString() : String
    {
        return StringTools.hex(this & 0xFFFFFF);
    }
    
    static function limitateComponent( value : Int ) : Int
    {
        return switch(value) {
            case a if (a > 255):
                255;
            case a if (a < 0):
                0;
            default:
                value;
        }
    }
}
