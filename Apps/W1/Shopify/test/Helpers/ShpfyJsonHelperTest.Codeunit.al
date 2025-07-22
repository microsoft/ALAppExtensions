// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

/// <summary>
/// Codeunit Shpfy Json Helper Test (ID 139574).
/// </summary>
codeunit 139574 "Shpfy Json Helper Test"
{
    Subtype = Test;
    RequiredTestIsolation = Disabled;
    TestPermissions = NonRestrictive;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        JsonHelper: Codeunit "Shpfy Json Helper";
        LibraryERM: Codeunit "Library - ERM";

    [Test]
    procedure UnitTestContainsToken()
    var
        JToken: JsonToken;
        Result: Boolean;
    begin
        // Creating Test data and expected results.
        JToken.ReadFrom('{"data": {"address": {"street": "' + Any.AlphabeticText(50) + '", "number": ' + Format(Any.IntegerInRange(1, 100)) + '}}}');

        // [SCENARIO] Test is a member is in a Json Token or Json Object
        // Member names can not contains the char '.'.
        // The members can be combine with the char "." to make the path.
        // The path can not look into an array.
        // [GIVEN] a Json Token with the value of {"data": {"address": {"street": "XXXXXX", "number": 999}}}
        // [WHEN] token path is data.address.street
        Result := JsonHelper.ContainsToken(JToken, 'data.address.street');
        // [THEN] Result = true
        LibraryAssert.IsTrue(Result, 'data.address.street');
        // [WHEN] token path is data.address.number
        Result := JsonHelper.ContainsToken(JToken.AsObject(), 'data.address.number');
        // [THEN] Result = true
        LibraryAssert.IsTrue(Result, 'data.address.number');
        // [WHEN] token path is data.address.number
        Result := JsonHelper.ContainsToken(JToken.AsObject(), 'data.address.name');
        // [THEN] Result = false
        LibraryAssert.IsFalse(Result, 'data.address.name');
    end;

    [Test]
    procedure UnitTestGetArrayAsText()
    var
        Index: Integer;
        MaxStringLength: Integer;
        JArray: JsonArray;
        JToken: JsonToken;
        Items: List of [Text];
        Result: Text;
        JConvertErr: Label 'The Json data: %1 is not converted to: %2', Comment = '%1 = the Json string, %2 = The expected results';
    begin
        // Creating Test data and expected results.
        for Index := 1 to Any.IntegerInRange(5, 10) do begin
            Items.Add(Any.AlphanumericText(20));
            JArray.Add(Items.Get(Index));
            Result := Result + ', ' + Items.Get(Index);
        end;
        Result := CopyStr(Result, 3);
        JToken.ReadFrom('{"data": {"testArray": ' + Format(JArray) + '}}');
        MaxStringLength := Any.IntegerInRange(StrLen(Result) / 2, StrLen(Result));

        // [SCENARIO] Test to convert a simple JsonArray with only JValue childs to a single string where the values a seperated with ', '.

        // [GIVEN] a JsonArray with JsonValue members.
        // [THEN] the output = Result.
        LibraryAssert.AreEqual(Result, JsonHelper.GetArrayAsText(JArray), StrSubstNo(JConvertErr, Format(JArray), Result));

        // [GIVEN] a JsonArray with JsonValue members 
        // [GIVEN] a max. string length.
        // [THEN] the output = CopyStr(Result, 1, MaxStringLength).
        LibraryAssert.AreEqual(CopyStr(Result, 1, MaxStringLength), JsonHelper.GetArrayAsText(JArray, MaxStringLength), StrSubstNo(JConvertErr, Format(JArray), CopyStr(Result, 1, MaxStringLength)));

        // [GIVEN] a JsonToken contain an JsonArray with JsonValue member deep down in the Jsons structure.
        // [GIVEN] the path to find the JsonArray in the Json structure.
        // [THEN] the output = Result.
        LibraryAssert.AreEqual(Result, JsonHelper.GetArrayAsText(JToken, 'data.testArray'), StrSubstNo(JConvertErr, Format(JToken), Result));

        // [GIVEN] a JsonToken contain an JsonArray with JsonValue member deep down in the Jsons structure.
        // [GIVEN] the path to find the JsonArray in the Json structure.
        // [GIVEN] a max. string length.
        // [THEN] the output = Result.
        LibraryAssert.AreEqual(CopyStr(Result, 1, MaxStringLength), JsonHelper.GetArrayAsText(JToken, 'data.testArray', MaxStringLength), StrSubstNo(JConvertErr, Format(JToken), CopyStr(Result, 1, MaxStringLength)));

        // [GIVEN] a JsonObject contain an JsonArray with JsonValue member deep down in the Jsons structure.
        // [GIVEN] the path to find the JsonArray in the Json structure.
        // [THEN] the output = Result.
        LibraryAssert.AreEqual(Result, JsonHelper.GetArrayAsText(JToken.AsObject(), 'data.testArray'), StrSubstNo(JConvertErr, Format(JToken), Result));

        // [GIVEN] a JsonObject contain an JsonArray with JsonValue member deep down in the Jsons structure.
        // [GIVEN] the path to find the JsonArray in the Json structure.
        // [GIVEN] a max. string length.
        // [THEN] the output = Result.
        LibraryAssert.AreEqual(CopyStr(Result, 1, MaxStringLength), JsonHelper.GetArrayAsText(JToken.AsObject(), 'data.testArray', MaxStringLength), StrSubstNo(JConvertErr, Format(JToken), CopyStr(Result, 1, MaxStringLength)));
    end;

    [Test]
    procedure UnitTestGetJsonArray()
    var
        Index: Integer;
        JArray: JsonArray;
        JToken: JsonToken;
        JResult: JsonArray;
        JsonArrayFoundErr: Label 'JsonArray found at %1 in: %2', Comment = '%1 = Path, %2 = JsonToken';
        NoJsonArrayFoundErr: Label 'No JsonArray found at %1 in: %2', Comment = '%1 = Path, %2 = JsonToken';
        NoMatchingResultErr: Label '%1 does not match %2', Comment = '%1 = the result, %21 = the expected result';
    begin
        // Creating Test data and expected results.
        for Index := 1 to Any.IntegerInRange(5, 10) do
            JArray.Add(Any.AlphanumericText(20));
        JToken.ReadFrom('{"data": {"testArray": ' + Format(JArray) + '}}');

        // [SCENARIO] Get a JsonArray out of a Json structure.

        // [GIVEN] a JsonToken containing the Json data with an array.
        // [GIVEN] a JsonArray for capture the result.
        // [GIVEN] a path for finding the JsonArray in the JsonToken.
        // [THEN] the result of the function returns true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonArray(JToken, JResult, 'data.testArray'), StrSubstNo(NoJsonArrayFoundErr, 'data.testArray', Format(JToken)));
        // [THEN] Format(JResult) = Format(JArray)
        LibraryAssert.IsTrue(Format(JResult) = Format(JArray), StrSubstNo(NoMatchingResultErr, Format(JResult), Format(JArray)));

        // [GIVEN] a JsonObject containing the Json data with an array.
        // [GIVEN] a JsonArray for capture the result.
        // [GIVEN] a path for finding the JsonArray in the JsonObject.
        // [THEN] the result of the function returns true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonArray(JToken.AsObject(), JResult, 'data.testArray'), StrSubstNo(NoJsonArrayFoundErr, 'data.testArray', Format(JToken)));
        // [THEN] Format(JResult) = Format(JArray)
        LibraryAssert.IsTrue(Format(JResult) = Format(JArray), StrSubstNo(NoMatchingResultErr, Format(JResult), Format(JArray)));

        // [GIVEN] a JsonToken containing the Json data.
        // [GIVEN] a JsonArray for capture the result.
        // [GIVEN] a wrong path for finding the JsonArray in the JsonToken.
        // [THEN] the result of the function returns false.
        LibraryAssert.IsFalse(JsonHelper.GetJsonArray(JToken, JResult, 'data'), StrSubstNo(JsonArrayFoundErr, 'data', Format(JToken)));
    end;

    [Test]
    procedure UnitTestGetJsonObject()
    var
        JToken: JsonToken;
        JResult: JsonObject;
        ObjectFoundErr: Label 'JsonObject found at %1, in %2', Comment = '%1 = Path, %2 = JsonToken';
        NoObjectFoundErr: Label 'No JsonObject found at %1, in %2', Comment = '%1 = Path, %2 = JsonToken';
    begin
        // Creating Test data and expected results.
        JToken.ReadFrom('{"data": {"address": {"street": "' + Any.AlphabeticText(50) + '", "number": ' + Format(Any.IntegerInRange(1, 100)) + '}}}');

        // [SCENARIO] Get a JsonObject out of a Json structure.

        // [GIVEN] a JsonToken containing an JsonObject
        // [GIVEN] a JsoObject for capture the result.
        // [GIVEN] a path for finding the in the JsonObject.
        // [THEN] the result of the function returns true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonObject(JToken, JResult, 'data.address'), StrSubstNo(NoObjectFoundErr, 'data.address', Format(JToken)));

        // [GIVEN] a JsonToken containing an JsonObject
        // [GIVEN] a JsoObject for capture the result.
        // [GIVEN] a wrong path for finding the JsonObject.
        // [THEN] the result of the function returns false.
        LibraryAssert.IsFalse(JsonHelper.GetJsonObject(JToken, JResult, 'data.address.street'), StrSubstNo(ObjectFoundErr, 'data.address.streaat', Format(JToken)));

        // [GIVEN] a JsonObject containing an JsonObject
        // [GIVEN] a JsoObject for capture the result.
        // [GIVEN] a path for finding the JsonObject.
        // [THEN] the result of the function returns true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonObject(JToken.AsObject(), JResult, 'data.address'), StrSubstNo(NoObjectFoundErr, 'data.address', Format(JToken)));

        // [GIVEN] a JsonObject containing an JsonObject
        // [GIVEN] a JsoObject for capture the result.
        // [GIVEN] a wrong path for finding the JsonObject.
        // [THEN] the result of the function returns false.
        LibraryAssert.IsFalse(JsonHelper.GetJsonObject(JToken.AsObject(), JResult, 'data.address.street'), StrSubstNo(ObjectFoundErr, 'data.address.streaat', Format(JToken)));
    end;

    [Test]
    procedure UnitTestGetJsonToken()

    var
        JToken: JsonToken;
        JResult: JsonToken;
        NoObjectFoundErr: Label 'No JsonObject found at %1, in %2', Comment = '%1 = Path, %2 = JsonToken';
        NoValueFoundErr: Label 'No JsonValue found at %1, in %2', Comment = '%1 = Path, %2 = JsonToken';
        ExpectedErr: Label 'Unable to convert from Microsoft.Dynamics.Nav.Runtime.NavJsonToken to Microsoft.Dynamics.Nav.Runtime.NavJsonObject.';
    begin
        GlobalLanguage(1033);
        // Creating Test data and expected results.
        JToken.ReadFrom('{"data": {"address": {"street": "' + Any.AlphabeticText(50) + '", "number": ' + Format(Any.IntegerInRange(1, 100)) + '}}}');

        // [SCENARIO] Get a JsonObject out of a Json structure.

        // [GIVEN] a JsonToken containing an JsonObject
        // [GIVEN] a JsonToken for capture the result.
        // [GIVEN] a path for finding the JsonObject in the JsonToken.
        JResult := JsonHelper.GetJsonToken(JToken, 'data.address');
        // [THEN] the JResult.IsObject() = true.
        LibraryAssert.IsTrue(JResult.IsObject(), StrSubstNo(NoObjectFoundErr, 'data.address', Format(JToken)));

        // [GIVEN] a JsonToken containing an JsonValue
        // [GIVEN] a JsonToken for capture the result.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        JResult := JsonHelper.GetJsonToken(JToken, 'data.address.street');
        // [THEN] the JResult.IsValue() = true.
        LibraryAssert.IsTrue(JResult.IsValue(), StrSubstNo(NoValueFoundErr, 'data.address.street', Format(JToken)));

        // [GIVEN] a JsonToken containing an JsonToken
        // [GIVEN] a JsonToken for capture the result.
        // [GIVEN] a invalid path for finding the JsonToken in the JsonToken.
        // [THEN] Error.
        asserterror JResult := JsonHelper.GetJsonToken(JToken, 'data.address.street.no');
        LibraryAssert.ExpectedError(ExpectedErr);
    end;

    [Test]
    procedure UnitTestGetJsonValue()
    var
        JToken: JsonToken;
        JResult: JsonValue;
        NoValueFoundErr: Label 'No JsonValue found at %1, in %2', Comment = '%1 = Path, %2 = JsonToken';
        ValueFoundErr: Label 'JsonValue found at %1, in %2', Comment = '%1 = Path, %2 = JsonToken';
    begin
        GlobalLanguage(1033);
        // Creating Test data and expected results.
        JToken.ReadFrom('{"data": {"address": {"street": "' + Any.AlphabeticText(50) + '", "number": ' + Format(Any.IntegerInRange(1, 100)) + '}}}');

        // [SCENARIO] Get a JsonObject out of a Json structure.

        // [GIVEN] a JsonToken containing an JsonValue
        // [GIVEN] a JsonValue for capture the result.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        // [THEN] the result of the function = true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonValue(JToken, JResult, 'data.address.street'), StrSubstNo(NoValueFoundErr, 'data.address.street', Format(JToken)));

        // [GIVEN] a JsonToken containing an JsonValue
        // [GIVEN] a JsonValue for capture the result.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        // [THEN] the result of the function = true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonValue(JToken, JResult, 'data.address.number'), StrSubstNo(NoValueFoundErr, 'data.address.number', Format(JToken)));

        // [GIVEN] a JsonToken containing an JsonValue
        // [GIVEN] a JsonValue for capture the result.
        // [GIVEN] a invalid path for finding the JsonValue in the JsonToken.
        // [THEN] the result of the function = false.
        LibraryAssert.IsFalse(JsonHelper.GetJsonValue(JToken, JResult, 'data.address.street.no'), StrSubstNo(ValueFoundErr, 'data.address.number', Format(JToken)));

        // [GIVEN] a JsonObject containing an JsonValue
        // [GIVEN] a JsonValue for capture the result.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        // [THEN] the result of the function = true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonValue(JToken.AsObject(), JResult, 'data.address.street'), StrSubstNo(NoValueFoundErr, 'data.address.street', Format(JToken)));

        // [GIVEN] a JsonObject containing an JsonValue
        // [GIVEN] a JsonValue for capture the result.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        // [THEN] the result of the function = true.
        LibraryAssert.IsTrue(JsonHelper.GetJsonValue(JToken.AsObject(), JResult, 'data.address.number'), StrSubstNo(NoValueFoundErr, 'data.address.number', Format(JToken)));

        // [GIVEN] a JsonObject containing an JsonValue
        // [GIVEN] a JsonValue for capture the result.
        // [GIVEN] a invalid path for finding the JsonValue in the JsonToken.
        // [THEN] the result of the function = false.
        LibraryAssert.IsFalse(JsonHelper.GetJsonValue(JToken.AsObject(), JResult, 'data.address.street.no'), StrSubstNo(ValueFoundErr, 'data.address.number', Format(JToken)));
    end;

    [Test]
    procedure UnitTestGetValueAsBigInteger()
    var
        ExpectedResult: BigInteger;
        Result: BigInteger;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.IntegerInRange(-1313548468, 156465984);
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a BigInteger value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an BigInteger value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsBigInteger(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an BigInteger value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsBigInteger(JToken, 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(0L, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an BigInteger value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsBigInteger(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an BigInteger value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsBigInteger(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(0L, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsBoolean()
    var
        ExpectedResult: Boolean;
        Result: Boolean;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := true;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Boolean value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Boolean value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsBoolean(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Boolean value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsBoolean(JToken, 'data.value');
        // [THEN] the result of the function = false.
        LibraryAssert.AreEqual(false, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Boolean value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsBoolean(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Boolean value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsBoolean(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = false.
        LibraryAssert.AreEqual(false, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsByte()
    var
        ExpectedResult: Byte;
        Result: Byte;
        ZeroByte: Byte;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.IntegerInRange(1, 8);
        ZeroByte := 0;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Byte value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Byte value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsByte(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Byte value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsByte(JToken, 'data.value');
        // [THEN] the result of the function = ZeroByte.
        LibraryAssert.AreEqual(ZeroByte, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Byte value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsByte(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Byte value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsByte(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = ZeroByte.
        LibraryAssert.AreEqual(ZeroByte, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsChar()
    var
        ExpectedResult: Char;
        Result: Char;
        ZeroChar: Char;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.AlphanumericText(1) [1];
        ZeroChar := 0;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Char value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Char value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsChar(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Char value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsChar(JToken, 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(ZeroChar, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Char value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsChar(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Char value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsChar(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(ZeroChar, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsCode()
    var
        ExpectedResult: Code[10];
        Result: Code[10];
        ZeroCode: Code[10];
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := CopyStr(Any.AlphanumericText(10), 1, MaxStrLen(ExpectedResult));
        ZeroCode := '';
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Code value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Code value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := CopyStr(JsonHelper.GetValueAsCode(JToken, 'data.someValue'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Code value longer then MaxLength.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        // [GIVEN] a MaxLength value = 5;
        Result := CopyStr(JsonHelper.GetValueAsCode(JToken, 'data.someValue', 5), 1, MaxStrLen(Result));
        // [THEN] the result of the function = CopyStr(ExpectedResult, 1, 5)
        LibraryAssert.AreEqual(CopyStr(ExpectedResult, 1, 5), Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Code value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := CopyStr(JsonHelper.GetValueAsCode(JToken, 'data.value'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ZeroCode.
        LibraryAssert.AreEqual(ZeroCode, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Code value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := CopyStr(JsonHelper.GetValueAsCode(JToken.AsObject(), 'data.someValue'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Code value longer then MaxLength.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        // [GIVEN] a MaxLength value = 5;
        Result := CopyStr(JsonHelper.GetValueAsCode(JToken.AsObject(), 'data.someValue', 5), 1, MaxStrLen(Result));
        // [THEN] the result of the function = CopyStr(ExpectedResult, 1, 5)
        LibraryAssert.AreEqual(CopyStr(ExpectedResult, 1, 5), Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Code value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := CopyStr(JsonHelper.GetValueAsCode(JToken.AsObject(), 'data.value'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ZeroCode.
        LibraryAssert.AreEqual(ZeroCode, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsDate()
    var
        ExpectedResult: Date;
        Result: Date;
        ZeroDate: Date;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.DateInRange(100);
        ZeroDate := 0D;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Date value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsDate(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsDate(JToken, 'data.value');
        // [THEN] the result of the function = ZeroDate.
        LibraryAssert.AreEqual(ZeroDate, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsDate(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsDate(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = ZeroDate.
        LibraryAssert.AreEqual(ZeroDate, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsDateTime()
    var
        ExpectedResult: DateTime;
        Result: DateTime;
        ZeroDateTime: DateTime;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := CurrentDateTime();
        ZeroDateTime := 0DT;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Date value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsDateTime(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsDateTime(JToken, 'data.value');
        // [THEN] the result of the function = ZeroDateTime.
        LibraryAssert.AreEqual(ZeroDateTime, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsDateTime(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsDateTime(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = ZeroDateTime.
        LibraryAssert.AreEqual(ZeroDateTime, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsDecimal()
    var
        ExpectedResult: BigInteger;
        Result: BigInteger;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.IntegerInRange(-1313548468, 156465984);
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a BigInteger value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an BigInteger value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsBigInteger(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an BigInteger value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsBigInteger(JToken, 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(0L, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an BigInteger value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsBigInteger(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an BigInteger value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsBigInteger(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(0L, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsDuration()
    var
        ExpectedResult: Duration;
        Result: Duration;
        ZeroDuration: Duration;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.IntegerInRange(100000);
        ZeroDuration := 0;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Date value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsDuration(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsDuration(JToken, 'data.value');
        // [THEN] the result of the function = ZeroDuration.
        LibraryAssert.AreEqual(ZeroDuration, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsDuration(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsDuration(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = ZeroDuration.
        LibraryAssert.AreEqual(ZeroDuration, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsInteger()
    var
        ExpectedResult: Integer;
        Result: Integer;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.IntegerInRange(-1313548468, 156465984);
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Integer value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Integer value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsInteger(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Integer value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsInteger(JToken, 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(0, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Integer value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsInteger(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Integer value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsInteger(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = 0.
        LibraryAssert.AreEqual(0, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsOption()
    var
        ExpectedResult: Option;
        Result: Option;
        ZeroOption: Option;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Any.IntegerInRange(0, 10);
        ZeroOption := 0;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Option value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Option value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsOption(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Option value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsOption(JToken, 'data.value');
        // [THEN] the result of the function = ZeroOption.
        LibraryAssert.AreEqual(ZeroOption, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Option value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsOption(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Option value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsOption(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = ZeroOption.
        LibraryAssert.AreEqual(ZeroOption, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsText()
    var
        ExpectedResult: Text[100];
        Result: Text[100];
        ZeroText: Text[100];
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := CopyStr(Any.AlphanumericText(100), 1, MaxStrLen(ExpectedResult));
        ZeroText := '';
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Text value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Text value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := CopyStr(JsonHelper.GetValueAsText(JToken, 'data.someValue'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Text value longer then MaxLength.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        // [GIVEN] a MaxLength value = 5;
        Result := CopyStr(JsonHelper.GetValueAsText(JToken, 'data.someValue', 25), 1, MaxStrLen(Result));
        // [THEN] the result of the function = CopyStr(ExpectedResult, 1, 25)
        LibraryAssert.AreEqual(CopyStr(ExpectedResult, 1, 25), Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Text value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := CopyStr(JsonHelper.GetValueAsText(JToken, 'data.value'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ZeroText.
        LibraryAssert.AreEqual(ZeroText, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Text value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := CopyStr(JsonHelper.GetValueAsText(JToken.AsObject(), 'data.someValue'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Text value longer then MaxLength.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        // [GIVEN] a MaxLength value = 5;
        Result := CopyStr(JsonHelper.GetValueAsText(JToken.AsObject(), 'data.someValue', 5), 1, MaxStrLen(Result));
        // [THEN] the result of the function = CopyStr(ExpectedResult, 1, 5)
        LibraryAssert.AreEqual(CopyStr(ExpectedResult, 1, 5), Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Text value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := CopyStr(JsonHelper.GetValueAsText(JToken.AsObject(), 'data.value'), 1, MaxStrLen(Result));
        // [THEN] the result of the function = ZeroText.
        LibraryAssert.AreEqual(ZeroText, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsTime()
    var
        ExpectedResult: Time;
        Result: Time;
        ZeroTime: Time;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        // Creating Test data and expected results.
        ExpectedResult := Time;
        ZeroTime := 0T;
        JValue.SetValue(ExpectedResult);
        JToken.ReadFrom('{"data":{"someValue": ' + Format(JValue) + '}}');

        // [SCENARIO] Get a Date value out of a Json structure.

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsTime(JToken, 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonToken with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonToken.
        Result := JsonHelper.GetValueAsTime(JToken, 'data.value');
        // [THEN] the result of the function = ZeroTime.
        LibraryAssert.AreEqual(ZeroTime, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsTime(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a wrong path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsTime(JToken.AsObject(), 'data.value');
        // [THEN] the result of the function = ZeroTime.
        LibraryAssert.AreEqual(ZeroTime, Result, '');
    end;

    [Test]
    procedure UnitTestGetValueAsDateTimezoneOffset()
    var
        CompanyInformation: Record "Company Information";
        PostCode: Record "Post Code";
        InputDateTime: Text;
        Result: Date;
        ExpectedResult: Date;
        JToken: JsonToken;
    begin
        // Creating Test data and expected results.
        InputDateTime := '"2024-03-31T23:00:00.0000000Z"'; // UTC 31/03/2024 23:00:00
        ExpectedResult := DMY2Date(1, 4, 2024); // Romance time 01/04/2024
        JToken.ReadFrom('{"data":{"someValue": ' + InputDateTime + '}}');

        CreatePostCode(PostCode);
        CompanyInformation.Get();
        CompanyInformation."Post Code" := PostCode.Code;
        CompanyInformation.City := PostCode.City;
        CompanyInformation.Modify();

        // [SCENARIO] Get a Date value out of a Json structure.

        // [GIVEN] a JsonObject with a JsonValue that contains an Date value.
        // [GIVEN] a path for finding the JsonValue in the JsonObject.
        Result := JsonHelper.GetValueAsDate(JToken.AsObject(), 'data.someValue');
        // [THEN] the result of the function = ExpectedResult
        LibraryAssert.AreEqual(ExpectedResult, Result, '');
    end;

    [Test]
    procedure UnitTestValueIntoField()
    var
        TestFields: Record "Shpfy Test Fields";
        TestFields2: Record "Shpfy Test Fields";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldNo: Integer;
        JObject: JsonObject;
        Path: Text;
    begin
        // Creating Test data and expected results.
        TestFields := TestFields.CreateNewRecordWithAnyValues();
        JObject.Add(TestFields.FieldName(BigIntegerField), TestFields.BigIntegerField);
        JObject.Add(TestFields.FieldName(BlobField), TestFields.GetBlobData());
        JObject.Add(TestFields.FieldName(BooleanField), TestFields.BooleanField);
        JObject.Add(TestFields.FieldName(CodeField), TestFields.CodeField);
        JObject.Add(TestFields.FieldName(TextField), TestFields.TextField);
        JObject.Add(TestFields.FieldName(DateField), TestFields.DateField);
        JObject.Add(TestFields.FieldName(DateTimeField), TestFields.DateTimeField);
        JObject.Add(TestFields.FieldName(DecimalField), TestFields.DecimalField);
        JObject.Add(TestFields.FieldName(DurationField), TestFields.DurationField);
        JObject.Add(TestFields.FieldName(GuidField), TestFields.GuidField);
        JObject.Add(TestFields.FieldName(IntegerField), TestFields.IntegerField);
        JObject.Add(TestFields.FieldName(OptionField), TestFields.OptionField);
        JObject.Add(TestFields.FieldName(TimeField), TestFields.TimeField);
        RecordRef.Open(Database::"Shpfy Test Fields");

        // [SCENARIO] Get values out of a Json structure and put the in to a field of a record.
        #region BigInteger
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(BigIntegerField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a BigInteger field
        FieldNo := TestFields.FieldNo(BigIntegerField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.BigIntegerField = RecRef.Field(TestField.FieldNo(BigIntegerField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(BigIntegerField));
        LibraryAssert.AreEqual(TestFields.BigIntegerField, FieldRef.Value, Format(FieldRef.Type));
        #endregion BigInteger

        #region Blob
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(BlobField);
        // [GIVEN] A RecordRef of an record.
        // [GIVEN] A FieldNo of a BlobField field
        FieldNo := TestFields.FieldNo(BlobField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.GetBlobData() = TestField2.GetBlobData()
        FieldRef := RecordRef.Field(TestFields.FieldNo(BigIntegerField));
        RecordRef.SetTable(TestFields2);
        LibraryAssert.AreEqual(TestFields.GetBlobData(), TestFields2.GetBlobData(), Format(FieldRef.Type));
        #endregion

        #region Boolean
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(BooleanField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a BooleanField field
        FieldNo := TestFields.FieldNo(BooleanField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.BooleanField = RecRef.Field(TestField.FieldNo(BooleanField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(BooleanField));
        LibraryAssert.AreEqual(TestFields.BooleanField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Boolean

        #region Code
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(CodeField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a CodeField field
        FieldNo := TestFields.FieldNo(CodeField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.CodeField = RecRef.Field(TestField.FieldNo(CodeField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(CodeField));
        LibraryAssert.AreEqual(TestFields.CodeField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Code

        #region Text
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(TextField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a TextField field
        FieldNo := TestFields.FieldNo(TextField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.TextField = RecRef.Field(TestField.FieldNo(TextField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(TextField));
        LibraryAssert.AreEqual(TestFields.TextField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Text

        #region Date
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DateField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DateField field
        FieldNo := TestFields.FieldNo(DateField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DateField = RecRef.Field(TestField.FieldNo(DateField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DateField));
        LibraryAssert.AreEqual(TestFields.DateField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Date

        #region DateTime
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DateTimeField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DateTimeField field
        FieldNo := TestFields.FieldNo(DateTimeField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DateTimeField = RecRef.Field(TestField.FieldNo(DateTimeField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DateTimeField));
        LibraryAssert.AreEqual(TestFields.DateTimeField, FieldRef.Value, Format(FieldRef.Type));
        #endregion DateTime

        #region Decimal
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DecimalField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DecimalField field
        FieldNo := TestFields.FieldNo(DecimalField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DecimalField = RecRef.Field(TestField.FieldNo(DecimalField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DecimalField));
        LibraryAssert.AreEqual(TestFields.DecimalField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Decimal

        #region Duration
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DurationField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DurationField field
        FieldNo := TestFields.FieldNo(DurationField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DurationField = RecRef.Field(TestField.FieldNo(DurationField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DurationField));
        LibraryAssert.AreEqual(TestFields.DurationField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Duration

        #region Guid
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(GuidField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a GuidField field
        FieldNo := TestFields.FieldNo(GuidField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.GuidField = RecRef.Field(TestField.FieldNo(GuidField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(GuidField));
        LibraryAssert.AreEqual(TestFields.GuidField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Guid

        #region Integer
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(IntegerField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a IntegerField field
        FieldNo := TestFields.FieldNo(IntegerField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.IntegerField = RecRef.Field(TestField.FieldNo(IntegerField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(IntegerField));
        LibraryAssert.AreEqual(TestFields.IntegerField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Integer

        #region Option
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(OptionField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a OptionField field
        FieldNo := TestFields.FieldNo(OptionField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.OptionField = RecRef.Field(TestField.FieldNo(OptionField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(OptionField));
        LibraryAssert.AreEqual(TestFields.OptionField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Option

        #region Time
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(TimeField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a TimeField field
        FieldNo := TestFields.FieldNo(TimeField);
        JsonHelper.GetValueIntoField(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.TimeField = RecRef.Field(TestField.FieldNo(TimeField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(TimeField));
        LibraryAssert.AreEqual(TestFields.TimeField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Time
    end;

    [Test]
    [HandlerFunctions('ValidationMessageHandler')]
    procedure UnitTestGetValueIntoFieldWithValidation()
    var
        TestFields: Record "Shpfy Test Fields";
        TestFields2: Record "Shpfy Test Fields";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldNo: Integer;
        JObject: JsonObject;
        Path: Text;
    begin
        // Creating Test data and expected results.
        TestFields := TestFields.CreateNewRecordWithAnyValues();
        JObject.Add(TestFields.FieldName(BigIntegerField), TestFields.BigIntegerField);
        JObject.Add(TestFields.FieldName(BlobField), TestFields.GetBlobData());
        JObject.Add(TestFields.FieldName(BooleanField), TestFields.BooleanField);
        JObject.Add(TestFields.FieldName(CodeField), TestFields.CodeField);
        JObject.Add(TestFields.FieldName(TextField), TestFields.TextField);
        JObject.Add(TestFields.FieldName(DateField), TestFields.DateField);
        JObject.Add(TestFields.FieldName(DateTimeField), TestFields.DateTimeField);
        JObject.Add(TestFields.FieldName(DecimalField), TestFields.DecimalField);
        JObject.Add(TestFields.FieldName(DurationField), TestFields.DurationField);
        JObject.Add(TestFields.FieldName(GuidField), TestFields.GuidField);
        JObject.Add(TestFields.FieldName(IntegerField), TestFields.IntegerField);
        JObject.Add(TestFields.FieldName(OptionField), TestFields.OptionField);
        JObject.Add(TestFields.FieldName(TimeField), TestFields.TimeField);
        RecordRef.Open(Database::"Shpfy Test Fields");

        // [SCENARIO] Get values out of a Json structure and put the in to a field of a record.
        #region BigInteger
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(BigIntegerField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a BigInteger field
        FieldNo := TestFields.FieldNo(BigIntegerField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.BigIntegerField = RecRef.Field(TestField.FieldNo(BigIntegerField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(BigIntegerField));
        LibraryAssert.AreEqual(TestFields.BigIntegerField, FieldRef.Value, Format(FieldRef.Type));
        #endregion BigInteger

        #region Blob
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(BlobField);
        // [GIVEN] A RecordRef of an record.
        // [GIVEN] A FieldNo of a BlobField field
        FieldNo := TestFields.FieldNo(BlobField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.GetBlobData() = TestField2.GetBlobData()
        FieldRef := RecordRef.Field(TestFields.FieldNo(BigIntegerField));
        RecordRef.SetTable(TestFields2);
        LibraryAssert.AreEqual(TestFields.GetBlobData(), TestFields2.GetBlobData(), Format(FieldRef.Type));
        #endregion

        #region Boolean
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(BooleanField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a BooleanField field
        FieldNo := TestFields.FieldNo(BooleanField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.BooleanField = RecRef.Field(TestField.FieldNo(BooleanField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(BooleanField));
        LibraryAssert.AreEqual(TestFields.BooleanField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Boolean

        #region Code
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(CodeField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a CodeField field
        FieldNo := TestFields.FieldNo(CodeField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.CodeField = RecRef.Field(TestField.FieldNo(CodeField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(CodeField));
        LibraryAssert.AreEqual(TestFields.CodeField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Code

        #region Text
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(TextField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a TextField field
        FieldNo := TestFields.FieldNo(TextField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.TextField = RecRef.Field(TestField.FieldNo(TextField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(TextField));
        LibraryAssert.AreEqual(TestFields.TextField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Text

        #region Date
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DateField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DateField field
        FieldNo := TestFields.FieldNo(DateField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DateField = RecRef.Field(TestField.FieldNo(DateField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DateField));
        LibraryAssert.AreEqual(TestFields.DateField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Date

        #region DateTime
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DateTimeField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DateTimeField field
        FieldNo := TestFields.FieldNo(DateTimeField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DateTimeField = RecRef.Field(TestField.FieldNo(DateTimeField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DateTimeField));
        LibraryAssert.AreEqual(TestFields.DateTimeField, FieldRef.Value, Format(FieldRef.Type));
        #endregion DateTime

        #region Decimal
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DecimalField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DecimalField field
        FieldNo := TestFields.FieldNo(DecimalField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DecimalField = RecRef.Field(TestField.FieldNo(DecimalField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DecimalField));
        LibraryAssert.AreEqual(TestFields.DecimalField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Decimal

        #region Duration
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(DurationField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a DurationField field
        FieldNo := TestFields.FieldNo(DurationField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.DurationField = RecRef.Field(TestField.FieldNo(DurationField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(DurationField));
        LibraryAssert.AreEqual(TestFields.DurationField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Duration

        #region Guid
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(GuidField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a GuidField field
        FieldNo := TestFields.FieldNo(GuidField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.GuidField = RecRef.Field(TestField.FieldNo(GuidField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(GuidField));
        LibraryAssert.AreEqual(TestFields.GuidField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Guid

        #region Integer
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(IntegerField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a IntegerField field
        FieldNo := TestFields.FieldNo(IntegerField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.IntegerField = RecRef.Field(TestField.FieldNo(IntegerField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(IntegerField));
        LibraryAssert.AreEqual(TestFields.IntegerField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Integer

        #region Option
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(OptionField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a OptionField field
        FieldNo := TestFields.FieldNo(OptionField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.OptionField = RecRef.Field(TestField.FieldNo(OptionField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(OptionField));
        LibraryAssert.AreEqual(TestFields.OptionField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Option

        #region Time
        // [GIVEN] A JsonObject that contains the data.
        // [GIVEN] A Path to the value.
        Path := TestFields.FieldName(TimeField);
        // [GIVEN] A RecordRef of an record.      
        // [GIVEN] A FieldNo of a TimeField field
        FieldNo := TestFields.FieldNo(TimeField);
        JsonHelper.GetValueIntoFieldWithValidation(JObject, Path, RecordRef, FieldNo);
        // [THEN] TestField.TimeField = RecRef.Field(TestField.FieldNo(TimeField)).Value
        FieldRef := RecordRef.Field(TestFields.FieldNo(TimeField));
        LibraryAssert.AreEqual(TestFields.TimeField, FieldRef.Value, Format(FieldRef.Type));
        #endregion Time
    end;

    [MessageHandler]
    procedure ValidationMessageHandler(Message: Text[1024])
    var
        ValidateMsg: Label 'Validate Triggger Executed', Locked = true;
    begin
        LibraryAssert.ExpectedMessage(ValidateMsg, Message);
    end;

    local procedure CreatePostCode(var PostCode: Record "Post Code")
    begin
        LibraryERM.CreatePostCode(PostCode);
        PostCode."Time Zone" := 'Romance Standard Time';
        PostCode.Modify();
    end;
}