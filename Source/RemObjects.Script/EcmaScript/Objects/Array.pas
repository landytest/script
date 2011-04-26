﻿{

  Copyright (c) 2009-2010 RemObjects Software. See LICENSE.txt for more details.

}
namespace RemObjects.Script.EcmaScript;

interface


uses
  System.Collections.Generic,
  System.Text,
  Microsoft,
  RemObjects.Script,
  RemObjects.Script.EcmaScript.Internal;


type
  GlobalObject = public partial class(EcmaScriptObject)
  public
    method CreateArray: EcmaScriptObject;

    property DefaultCompareInstance: EcmaScriptFunctionObject;
  
    method Sort<T>(aList: T; aStart, aEnd: Integer; aSwap: Action<T, Integer, Integer>; aCompare: Func<T, Integer, Integer, Integer>): Boolean;
    method ArrayIsArray(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayCtor(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayToString(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayToLocaleString(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayConcat(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayJoin(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayPop(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayPush(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayReverse(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayShift(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArraySlice(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArraySort(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArraySplice(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayUnshift(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayIndexOf(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayEvery(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayLastIndexOf(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArraySome(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayMap(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayForeach(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayFilter(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayReduce(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
    method ArrayReduceRight(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;

    method DefaultCompare(aCaller: ExecutionContext; aSelf: Object; params Args: Array of Object): Object;
  private
    method Swap(EC: ExecutionContext; aSelf: EcmaScriptObject; L: Int32; R: Int32);
  end;
  RemObjects.Script.EcmaScript.EcmaScriptArrayObject = public class(EcmaScriptObject)
  private
    method get_Length: Cardinal;
  public
    constructor(aRoot: GlobalObject; aLength: Object);
    constructor(aCapacity: Integer; aRoot: GlobalObject);

    class var &Constructor: System.Reflection.ConstructorInfo := typeof(EcmaScriptArrayObject).GetConstructor([typeof(Integer), typeof(GlobalObject)]); readonly; 
    class var Method_AddValue: System.Reflection.MethodInfo := typeof(EcmaScriptArrayObject).GetMethod('AddValue', [typeof(Object)]); readonly;
    method AddValues(aItems: Array of Object): EcmaScriptArrayObject;
    method AddValue(aItem: Object);

    property Length: Cardinal read get_Length;

    method DefineOwnProperty(aName: String; aValue: PropertyValue; aThrow: Boolean): Boolean; override;
    
    class method TryGetArrayIndex(s: string; out val: Cardinal): Boolean;
  end;

  EcmaScriptArrayObjectObject = class(EcmaScriptFunctionObject)
  private
  public
    constructor (aOwner: GlobalObject);

    method Construct(context: ExecutionContext; params args: array of Object): Object; override;
  end;
implementation

method GlobalObject.CreateArray: EcmaScriptObject;
begin
  result := EcmaScriptObject(Get(nil, 0, 'Array'));
  if result <> nil then exit;

  result := new EcmaScriptArrayObjectObject(self, &Class := 'Function');
  result.Prototype := FunctionPrototype;
  Values.Add('Array', PropertyValue.NotEnum(Result));

  ArrayPrototype := new EcmaScriptObject(self, &Class := 'Array');
  ArrayPrototype.Prototype := ObjectPrototype;
  
  result.values['prototype'] := PropertyValue.NotAllFlags(ArrayPrototype);
  result.Values.Add('isArray', PRopertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'isArray', @ArrayIsArray, 1)));

  DefaultCompareInstance := new EcmaScriptFunctionObject(self, 'defaultCompare', @DefaultCompare, 2);
  ArrayPrototype.Values['constructor'] := PropertyValue.NotEnum(result);
  ArrayPrototype.Values['length'] := PropertyValue.NotAllFlags(0);
  ArrayPrototype.Values.Add('toString', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'toString', @ArrayToString, 0, false, true)));
  ArrayPrototype.Values.Add('toLocaleString', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'toLocaleString', @ArrayToLocaleString, 0, false, true)));
  ArrayPrototype.Values.Add('concat', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'concat', @ArrayConcat, 1, false, true)));
  ArrayPrototype.Values.Add('join', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'join', @ArrayJoin, 1, false, true)));
  ArrayPrototype.Values.Add('pop', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'pop', @ArrayPop, 0, false, true)));
  ArrayPrototype.Values.Add('push', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'push', @ArrayPush, 1, false, true)));
  ArrayPrototype.Values.Add('reverse', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'reverse', @ArrayReverse, 0, false, true)));
  ArrayPrototype.Values.Add('shift', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'shift', @ArrayShift, 0, false, true)));
  ArrayPrototype.Values.Add('slice', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'slice', @ArraySlice, 2, false, true)));
  ArrayPrototype.Values.Add('sort', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'sort', @ArraySort, 1, false, true)));
  ArrayPrototype.Values.Add('splice', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'splice', @ArraySplice, 2, false, true)));
  ArrayPrototype.Values.Add('unshift', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'unshift', @ArrayUnshift, 1, false, true)));



  ArrayPrototype.Values.Add('indexOf', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'indexOf', @ArrayindexOf, 1, false, true)));
  ArrayPrototype.Values.Add('lastIndexOf', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'lastIndexOf', @ArraylastIndexOf, 1, false, true)));
  ArrayPrototype.Values.Add('every', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'every', @Arrayevery, 1, false, true)));
  ArrayPrototype.Values.Add('some', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'some', @Arraysome, 1, false, true)));
  ArrayPrototype.Values.Add('forEach', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'forEach', @ArrayforEach, 1, false, true)));
  ArrayPrototype.Values.Add('map', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'map', @ArrayMap, 1, false, true)));
  ArrayPrototype.Values.Add('filter', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'filter', @Arrayfilter, 1, false, true)));
  ArrayPrototype.Values.Add('reduce', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'reduce', @Arrayreduce, 1, false, true)));
  ArrayPrototype.Values.Add('reduceRight', PropertyValue.NotEnum(new EcmaScriptFunctionObject(self, 'reduceRight', @ArrayreduceRight, 1, false, true)));
