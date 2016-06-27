package;

import hxargs.Args;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Loader;
import nme.events.Event;
import nme.filesystem.File;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.net.URLRequest;
import nme.utils.ByteArray;
import sys.FileSystem;
import sys.io.FileOutput;

/**
 * @author Mark Knol
 */
class Main {
  static function main() {
    var EMPTY = "";
    var EXTENSION = "png";
    
    var config = {
      input: EMPTY,
      output: EMPTY,
      rows: 1,
      cols: 1,
      start: 0,
      zeros: 2,
    }
    
    var argsHandler = Args.generate([
        @doc("The path to the spritesheet")
        ["-input"] => function(path:String) config.input = path,
        
        @doc("Amount of rows the spritesheet")
        ["-rows"] => function(rows:Int) config.rows = rows,
        
        @doc("Amount of columns the spritesheet")
        ["-cols"] => function(cols:Int) config.cols = cols,
        
        @doc("The output path prefix of the files (optional)")
        ["--output"] => function(name:String = "") config.output = name,
        
        @doc("Amount of leading zeros (default=3)")
        ["--zeros"] => function(amount:Int = 3) config.zeros = amount,

        @doc("Start value of count (default=0)")
        ["--start"] => function(value:Int = 0) config.start = value,

        _ => function(arg:String) throw "Invalid command: " + arg
    ]);
    
    
    var args = Sys.args();
    if (args.length == 0) {
      Sys.println(argsHandler.getDoc());
      return;
    } else {
      argsHandler.parse(args);
    }
    
    if (config.input == EMPTY) {
      Sys.println("Input is required.\n");
      Sys.println(argsHandler.getDoc());
      return;
    }
    if (config.rows < 1 || config.cols < 1) {
      Sys.println("Invalid rows/cols ");
      Sys.println(argsHandler.getDoc());
      return;
    }
    
    if (config.output == EMPTY) {
      // if output isnt set, use input name without extension
      config.output = removeExtension(config.input);
    }
    
    var loader = new Loader();
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event) {
        Sys.println("Loaded: " + config.input);
        
        var bmp:Bitmap  = cast loader.content;
        var image = bmp.bitmapData;
        
        var tileWidth = Std.int(bmp.width / config.cols);
        var tileHeight = Std.int(bmp.height / config.rows);
        var tile = new BitmapData(tileWidth, tileHeight, true, BitmapData.TRANSPARENT);
        
        if (config.output.indexOf("/") > -1) {
          var directory = getDirectory(config.output);
          if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);
        }
        
        for (grid in new GridIterator(config.cols, config.rows)) {
          var fileName = config.output + "_" + StringTools.lpad(Std.string(grid.index + config.start) , "0", config.zeros) + "." + EXTENSION;
          Sys.println("Created: " + fileName);
          
          tile.clear(BitmapData.TRANSPARENT);
          tile.copyPixels(image, new Rectangle(grid.x * tileWidth, grid.y * tileHeight, tileWidth, tileHeight), new Point(0, 0));
          
          var b:ByteArray = tile.encode(EXTENSION, 1);
          var fo:FileOutput = sys.io.File.write(fileName, true);
          fo.writeString(b.toString());
          fo.close();
        }
        
          Sys.println("Done! Enjoy your day!\n");
    });
    loader.load(new URLRequest(config.input));
  }
  
  static inline function removeExtension(v:String) return getWithoutLast(v, ".");
  static inline function getDirectory(v:String) return getWithoutLast(v, "/") + "/";
  static inline function getWithoutLast(v:String, delimiter:String) {
    var list = v.split(delimiter);
    list.pop();
    return list.join(delimiter);
  }
}

class GridIterator {
  var gridWidth:Int = 0;
  var gridHeight:Int = 0;
  var i:Int = 0;

  public inline function new(gridWidth:Int, gridHeight:Int) {
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
  }

  public inline function hasNext() {
    return i < gridWidth * gridHeight;
  }

  public inline function next() {
    return new GridIteratorObject(i++, gridWidth);
  }
}

class GridIteratorObject {
  public var index(default, null):Int;
  public var x(default, null):Int;
  public var y(default, null):Int;

  public inline function new(index:Int, gridWidth:Int) {
    this.index = index;
    this.x = index % gridWidth;
    this.y = Std.int(index / gridWidth);
  }
}