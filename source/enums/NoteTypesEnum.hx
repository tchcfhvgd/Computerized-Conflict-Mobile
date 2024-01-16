package enums;

#if (haxe >= "4.0.0") enum #else @:enum #end abstract NoteType(Null<Int>)
{
    var NONE = -1;
    var NORMAL_NOTE = 0;
    var HURT_NOTE = 1;
    var ALT_ANIM_NOTE = 2;
    var NO_ANIM_NOTE = 3;
    var GF_NOTE = 4;
    var GREEN_SING_NOTE = 5;
    var TSC_SING_NOTE = 6;
    var AV_NOTE = 7;
    var FIRE_NOTE = 8;
    var STOPWATCH_NOTE = 9;
    var TDL_NOTE = 10;
    var YT_NOTE = 11;
    var GH_NOTE = 12;

    public static inline function toString(item:NoteType)
    {
        return switch (item)
        {
            default: "add it in the toString shit";
        }
    }

    public static inline function toEnum(item:String)
    {
        return switch (item)
        {
            default: NONE;
            case "": NORMAL_NOTE;
            case "Hurt Note": HURT_NOTE;
            case "Alt Animation": ALT_ANIM_NOTE;
            case "No Animation": NO_ANIM_NOTE;
            case "GF Sing": GF_NOTE;
            case "Green Sing": GREEN_SING_NOTE;
            case "TSC Sing": TSC_SING_NOTE;
            case "AV": AV_NOTE;
            case "Fire Note": FIRE_NOTE;
            case "stopwatch": STOPWATCH_NOTE;
            case "Tdl note": TDL_NOTE;
            case "demonetization brah": YT_NOTE;
            case "Guitar Hero": GH_NOTE;
        }
    }
}