end;




constructor EcmaScriptArrayObject(aRoot: GlobalObject; aLength: Object);
begin
  inherited constructor(aRoot, aRoot.ArrayPrototype);
  &Class := 'Array';
  inherited DefineOwnProperty('length', new PropertyValue(PropertyAttributes.writable, Integer(0)), false);
  DefineOwnProperty('length', new PropertyValue(PropertyAttributes.writable, aLength), false)
end;

constructor EcmaScriptArrayObject(aCapacity: Integer; aRoot: GlobalObject);
begin
  inherited constructor(aRoot, aRoot.ArrayPrototype);
  &Class := 'Array';
  inherited DefineOwnProperty('length', new PropertyValue(PropertyAttributes.writable, 0), false);
end;

class method EcmaScriptArrayObject.TryGetArrayIndex(s: string; out val: Cardinal): Boolean;
begin
  result := UInt32.TryParse(s, out val)  and (val <> Cardinal.MaxValue);
end;

method EcmaScriptArrayObject.DefineOwnProperty(aName: String; aValue: PropertyValue; aThrow: Boolean): Boolean; 
begin
  var lOldLenDesc := GetOwnProperty('length');
  
  var lOldLen := Utilities.GetObjAsCardinal(lOldLenDesc:Value, Root.ExecutionContext);
  if aName = 'length' then begin
    if PropertyAttributes.HasValue not in aValue.Attributes then
      exit inherited;
    var lNewLen := Utilities.GetObjAsCardinal(aValue.Value, Root.ExecutionContext);
    var lLenVal := if lNewLen < cardinal(Int32.MaxValue) then Integer(lNewLen) else Double(Int64(lNewLen));
    if not Utilities.GetObjAsBoolean(Operators.Equal(lLenVal, Utilities.GetObjAsDouble(aValue.Value, Root.ExecutionContext), root.ExecutionContext), Root.ExecutionContext) then
      Root.RaiseNativeError(NativeErrorType.RangeError, 'Index out of range');
    aValue.Value := lLenVal;
    if lNewLen > lOldLen then 
      exit inherited;
    if not PropertyAttributes.writable not in lOldLenDesc.Attributes then begin
      if aThrow then
        Root.RaiseNativeError(NativeErrorType.TypeError, 'Value not writable');
      exit true;
    end;
    var lNewWritable := PropertyAttributes.writable in aValue.Attributes;
    aValue.Attributes := aValue.Attributes or PropertyAttributes.writable;
    if not inherited DefineOwnProperty(aName, aValue, aThrow) then exit false; // set the actual length
    while lNewLen < lOldLen do begin
      lOldLen := lOldLen - 1;
      if not Delete(lOldLen.ToString, false) then begin
         lOldLen := lOldLen +1;
        aValue.Value := if lOldLen < cardinal(Int32.MaxValue) then Integer(lOldLen) else Double(lOldLen);
        inherited DefineOwnProperty(aName, aValue, false);
        if aThrow then
          Root.RaiseNativeError(NativeErrorType.TypeError, 'Element '+(lOldLen-1)+' cannot be removed');
        exit true;
      end;
    end;
    if not lNewWritable then begin
      lOldLenDesc.Attributes := lOldLenDesc.Attributes and not PropertyAttributes.writable;
    end;
    exit true;
  end;
  var lIndex: Cardinal;
  if TryGetArrayIndex(aName, out lIndex) then begin
    if (PropertyAttributes.writable not in lOldLenDesc.Attributes) and (lIndex >= loldLen) then begin
      if aThrow then
        Root.RaiseNativeError(NativeErrorType.TypeError, 'Element out of range of array and length is readonly');
      exit true;
    end;
    if not inherited DefineOwnProperty(aName, aValue, false) then begin
      if aThrow then
        Root.RaiseNativeError(NativeErrorType.TypeError, 'Cannot write element '+aName);
      exit true;
    end;
    if lIndex >= lOldLen then begin
      lOldLen := lIndex + 1;
      lOldLenDesc.Value := if lOldLen < cardinal(Int32.MaxValue) then Integer(lOldLen) else Double(lOldLen);
    end;
    exit true;
  end;
  exit inherited;
