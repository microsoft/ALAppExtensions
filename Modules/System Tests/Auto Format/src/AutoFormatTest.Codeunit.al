// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132584 "Auto Format Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryAssert: Codeunit "Library Assert";
        AutoFormatTest: Codeunit "Auto Format Test";
        AutoFormatType: Enum "Auto Format";

    [Test]
    procedure TestAutoFormatType0()
    var
        AutoFormat: Codeunit "Auto Format";
        AutoFormatTestPage: TestPage "AutoFormat Test Page";
    begin
        BindSubscription(AutoFormatTest);

        // [GIVEN] A page with a field with AutoFormatType=0
        AutoFormatTestPage.OpenView();

        // [WHEN] A value is inserted in the field
        AutoFormatTestPage.Case0.SetValue(123);
        // [THEN] The inserted value is formatted using the default formatting rules (2 decimals)
        LibraryAssert.AreEqual('123.00', AutoFormatTestPage.Case0.Value(), 'The return value should be "123.00"');

        AutoFormatTestPage.Close();
        UnbindSubscription(AutoFormatTest);

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with AutoFormatType=0 and AutoFormatExpr=whatever value
        // [THEN] An empty string is returned
        LibraryAssert.AreEqual('', AutoFormat.ResolveAutoFormat(AutoFormatType::DefaultFormat, 'RandomText'), 'The return value should be an empty string');
    end;

    [Test]
    procedure TestAutoFormatType11()
    var
        AutoFormat: Codeunit "Auto Format";
        AutoFormatTestPage: TestPage "AutoFormat Test Page";
    begin
        // [GIVEN] A page with a field with AutoFormatType=11
        AutoFormatTestPage.OpenView();

        // [WHEN] The page field AutoFormatExpression is set to <Precision,4:4><Standard Format,0>
        // [WHEN] A value is inserted in the field
        AutoFormatTestPage.Case11.SetValue(1234.12345);
        // [THEN] The inserted value is formatted using the formatting rule for AutoFormatType=11 (4 decimal values in this case)
        LibraryAssert.AreEqual('1,234.1235', AutoFormatTestPage.Case11.Value(), 'The return value should be "1,234.1235"');

        AutoFormatTestPage.Close();

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with AutoFormatType=11 and AutoFormatExpr=data formatting expression (<Precision,1:2><Standard Format,0> in this case)
        // [THEN] The same data formatting expression is returned
        LibraryAssert.AreEqual('<Precision,1:2><Standard Format,0>', AutoFormat.ResolveAutoFormat(AutoFormatType::CustomFormatExpr, '<Precision,1:2><Standard Format,0>'),
            'The return value should be "<Precision,1:2><Standard Format,0>"');
    end;

    [Test]
    procedure TestAutoFormatExtensibility()
    var
        AutoFormat: Codeunit "Auto Format";
        AutoFormatTestPage: TestPage "AutoFormat Test Page";
    begin
        // [GIVEN] A page with a field with AutoFormatType=1000
        BindSubscription(AutoFormatTest);
        AutoFormatTestPage.OpenView();

        // [WHEN] The page field AutoFormatExpression is set to ''
        // [WHEN] A value is inserted in the field "Case1000"
        AutoFormatTestPage.Case1000.SetValue(3456.67843);
        // [THEN] The inserted value is formatted using the formatting rule for AutoFormatType=1000 (1 decimal values in this case)
        LibraryAssert.AreEqual('3,456.7', AutoFormatTestPage.Case1000.Value(), 'The return value should be "3,456.7"');

        AutoFormatTestPage.Close();

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with AutoFormatType=1000 and AutoFormatExpr=''
        // [THEN] A data formatting expression is returned ('<Precision,1:1><Standard Format,0>' in this case)
        LibraryAssert.AreEqual('<Precision,1:1><Standard Format,0>', AutoFormat.ResolveAutoFormat("Auto Format"::"1 decimal", ''), 'The return value should be "<Precision,1:1><Standard Format,0>"');

        UnbindSubscription(AutoFormatTest);
    end;

    [Test]
    procedure TestNotValidAutoFormatType()
    var
        AutoFormat: Codeunit "Auto Format";
        AutoFormatTestPage: TestPage "AutoFormat Test Page";
    begin
        // [GIVEN] A page with a field with a non valid AutoFormatType value (100 in this case)
        BindSubscription(AutoFormatTest);
        AutoFormatTestPage.OpenView();

        // [WHEN] The page field AutoFormatExpression is set to ''
        // [WHEN] A value is inserted in the field
        AutoFormatTestPage.CaseNoMatch.SetValue(934.341);
        // [THEN] The inserted value is formatted by the server using the default value (2 decimals)
        LibraryAssert.AreEqual('934.34', AutoFormatTestPage.CaseNoMatch.Value(), 'The return value should be "934.34"');

        AutoFormatTestPage.Close();

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with a non valid AutoFormatType value and AutoFormatExpr=whatever value
        // [THEN] The empty string is returned
        LibraryAssert.AreEqual('', AutoFormat.ResolveAutoFormat("Auto Format"::Whatever, 'RandomText'), 'The return value should be an empty string');

        UnbindSubscription(AutoFormatTest);
    end;

    [Test]
    procedure TestReadRounding()
    var
        AutoFormat: Codeunit "Auto Format";
    begin
        BindSubscription(AutoFormatTest);

        // [GIVEN] The function ReadRounding
        // [WHEN] Calling the function
        // [THEN] The decimal value precision 0.0001 is returned
        LibraryAssert.AreEqual(0.0001, AutoFormat.ReadRounding(), 'The return value should be "0.0001"');

        UnbindSubscription(AutoFormatTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Auto Format", 'OnResolveAutoFormat', '', true, true)]
    [Normal]
    local procedure HandleOnResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]; VAR Result: Text[80]; VAR Resolved: Boolean)
    begin
        if AutoFormatType = AutoFormatType::"1 Decimal" then begin
            Result := '<Precision,1:1><Standard Format,0>';
            Resolved := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Auto Format", 'OnReadRounding', '', true, true)]
    [Normal]
    local procedure HandleOnReadRounding(VAR AmountRoundingPrecision: Decimal)
    begin
        AmountRoundingPrecision := 0.0001;
    end;
}