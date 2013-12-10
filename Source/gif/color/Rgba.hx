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

package gif.color;

abstract Rgba(Int) from Int to Int
{
    inline function new(a:Int)
    {
        this = a;
    }
    
    public var alpha(get, set) : Int;
    public var red(get, set) : Int;
    public var green(get, set) : Int;
    public var blue(get, set) : Int;

    
	inline function get_alpha() : Int
    {
        return (this >> 24) & 0xFF;
	}

	inline function set_alpha( alpha : Int ) : Int
    {
        return this = ((alpha & 0xFF) << 24) | (this & 0xFFFFFF);
	}
    
    inline function get_red():Int
    {
        return (this >> 16) & 0xFF;
    }
    
	inline function set_red( red : Int ) : Int
    {
        return this = ((red & 0xFF) << 16) | (this & 0xFF00FFFF);
	}
    
    inline function get_green():Int
    {
        return (this >> 8) & 0xFF;
    }
    
	inline function set_green( green : Int ) : Int
    {
        return this = ((green & 0xFF) << 8) | (this & 0xFFFF00FF);
	}
    
    inline function get_blue():Int
    {
        return this & 0xFF;
    }
    
	inline function set_blue( blue : Int ) : Int
    {
        return this = (blue & 0xFF) | (this & 0xFFFFFF00);
	}
    
    public static function fromComponents( red : Int, green : Int, blue : Int, ?alpha : Int = 0xFF) : Rgba
    {
        return new Rgba(  limitateComponent(alpha) << 24
                        | limitateComponent(red)   << 16
                        | limitateComponent(green) << 8
                        | limitateComponent(blue)
                        );
    }
    
    @:op(A + B) static public function add(lhs:Rgba, rhs:Rgba):Rgba
    {
        var alpha:Int = lhs.alpha + rhs.alpha;
        var red:Int = lhs.red + rhs.red;
        var green:Int = lhs.green + rhs.green;
        var blue:Int = lhs.blue  + rhs.blue;
        
        return fromComponents(red, green, blue, alpha);
    }
    
    @:op(A - B) static public function sub(lhs:Rgba, rhs:Rgba):Rgba
    {
        var alpha:Int = lhs.alpha - rhs.alpha;
        var red:Int = lhs.red - rhs.red;
        var green:Int = lhs.green - rhs.green;
        var blue:Int = lhs.blue  - rhs.blue;
        
        return fromComponents(red, green, blue, alpha);
    }
    
    @:to public inline function toString() : String
    {
        return StringTools.hex(this);
    }
    
    static function limitateComponent(value:Int) : Int
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