end;

method EcmaScriptArrayObject.get_Length: Cardinal;
begin
  exit Utilities.GetObjAsCardinal(GetOwnProperty('length').Value, Root.ExecutionContext);
end;

method EcmaScriptArrayObject.AddValues(aItems: Array of Object): EcmaScriptArrayObject;
begin
  var lLen := Length;
  DefineOwnProperty('length', new PropertyValue(PropertyAttributes.writable, lLen + aItems.Length), true);
  for i: Cardinal := 0 to aItems.Length -1 do
    DefineOwnProperty((lLen + i).ToString, new PropertyValue(PropertyAttributes.All, aItems[i]), true);
  exit self;
end;

method EcmaScriptArrayObject.AddValue(aItem: Object);
begin
    DefineOwnProperty(Length.ToString(), new PropertyValue(PropertyAttributes.All, aItem), true);
end;


constructor EcmaScriptArrayObjectObject(aOwner: GlobalObject);
begin
  inherited constructor(aOwner, 'Array', @aOwner.ArrayCtor, 1, false);
end;


method GlobalObject.ArrayCtor(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  if (length(args) = 1) and ((args[0] is Integer) or (args[0] is Double)) then begin
    result := new EcmaScriptArrayObject(self, Args[0]); // create a new array of length arg
  end else begin
    result := new EcmaScriptArrayObject(self, 0).AddValues(Args);
  end;
end;

method GlobalObject.ArrayToString(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf :=  Utilities.ToObject(aCaller, aSelf);
  var lJoin := EcmaScriptBaseFunctionObject(lSelf.Get('join'));
  if lJoin = nil then exit ObjectToString(aCaller,aSelf);
  exit lJoin.CallEx(aCaller, aSelf);
end;

method GlobalObject.ArrayConcat(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lRes: EcmaScriptArrayObject;
  var lLen :=  Utilities.GetObjAsInteger(lSelf.Get('length'), aCaller);
  lRes := new EcmaScriptArrayObject(self, 0);
  for i: Integer := 0 to lLen -1 do begin
    lRes.AddValue(lSelf.Get(aCaller, 3, i.ToString()));
  end;

  for each el in Args do begin
    if el is EcmaScriptArrayObject then begin
      for i: Cardinal := 0 to EcmaScriptArrayObject(el).Length -1 do
      begin
        var lVal := EcmaScriptArrayObject(el).GetOwnProperty(i.ToString());
        if lVal <> nil then 
        lRes.AddValue(lVal.Value);
      end;
    end else
      lRes.AddValue(el);
  end;
  result := lRes;
end;

method GlobalObject.ArrayJoin(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSep := if Args.Length = 0 then nil else Utilities.GetArgAsString(Args, 0, aCaller);
  if (lSep = nil) then lSep := ',';
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lRes := new StringBuilder;
  for i: Integer := 0 to Utilities.GetObjAsInteger(lSelf.Get('length'), aCaller) -1 do begin
    if i <> 0 then lRes.Append(lSep);
    var lItem := Utilities.GetObjAsString(lSelf.Get(aCaller, 3, i.ToString()), aCaller);
    if (lItem = nil) then lItem := '';
    lRes.Append(lItem);
  end;
  exit lRes.ToString;
end;

method GlobalObject.ArrayPop(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);
  if lLen = 0 then begin
    lSelf.Put(aCaller, 'length', 0, 1);
    exit Undefined.Instance;
  end;
  var indx := (lLen -1).ToString;
  var el := lSelf.Get(aCaller, indx);
  lSelf.Delete(indx, true);
  lLen := (lLen -1);
  lSelf.Put(aCaller, 'length', indx);
  exit el;
end;

method GlobalObject.ArrayPush(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);
  for each el in args do begin
    lSelf.Put(aCaller, lLen.ToString, el);
    inc(lLen);
  end;
  exit Put(aCaller, 'length', if lLen < Cardinal(Int32.MaxValue) then Integer(lLen) else Double(lLen));
end;

method GlobalObject.ArrayReverse(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);
  var lMid := lLen / 2;
  var lLow := 0;
  while lLow <> lMid do begin
    var lUp := lLen - lLow -1;
    var lUpP := lUp.ToString;
    var lLowP := lLow.ToString;
    var lLowVal := lSelf.Get(aCaller, lLowP);
    var lUpVal := lSelf.Get(aCaller, lUpP);
    var lLowerExists := lSelf.HasProperty(lLowP);
    var lUpperExists := lSelf.HasProperty(lUpP);
    if lLowerExists and lUpperExists then begin
      lSelf.Put(aCaller, lLowP, lUpVal, 1);
      lSelf.Put(aCaller, lUpP, lLowVal, 1);
    end else if not lLowerExists and lUpperExists then begin
      lSelf.Put(aCaller, lLowP, lUpVal, 1);
      lSelf.Delete(lUpP, true);
    end else if not lLowerExists and not lUpperExists then begin
      lSelf.Delete(lLowP, true);
      lSelf.Put(aCaller, lUpP, lLowVal, 1);
    end;

    inc(lLow);
  end;
  exit lSelf;
end;

method GlobalObject.ArrayShift(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);
  if lLen = 0 then begin
    lSelf.Put(aCaller, 'length', 0, 1);
    exit Undefined.Instance;
  end;
  var first := lSelf.Get(aCaller, 0, '0');
  var k: Cardinal := 1;
  while k < lLen do begin
    var lfrom := k.ToString;
    var lto  := (k-1).ToString;
    if lSelf.HasProperty(lFrom) then begin
      lSelf.Put(aCaller, lTo, lSelf.Get(aCaller, lFrom));
    end else
      lSelf.Delete(lTo, true);
    inc(k);
  end;
  var lNewLen := (lLen -1).ToString;
  lSelf.Delete(lNewLen, true);
  lSelf.Put(aCaller, 'length', lNewLen);
  exit first;
end;

method GlobalObject.ArraySlice(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);

  var lRelStart := Utilities.GetArgAsDouble(args, 0, aCaller);
  var k: Cardinal;
  if lRelStart < 0 then 
    k := Cardinal(Int64(Math.Max(Double(lLen + lRelStart), 0))) 
  else 
    k := Cardinal(Int64(Math.Min(lRelStart, Double(Int64(lLen)))));
  var lRelEnd := if (lengtH(args) < 2) or (args[1] = Undefined.Instance) then lLen else Utilities.GetArgAsDouble(args, 1, aCaller);
  var lFinal := if lRelEnd < 0 then Cardinal(Math.Max(lLen + Integer(lRelEnd), 0)) else Cardinal(Int64(Math.Min(lRelEnd, Double(lLen))));
  var a := new EcmaScriptArrayObject(Root, 0);
  var n := 0;
  while k < lFinal do begin
    var pk := k.ToString;
    if lSelf.HasProperty(pk) then begin
      a.Put(aCaller, n.ToString(), lSelf.Get(aCaller, 0, pk), 0);
    end;

    inc(n);
    inc(k);
  end;
  exit A;
end;

method GlobalObject.ArraySort(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);

  var lFunc := EcmaScriptBaseFunctionObject(Utilities.GetArg(Args, 0));
  if lFunc = nil then begin
    lFunc := DefaultCompareInstance;
  end;
  Sort(lSelf, 0, lLen -1,
    method (aList: EcmaScriptObject; L, R: Integer) begin
      if l <> r then self.Swap(self.ExecutionContext, aList, L, R);
    end,
    method (aList: EcmaScriptObject; L, R: Integer): Integer begin
      var jString := L.ToString;
      var kString := R.ToString;
      var hasJ := aList.HasProperty(jString);
      var hasK := aList.HasProperty(kString);
      if not hasJ and not hasK then exit 0;
      if not hasJ then exit 1;
      if not hasK then exit -1;
      var x := aList.Get(aCaller, 0, jString);
      var y := aList.Get(aCaller, 0, kString);
      if (x=Undefined.Instance) and (y = Undefined.Instance) then exit 0;
      if x = Undefined.Instance then exit 1;
      if y = Undefined.Instance then exit -1;
      exit Utilities.GetObjAsInteger(lFunc.CallEx(aCaller, aList, x, y), aCaller);
    end);
  exit lSelf;
end;

method GlobalObject.ArraySplice(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var A := new EcmaScriptArrayObject(self, 0);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);

  var lRelativeStart := Utilities.GetArgAsInteger(Args, 0, aCaller);
  var lActualStart := if lRelativeStart < 0 then Math.Max(lLen + lRelativeStart, 0) else Math.Min(lRelativeStart, Integer(lLen));

  var lActualDeleteCount := Math.Min(Math.Max(Utilities.GetArgAsInteger(Args, 1, aCaller), 0), lLen - lActualStart);
  var k: Integer := 0;
  while k < lActualDeleteCount do begin
    var lFrom := (lRelativeStart + k).ToString;
    if lSelf.HasProperty(lFrom) then begin
      A.Put(aCaller, K.ToString(), lSelf.Get(aCaller, lFrom));
    end;
    inc(k);
  end;

  if Length(Args) - 2< lActualDeleteCount then begin
    k := lActualStart;
    while k < (lLen - lActualDeleteCount) do begin
      var lFrom := (k + lActualDeleteCount).ToString;
      var lTo := (k + Length(Args) - 2).ToString;
      if lSelf.HasProperty(lFrom) then 
        lSelf.Put(aCaller, lTo, lSelf.Get(aCaller, lFrom))
      else
        lSelf.Delete(lTo, true);
      inc(k);
    end;
  end else if length(args) -2 > lActualDeleteCount then begin
    k := lLen - lActualDeleteCount;
    while k > lActualStart do begin
      var lFrom := (k + lActualDeleteCount -1).ToString;
      var lTo := (k + length(Args)- 3).ToString;
      if lSelf.HasProperty(lFrom) then 
        lSelf.Put(aCaller, lTo, lSelf.Get(aCaller, lFrom))
      else
        lSelf.Delete(lTo, true);
      dec(k);
    end;
  end;
  k := lActualStart;
  for i: Integer := 2 to Length(Args) -1 do begin
    lSelf.Put(aCaller, k.ToString(), Args[i]);
    inc(k);
  end;

  lSelf.Put(aCaller, 'length', Integer(lLen - lActualDeleteCount + (length(Args)-2)));
  exit A;
end;

method GlobalObject.ArrayUnshift(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lSelf := Utilities.ToObject(aCaller, aSelf);
  var lLen := Utilities.GetObjAsCardinal(lSelf.Get(aCaller, 0, 'length'), aCaller);
  var argcount := Length(args);
  var k := lLen;
  while k > 0 do begin
    var lfrom := (k-1).ToString;
    var lto  := (k+argcount-1).ToString;
    if lSelf.HasProperty(lFrom) then begin
      lSelf.Put(aCaller, lTo, lSelf.Get(aCaller, lFrom));
    end else
      lSelf.Delete(lTo, true);
    dec(k);
  end;
  for j: Integer := 0 to Length(Args) -1 do begin
    lSelf.Put(aCaller, j.ToString(), args[j], 1);
  end;
  lSelf.Put(aCaller, 'length', Integer(lLen)+argcount);
  exit lSelf;
end;

method GlobalObject.DefaultCompare(aCaller: ExecutionContext; aSelf: Object; params Args: Array of Object): Object;
begin
  var lLeft := args[0];
  var lRight := args[1];
  if lLeft = lRight then exit 0;
  if lLeft = Undefined.Instance then exit 1;
  if lRight = Undefined.Instance then exit -1;
  if lLeft = nil then exit 1;
  if lRight = nil then exit -1;

  if (lLeft is String) or (lRight is String) then 
    exit String.Compare(Utilities.GetObjAsString(lLeft, aCaller), Utilities.GetObjAsString(lRight, aCaller), StringComparison.Ordinal);
  if lLeft is EcmaScriptObject then 
    exit iif(lRight is EcmaScriptObject, 1, 0);
  if lRight is EcmaScriptObject then 
    exit -1;
  exit Utilities.GetObjAsDouble(lLeft, aCaller).CompareTo(Utilities.GetObjAsDouble(lRight, aCaller));
end;


method GlobalObject.ArrayToLocaleString(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  if lObj = nil then RaiseNativeError(NativeErrorType.ReferenceError, 'Object type expected');
  var lLen := Utilities.GetObjAsInteger(lObj.Get(aCaller, 0, 'length'), aCaller);
  var lRes := new StringBuilder;
  for i: Integer := 0 to lLen -1 do begin
    var lVal := Utilities.ToObject(aCaller, lObj.Get(aCaller, 2, i.ToString));
    var lData: string;
    if lVal = nil then begin
      lData := String.Empty;
    end else begin
      var lLocale := EcmaSCriptFunctionObject(lVAl.Get('toLocaleString'));
      if lLocale = nil then RaiseNativeError(NativeErrorType.ReferenceError, 'element '+i+' in array does not have a callable toLocaleString');
      lData := Utilities.GetObjAsString(lLocale.CallEx(aCaller, lVal), aCaller);
    end;
    
    if i <> 0 then lRes.Append(',');
    lREs.Append(lData);
  end;
  exit lRes.ToString;
end;

method GlobalObject.Sort<T>(aList: T; aStart, aEnd: Integer; aSwap: Action<T, Integer, Integer>; aCompare: Func<T, Integer, Integer, Integer>): Boolean;
begin
  var I: Integer;
  repeat
    I := aStart;
    var J := aEnd;
    var P := (aStart + aEnd) shr 1;
    repeat
      while aCompare(aList, I, P) < 0 do
        Inc(I);
      while aCompare(aList, J, P) > 0 do
        Dec(J);
      if I <= J then begin
        Result := true;
        aSwap(aList, I, J);

        if P = I then
          P := J
        else if P = J then
          P := I;

        Inc(I);
        Dec(J);
      end;
    until I > J;
    if aStart < J then
       Result := Sort<T>(aList, aStart, J, aSwap, aCompare) or Result;
    aStart := I;
  until I >= aEnd;
end;

method GlobalObject.ArrayIsArray(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lEl := EcmaScriptArrayObject(Utilities.GetArg(Args, 0));
  if lEl = nil then exit false;
  exit lEl <> nil;
end;

method GlobalObject.ArrayIndexOf(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lElement := utilities.GetArg(Args, 0);
  var lStart := Utilities.GetArgAsInteger(args, 1, aCaller);
  if lStart >= lLen then exit -1;
  if lStart < 0 then lStart := lLen + lStart;
  while lStart < lLen do begin
    var lIndex := lStart.ToString;
    if lObj.HasProperty(lIndex) then
      if Boolean(Operators.StrictEqual(lObj.Get(aCaller, 2, lIndex), lElement, aCaller)) then exit lStart;
    lStart := lStart + 1;
  end;
  exit -1;
end;

method GlobalObject.ArrayEvery(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lCallback := EcmaScriptBaseFunctionObject(Utilities.GetArg(args, 0));
  var lCallbackThis := coalesce(UTilities.GetArg(args, 1), Undefined.Instance);
  if lCallback = nil then RaiseNativeError(nativeErrorType.TypeError, 'Delegate expected');
  for i: Integer := 0 to lLen -1 do begin
    var lIndex := i.ToString;
    if lObj.HasProperty(lIndex) then
      if not Utilities.GetObjAsBoolean(lCallback.CallEx(aCaller, lCallbackThis, lObj.Get(aCaller, 2, lIndex), i, lObj), aCaller) then exit false;
  end;
  exit true;
end;

method GlobalObject.ArrayLastIndexOf(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lElement := utilities.GetArg(Args, 0);
  var lStart := if Args.length >= 2 then Utilities.GetArgAsInteger(args, 1, aCaller) else lLen;
  if lLen = 0 then exit false;
  if lStart >= lLen then lStart := lLen -1;
  if lStart < 0 then lStart := lLen + lStart;
  while lStart >= 0 do begin
    var lIndex := lStart.ToString;
    if lObj.HasProperty(lIndex) then
      if Boolean(Operators.StrictEqual(lObj.Get(aCaller, 2, lIndex), lElement, aCaller)) then exit lStart;
    lStart := lStart - 1;
  end;
  exit -1;
end;

method GlobalObject.ArraySome(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lCallback := EcmaScriptBaseFunctionObject(Utilities.GetArg(args, 0));
  var lCallbackThis := coalesce(UTilities.GetArg(args, 1), Undefined.Instance);
  if lCallback = nil then RaiseNativeError(nativeErrorType.TypeError, 'Delegate expected');
  for i: Integer := 0 to lLen -1 do begin
    var lIndex := i.ToString;
    if lObj.HasProperty(lIndex) then
      if Utilities.GetObjAsBoolean(lCallback.CallEx(aCaller, lCallbackThis, lObj.Get(aCaller, 2, lIndex), i, lObj), aCaller) then exit true;
  end;
  exit false;
end;

method GlobalObject.ArrayMap(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lCallback := EcmaScriptBaseFunctionObject(Utilities.GetArg(args, 0));
  var lCallbackThis := coalesce(UTilities.GetArg(args, 1), Undefined.Instance);
  if lCallback = nil then RaiseNativeError(nativeErrorType.TypeError, 'Delegate expected');
  var lRes := new EcmaScriptArrayObject(lLen, self);
  for i: Integer := 0 to lLen -1 do begin
    var lIndex := i.ToString;
    if lObj.HasProperty(lIndex) then begin
      lRes.AddValue(lCallback.CallEx(aCaller, lCallbackThis, lObj.Get(aCaller, 2, lIndex), i, lObj));
    end;
  end;
  exit lRes;
end;

method GlobalObject.ArrayForeach(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lCallback := EcmaScriptBaseFunctionObject(Utilities.GetArg(args, 0));
  var lCallbackThis := coalesce(UTilities.GetArg(args, 1), Undefined.Instance);
  if lCallback = nil then RaiseNativeError(nativeErrorType.TypeError, 'Delegate expected');
  for i: Integer := 0 to lLen -1 do begin
    var lIndex := i.ToString;
    if lObj.HasProperty(lIndex) then
      lCallback.CallEx(aCaller, lCallbackThis, lObj.Get(aCaller, 2, lIndex), i, lObj);
  end;
  exit Undefined.Instance;
end;

method GlobalObject.ArrayFilter(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lCallback := EcmaScriptBaseFunctionObject(Utilities.GetArg(args, 0));
  var lCallbackThis := coalesce(UTilities.GetArg(args, 1), Undefined.Instance);
  if lCallback = nil then RaiseNativeError(nativeErrorType.TypeError, 'Delegate expected');
  var lRes := new EcmaScriptArrayObject(lLen, self);
  for i: Integer := 0 to lLen -1 do begin
    var lIndex := i.ToString;
    if lObj.HasProperty(lIndex) then begin
      var lGet := lObj.Get(aCaller, 2, lIndex);
      if Utilities.GetObjAsBoolean(lCallback.CallEx(aCaller, lCallbackThis, lGet, i, lObj), aCaller) then
        lRes.AddValue(lGet);
    end;
  end;
  exit lRes;
end;

method GlobalObject.ArrayReduce(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lCallback := EcmaScriptBaseFunctionObject(Utilities.GetArg(args, 0));
  if lCallback = nil then RaiseNativeError(nativeErrorType.TypeError, 'Delegate expected');
  var lInitialValue := Utilities.GetArg(args, 1);
  var lGotInitial := false;
  if args.Length >= 2 then 
    lGotInitial := true;
  var k := 0;
  if not lGotInitial then begin
    while k < lLen do begin
      var lKey := k.ToString;
      inc(k);
      if lObj.HasProperty(lKey) then begin
        lGotInitial := true;
        lInitialValue := lObj.Get(aCaller, 2, lKey);
        break;
      end;
    end;
  end;
  if not lGotInitial then
    RaiseNativeError(NativeErrorType.TypeError, 'Empty array');
  while k < lLen do begin
    var lKey := k.ToString;
    if lObj.HasProperty(lKey) then
    lInitialValue := lCallback.CallEx(aCaller, Undefined.Instance, lInitialValue, lObj.Get(aCaller, 2, lKey), k, lObj);

    inc(k);
  end;
  exit lInitialValue;
end;

method GlobalObject.ArrayReduceRight(aCaller: ExecutionContext;aSelf: Object; params Args: array of Object): Object;
begin
  var lObj := Utilities.ToObject(aCaller, aSelf);
  var lLen := UTilities.GetObjAsInteger(lObj.Get('length'), aCaller);
  var lCallback := EcmaScriptBaseFunctionObject(Utilities.GetArg(args, 0));
  if lCallback = nil then RaiseNativeError(nativeErrorType.TypeError, 'Delegate expected');
  var lInitialValue := Utilities.GetArg(args, 1);
  var lGotInitial := false;
  if args.Length >= 2 then 
    lGotInitial := true;
  var k := lLen -1;
  if not lGotInitial then begin
    while k >= 0 do begin
      var lKey := k.ToString;
      dec(k);
      if lObj.HasProperty(lKey) then begin
        lGotInitial := true;
        lInitialValue := lObj.Get(aCaller, 2, lKey);
        break;
      end;
    end;
  end;
  if not lGotInitial then
    RaiseNativeError(NativeErrorType.TypeError, 'Empty array');
  while k >= 0 do begin
    var lKey := k.ToString;
    if lObj.HasProperty(lKey) then
    lInitialValue := lCallback.CallEx(aCaller, Undefined.Instance, lInitialValue, lObj.Get(aCaller, 2, lKey), k, lObj);

    dec(k);
  end;
  exit lInitialValue;
end;

method GlobalObject.Swap(EC: ExecutionContext; aSelf: EcmaScriptObject; L: Int32; R: Int32);
begin
  var lStr := L.ToString;
  var LVal := aSElf.Get(ec, lStr);
  var lHasL := aSelf.HasProperty(lStr);
  var RStr := R.ToString;
  var RVal := aSElf.Get(ec, rStr);
  var lHasR := aSelf.HasProperty(rStr);

  if lHasL and lHasR then begin
    aSelf.Put(EC, lStr, RVal, 1);
    aSelf.Put(EC, RStr, lVal, 1);
  end else if not lHasL and lHasR then begin
    aSelf.Put(EC, lStr, RVal, 1);
    aSelf.Delete(RStr, true);
  end else if not lHasL and not lHasR then begin
    aSelf.Delete(lStr, true);
    aSelf.Put(EC, RStr, LVal, 1);
  end;

end;

method EcmaScriptArrayObjectObject.Construct(context: ExecutionContext; params args: array of Object): Object;
begin
    exit root.ArrayCtor(context, self, args)
end;

end.