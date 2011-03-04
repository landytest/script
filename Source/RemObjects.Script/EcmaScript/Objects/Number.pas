﻿{

  Copyright (c) 2009-2010 RemObjects Software. See LICENSE.txt for more details.

}
namespace RemObjects.Script.EcmaScript;

interface


uses
  System.Collections.Generic,
  System.Text,
  RemObjects.Script.EcmaScript.Internal;


type
  GlobalObject = public partial class(EcmaScriptObject)
  public
    method CreateNumber: EcmaScriptObject;

    method NumberCall(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
    method NumberCtor(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
    method NumberToString(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
    method NumberValueOf(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
    method NumberLocaleString(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
    method NumberToFixed(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
    method NumberToExponential(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
    method NumberToPrecision(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
  end;
  EcmaScriptNumberObject = public class(EcmaScriptFunctionObject)
  public
    method Call(context: ExecutionContext; params args: array of Object): Object; override;
    method Construct(context: ExecutionContext; params args: array of Object): Object; override;
  end;

  
implementation


method GlobalObject.CreateNumber: EcmaScriptObject;
begin
  result := EcmaScriptObject(Get(nil, 'Number'));
  if result <> nil then exit;

  result := new EcmaScriptNumberObject(self, 'Number', @NumberCall, 1, &Class := 'Number');
  Values.Add('Number', PropertyValue.NotEnum(Result));
  Result.Values.Add('MAX_VALUE', PropertyValue.NotAllFlags(Double.MaxValue));
  Result.Values.Add('MIN_VALUE', PropertyValue.NotAllFlags(Double.MinValue));
  Result.Values.Add('NaN', PropertyValue.NotAllFlags(Double.NaN));
  Result.Values.Add('NEGATIVE_INFINITY', PropertyValue.NotAllFlags(Double.NegativeInfinity));
  Result.Values.Add('POSITIVE_INFINITY', PropertyValue.NotAllFlags(Double.PositiveInfinity));

  NumberPrototype := new EcmaScriptFunctionObject(self, 'Number', @NumberCtor, 1, &Class := 'Number');
  NumberPrototype.Prototype := ObjectPrototype;
  result.Values['prototype'] := PropertyValue.NotAllFlags(NumberPrototype);
  
  
  NumberPrototype.Values.Add('toString', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'toString', @NumberToString, 0)));
  
  NumberPrototype.Values.Add('toLocaleString', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'toLocaleString', @NumberLocaleString, 0)));
  NumberPrototype.Values.Add('toFixed', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'toFixed', @NumberToFixed, 1)));
  NumberPrototype.Values.Add('toExponential', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'toExponential', @NumberToExponential, 1)));
  NumberPrototype.Values.Add('toPrecision', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'toPrecision', @NumberToPrecision, 1)));

  NumberPrototype.Values.Add('valueOf', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'valueOf', @NumberValueOf, 0)));
end;

method GlobalObject.NumberCall(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  exit Utilities.GetArgAsDouble(args, 0);
end;

method GlobalObject.NumberCtor(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  var lVal := Utilities.GetArgAsDouble(args, 0);
  var lObj := new EcmaScriptObject(self, NumberPrototype, &Class := 'Number', Value := lVal);
  exit lObj;
end;


method GlobalObject.NumberToString(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  var lRadix := Utilities.GetArgAsInteger(args, 0);
  if (lRadix < 0) or (lRadix > 36) then lRadix := 10;
  exit Utilities.GetObjAsDouble(aSelf).ToString(System.Globalization.NumberFormatInfo.InvariantInfo);
end;

method GlobalObject.NumberValueOf(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  exit Utilities.GetObjAsDouble(aSelf);
end;

method GlobalObject.NumberLocaleString(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  exit Utilities.GetObjAsDouble(aSelf).ToString;
end;

method GlobalObject.NumberToFixed(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  var lFrac := Utilities.GetArgAsInteger(args, 0);
  var lValue := Utilities.GetObjAsDouble(aSelf);
  exit lValue.ToString('F'+lFrac.ToString);
end;

method GlobalObject.NumberToExponential(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  var lFrac := Utilities.GetArgAsInteger(args, 0);
  var lValue := Utilities.GetObjAsDouble(aSelf);
  exit lValue.ToString('E'+lFrac.ToString);
end;

method GlobalObject.NumberToPrecision(aCaller: ExecutionContext;aSelf: Object; params args: Array of Object): Object;
begin
  var lFrac := Utilities.GetArgAsInteger(args, 0);
  var lValue := Utilities.GetObjAsDouble(aSelf);
  exit lValue.ToString('N'+lFrac.ToString);
end;
method EcmaScriptNumberObject.Call(context: ExecutionContext; params args: array of Object): Object;
begin
  exit Root.NumberCall(context, self, args);
end;

method EcmaScriptNumberObject.Construct(context: ExecutionContext; params args: array of Object): Object;
begin
  exit Root.NumberCtor(context,self, args);
end;

end.