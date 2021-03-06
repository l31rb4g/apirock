package apirock.types;

import haxe.ds.StringMap;

abstract StringKeeper(String) from String {

    static private var KEEPER_MAP:StringMap<String> = new StringMap<String>();

    public function new(value:String) this = value;

    @:to
    inline public function toString():String return StringKeeper.parse(this);

    inline public function getStringUnparsed():String return this;

    @:op(A + B)
    public function addStringKeepers(value:StringKeeper):StringKeeper {
        return getStringUnparsed() + value.getStringUnparsed();
    }
    
    static public function parse(value:String):String {
        var map:StringMap<String> = KEEPER_MAP;
        var result = value;

        for (key in map.keys()) result = result.split('#${key}').join(map.get(key));

        return result;
    }

    static public function addData(key:String, value:String):Void {
        if (StringTools.startsWith('#', key)) key = key.substr(1);
        KEEPER_MAP.set(key, value);
    }

    static public function getData(key:String):String {
        if (StringTools.startsWith('#', key)) key = key.substr(1);
        return KEEPER_MAP.exists(key) ? KEEPER_MAP.get(key) : "";
    }
    
    static public function clear():Void KEEPER_MAP = new StringMap<String>();
}
