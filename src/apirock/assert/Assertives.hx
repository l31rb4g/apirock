package apirock.assert;

import datetime.DateTime;
import apirock.activity.Activity;

import anonstruct.AnonStruct;

@:access(anonstruct.AnonStruct)
@:access(anonstruct.AnonProp)
@:access(anonstruct.AnonPropDate)
@:access(anonstruct.AnonPropArray)
@:access(anonstruct.AnonPropObject)
@:access(anonstruct.AnonPropString)
@:access(anonstruct.AnonPropInt)
@:access(anonstruct.AnonPropFloat)
@:access(anonstruct.AnonPropBool)
class Assertives {

    private var assertive:Dynamic;
    private var errors:Array<String> = [];
    private var map:Array<String> = [];

    public function new(?activity:Activity) {
        if (activity != null) activity.assertive = this;
    }

    inline private function isString(value:Dynamic):Bool return new AnonStruct().valueString().validate_isString(value);
    inline private function isInt(value:Dynamic):Bool return new AnonStruct().valueInt().validate_isInt(value);
    inline private function isDate(value:Dynamic):Bool return new AnonStruct().valueDate().validate_isDateTime(value);
    inline private function isFloat(value:Dynamic):Bool return new AnonStruct().valueFloat().validate_isFloat(value);
    inline private function isBool(value:Dynamic):Bool return new AnonStruct().valueBool().validate_isBool(value);
    inline private function isArray(value:Dynamic):Bool return new AnonStruct().valueArray().validate_isArray(value);
    inline private function isObject(value:Dynamic):Bool return new AnonStruct().valueObject().validate_isObject(value);

    public function getErrors():Array<String> return this.errors.copy();

    public function setAssertive(value:Dynamic) this.assertive = value;

    public function compare(data:Dynamic):Bool {
        this.errors = [];
        this.map = [];
        return this.compareValues(this.assertive, data);
    }

    private function compareTypes(a:Dynamic, b:Dynamic):Bool {
        if (a == null && b == null) return true;
        else if (this.isString(a) && this.isString(b)) return true;
        else if (this.isInt(a) && this.isInt(b)) return true;
        else if (this.isFloat(a) && this.isFloat(b)) return true;
        else if (this.isBool(a) && this.isBool(b)) return true;
        else if (this.isDate(a) && this.isDate(b)) return true;
        else if (this.isArray(a) && this.isArray(b)) return true;
        else if (this.isObject(a) && this.isObject(b)) return true;
        else {

            if (a == null || b == null) {
                this.addErrorValue(a, b);
                return false;

            } else {

                if (this.map.length > 0) this.errors.push("Wrong type for " + this.map.join("."));
                else this.errors.push("Values are not same type");

                return false;
            }
        }
    }

    private function compareValues(a:Dynamic, b:Dynamic):Bool {

        if (this.compareTypes(a, b)) {
            
            if (a == null) return a == b;
            else if (this.isString(a)) return this.compareStrings(a, b);
            else if (this.isInt(a)) return this.compareFloats(a, b);
            else if (this.isFloat(a)) return this.compareInts(a, b);
            else if (this.isBool(a)) return this.compareBools(a, b);
            else if (this.isArray(a)) return this.compareArrays(a, b);
            else if (this.isDate(a)) return this.compareDates(a, b);
            else if (this.isObject(a)) return this.compareObjects(a, b);
            else {

                this.errors.push("Unable to identify types");

                return false;
            }

        } else return false;
    }

    private function addErrorValue(expected:Dynamic, gets:Dynamic):Void {
        var error:String = "";
        error += "Wrong value";

        if (this.map.length > 0) error += " for " + this.map.join(".");

        error += ": Expects '" + Std.string(expected) + "' and Gets '" + Std.string(gets) + "'";

        this.errors.push(error);
    }

    private function compareDates(a:Dynamic, b:Dynamic):Bool {
        var aString:String = '';
        var bString:String = '';

        if (Std.is(a, Date)) {
            var aDate:DateTime = DateTime.fromDate(a);
            aString = aDate.toString();
        } else if (Std.is(a, String)) {
            var aDate:DateTime = DateTime.fromString(a);
            aString = aDate.toString();
        } else if (Std.is(a, Float)) {
            var aDate:DateTime = DateTime.fromTime(a);
            aString = aDate.toString();
        }

        if (Std.is(b, Date)) {
            var bDate:DateTime = DateTime.fromDate(b);
            bString = bDate.toString();
        } else if (Std.is(b, String)) {
            var bDate:DateTime = DateTime.fromString(b);
            bString = bDate.toString();
        } else if (Std.is(b, Float)) {
            var bDate:DateTime = DateTime.fromTime(b);
            bString = bDate.toString();
        }

        if (aString == '' || bString == '') return false;
        else return aString == bString;
    }

    private function compareStrings(a:String, b:String):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }
    private function compareInts(a:Int, b:Int):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }
    private function compareBools(a:Bool, b:Bool):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }
    private function compareFloats(a:Float, b:Float):Bool {
        if (Math.abs(a - b) < 0.0001) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }

    private function compareArrays(a:Array<Dynamic>, b:Array<Dynamic>):Bool {
        if (a.length == b.length) {

            for (i in 0 ... a.length) {
                this.map.push("[" + i + "]");
                if (!this.compareValues(a[i], b[i])) return false;
                this.map.pop();
            }

            return true;
        } else {
            this.errors.push("Arrays have wrong length at " + this.map.join("."));
            return false;
        }
    }

    private function compareObjects(a:Dynamic, b:Dynamic):Bool {
        var fieldsA:Array<String> = Reflect.fields(a);
        var fieldsB:Array<String> = Reflect.fields(b);

        var hasErrors:Bool = false;

        for (field in fieldsA) {
            this.map.push(field);

            if (fieldsB.indexOf(field) == -1) {
                this.errors.push("Field " + this.map.join(".") + " not found");
                hasErrors = true;
            } else {

                var aValue:Dynamic = Reflect.field(a, field);
                var bValue:Dynamic = Reflect.field(b, field);

                if (!this.compareValues(aValue, bValue)) {
                    hasErrors = true;
                }

            }

            this.map.pop();
        }

        return !hasErrors;
    }
}