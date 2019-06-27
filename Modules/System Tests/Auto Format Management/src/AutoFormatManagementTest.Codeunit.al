// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132584 "Auto Format Management Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryAssert: Codeunit "Library Assert";
        AutoFormatManagementTest: Codeunit "Auto Format Management Test";

    [Test]
    procedure TestAutoFormatType0()
    var
        AutoFormatManagement: Codeunit "Auto Format Management";
        AutoFormatManagementTestPage: TestPage "AutoFormatManagement Test Page";
    begin
        BindSubscription(AutoFormatManagementTest);

        // [GIVEN] A page with a field with AutoFormatType=0
        AutoFormatManagementTestPage.OpenView();

		// [WHEN] A value is inserted in the field
        AutoFormatManagementTestPage.Case0.SetValue(123);
        // [THEN] The inserted value is formatted using the default formatting rules (2 decimals)
        LibraryAssert.AreEqual('123.00', AutoFormatManagementTestPage.Case0.Value(), 'The return value should be "123.00"');

        AutoFormatManagementTestPage.Close();
        UnbindSubscription(AutoFormatManagementTest);

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with AutoFormatType=0 and AutoFormatExpr=whatever value
        // [THEN] An empty string is returned
        LibraryAssert.AreEqual('', AutoFormatManagement.ResolveAutoFormat(0, 'RandomText'), 'The return value should be an empty string');
    end;

    [Test]
    procedure TestAutoFormatType11()
    var
        AutoFormatManagement: Codeunit "Auto Format Management";
        AutoFormatManagementTestPage: TestPage "AutoFormatManagement Test Page";
    begin
        // [GIVEN] A page with a field with AutoFormatType=11
        AutoFormatManagementTestPage.OpenView();

        // [WHEN] The page field AutoFormatExpression is set to <Precision,4:4><Standard Format,0>
        // [WHEN] A value is inserted in the field
        AutoFormatManagementTestPage.Case11.SetValue(1234.12345);
        // [THEN] The inserted value is formatted using the formatting rule for AutoFormatType=11 (4 decimal values in this case)
        LibraryAssert.AreEqual('1,234.1235', AutoFormatManagementTestPage.Case11.Value(), 'The return value should be "1,234.1235"');

        AutoFormatManagementTestPage.Close();

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with AutoFormatType=11 and AutoFormatExpr=data formatting expression (<Precision,1:2><Standard Format,0> in this case)
        // [THEN] The same data formatting expression is returned
        LibraryAssert.AreEqual('<Precision,1:2><Standard Format,0>', AutoFormatManagement.ResolveAutoFormat(11, '<Precision,1:2><Standard Format,0>'),
            'The return value should be "<Precision,1:2><Standard Format,0>"');
    end;

    [Test]
    procedure TestAutoformatExtensibility()
    var
        AutoFormatManagement: Codeunit "Auto Format Management";
        AutoFormatManagementTestPage: TestPage "AutoFormatManagement Test Page";
    begin
        // [GIVEN] A page with a field with AutoFormatType=1000
        BindSubscription(AutoFormatManagementTest);
        AutoFormatManagementTestPage.OpenView();

        // [WHEN] The page field AutoFormatExpression is set to ''
        // [WHEN] A value is inserted in the field "Case1000"
        AutoFormatManagementTestPage.Case1000.SetValue(3456.67843);
        // [THEN] The inserted value is formatted using the formatting rule for AutoFormtType=1000 (1 decimal values in this case)
        LibraryAssert.AreEqual('3,456.7', AutoFormatManagementTestPage.Case1000.Value(), 'The return value should be "3,456.7"');

        AutoFormatManagementTestPage.Close();

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with AutoFormtType=1000 and AutoFormatExpr=''
        // [THEN] A data formatting expression is returned ('<Precision,1:1><Standard Format,0>' in this case)
        LibraryAssert.AreEqual('<Precision,1:1><Standard Format,0>', AutoFormatManagement.ResolveAutoFormat(1000, ''), 'The return value should be "<Precision,1:1><Standard Format,0>"');

        UnbindSubscription(AutoFormatManagementTest);
    end;

    [Test]
    procedure TestNotValidAutoformatType()
    var
        AutoFormatManagement: Codeunit "Auto Format Management";
        AutoFormatManagementTestPage: TestPage "AutoFormatManagement Test Page";
    begin
        // [GIVEN] A page with a field with a non valid AutoFormatType value (100 in this case)
        BindSubscription(AutoFormatManagementTest);
        AutoFormatManagementTestPage.OpenView();

        // [WHEN] The page field AutoFormatExpression is set to ''
        // [WHEN] A value is inserted in the field
        AutoFormatManagementTestPage.CaseNoMatch.SetValue(934.341);
        // [THEN] The inserted value is formatted by the server using the default value (2 decimals)
        LibraryAssert.AreEqual('934.34', AutoFormatManagementTestPage.CaseNoMatch.Value(), 'The return value should be "934.34"');

        AutoFormatManagementTestPage.Close();

        // [GIVEN] The function ResolveAutoFormat
        // [WHEN] Calling the function with a non valid AutoFormatType value and AutoFormatExpr=whatever value
        // [THEN] The empty string is returned
        LibraryAssert.AreEqual('', AutoFormatManagement.ResolveAutoFormat(100, 'RandomText'), 'The return value should be an empty string');

        UnbindSubscription(AutoFormatManagementTest);
    end;

    [Test]
    procedure TestReadRounding()
    var
        AutoFormatManagement: Codeunit "Auto Format Management";
    begin
        BindSubscription(AutoFormatManagementTest);

        // [GIVEN] The function ReadRounding
        // [WHEN] Calling the function
        // [THEN] The decimal value precision 0.0001 is returned
        LibraryAssert.AreEqual(0.0001, AutoFormatManagement.ReadRounding(), 'The return value should be "0.0001"');

        UnbindSubscription(AutoFormatManagementTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Auto Format Management", 'OnResolveAutoFormat', '', true, true)]
    [Normal]
    procedure HandleOnResolveAutoFormat(AutoFormatType: Integer; AutoFormatExpr: Text[80]; VAR Result: Text[80]; VAR Resolved: Boolean)
    begin
        if AutoFormatType = 1000 then begin
            Result := '<Precision,1:1><Standard Format,0>';
            Resolved := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Auto Format Management", 'OnReadRounding', '', true, true)]
    [Normal]
    procedure HandleOnReadRounding(VAR AmountRoundingPrecision: Decimal)
    begin
        AmountRoundingPrecision := 0.0001;
    end;
}