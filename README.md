# Spritesheet image splitter

> Command-line tool to split spritesheets into separate images.  
> Because some people need this sometimes.


### How to use

1. Download the [executable](/bin/spritesheet-splitter.exe)
2. Run `spritesheet-splitter.exe` with the following commands:

```
spritesheet-splitter.exe

[-input] <path>    : The path to the spritesheet
[-cols] <cols>     : Amount of columns the spritesheet
[-rows] <rows>     : Amount of rows the spritesheet

[--output] <name>  : The output path prefix of the files (optional)
[--zeros] <amount> : Amount of leading zeros (default=3)
[--start] <value>  : Start value of count (default=0)
```

##### Example

`spritesheet-splitter.exe -input "test.png" -cols 4 -rows 2`


> If you have Neko installed, you can also do `neko spritesheet-splitter.n` with the same arguments.

### Sources

The source code of this Haxe/Neko project depends on `nme` and `hxargs`. 
