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

import gif.color.Rgb;
import gif.color.Rgba;

class GifFrameInfo
{
    public var parent: GifInfo;
    
    /* Graphic Control Extension */
    public var disposalMothod: Int;
    public var userInputFlag: Bool;
    public var transparentColorFlag: Bool;
    public var delayTime: Int;
    public var transparentColorIndex: Int;
    
    /* Image Descriptor */
    public var imageLeftPosition: Int;
    public var imageTopPosition: Int;
    public var imageWidth: Int;
    public var imageHeight: Int;
    public var localColorTableFlag: Bool;
    public var interlaceFlag: Bool;
    public var sortFlag: Bool;
    public var sizeOfLocalColorTable: Int;
    
    /* Local Color Table */
    public var localColorTable: Array<Rgb>;
    
    /* Image Data */
    public var imageData: Array<Int>;
    
    public function new(parent : GifInfo) 
    {
        this.parent = parent;
        
        localColorTable = [];
        imageData = [];
    }

    public function clearBinaryData(){
        this.imageData=null;
        this.localColorTable=null;
    }
    
    public function getGlobalRbgaPalette() : Array<Rgba>
    {
        var rgbaPalette = new Array<Rgba>();
        
        for (i in 0 ... parent.globalColorTable.length) {
            rgbaPalette[i] = parent.globalColorTable[i];
            
            if (transparentColorFlag && i == transparentColorIndex) {
                rgbaPalette[i].alpha = 0;
            }
        }
        
        return rgbaPalette;
    }
    
    public function getLocalRbgaPalette() : Array<Rgba>
    {
        var rgbaPalette = new Array<Rgba>();
        
        for (i in 0 ... localColorTable.length) {
            rgbaPalette[i] = localColorTable[i];
            
            if (transparentColorFlag && i == transparentColorIndex) {
                rgbaPalette[i].alpha = 0;
            }
        }
        
        return rgbaPalette;
    }
    
    public function getRgbaImageData() : Array<Rgba>
    {
        var rgbaPalette = localColorTableFlag ? getLocalRbgaPalette() : getGlobalRbgaPalette();
        var rgbaImageData = new Array<Rgba>();
        for (i in 0 ... imageData.length) rgbaImageData[i] = rgbaPalette[imageData[i]];
        return rgbaImageData;
    }
}
