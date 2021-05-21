// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132577 "Caption Class Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        CaptionClassTest: Codeunit "Caption Class Test";
        CaptionClassExpression: Text;
        OriginalCaptionClassExpr: Text;
        ResolvedCaption: Text[1024];
        CaptionLanguage: Integer;

    [Test]
    procedure ResolveValidCaptionClassExpressionTest()
    var
        CaptionClassTestPage: TestPage "Caption Class Test Page";
    begin
        BindSubscription(CaptionClassTest);

        // [GIVEN] Well-formatted CaptionClass expression.
        CaptionClassExpression := '3,Some caption';
        GlobalLanguage(1030); // Danish

        // [WHEN] The page with the given CaptionClass is opened.
        CaptionClassTestPage.OpenView();

        // [THEN] The caption values are expected and the OnAfter event is emitted.
        Assert.AreEqual('Some caption', CaptionClassTestPage."Test field".Caption(), 'Wrong caption on page');

        Assert.AreEqual(GlobalLanguage(), CaptionLanguage, 'Wrong caption language');
        Assert.AreEqual('3,Some caption', OriginalCaptionClassExpr, 'Wrong original CaptionClass expression');
        Assert.AreEqual('Some caption', ResolvedCaption, 'Wrong resolved caption');

        UnbindSubscription(CaptionClassTest);
    end;

    [Test]
    procedure ResolveCaptionClassWithoutValidCaptionAreaTest()
    var
        CaptionClassTestPage: TestPage "Caption Class Test Page";
    begin
        BindSubscription(CaptionClassTest);

        // [GIVEN] A CaptionClass expression that is not in the valid format.
        CaptionClassExpression := 'Expression in the wrong format';
        GlobalLanguage(1033); // English - United States

        // [WHEN] The page with the given CaptionClass is opened.
        CaptionClassTestPage.OpenView();

        // [THEN] The resolving was unsuccessful, so the caption is the original CaptionClass value.
        Assert.AreEqual('Expression in the wrong format', CaptionClassTestPage."Test field".Caption(), 'Wrong caption on page');

        Assert.AreEqual(GlobalLanguage(), CaptionLanguage, 'Wrong caption language');
        Assert.AreEqual('Expression in the wrong format', OriginalCaptionClassExpr, 'Wrong original CaptionClass expression');
        Assert.AreEqual('Expression in the wrong format', ResolvedCaption, 'Wrong resolved caption');

        UnbindSubscription(CaptionClassTest);
    end;

    [Test]
    procedure ResolveCaptionClassExprEventEmittedTest()
    var
        CaptionClassTestPage: TestPage "Caption Class Test Page";
    begin
        BindSubscription(CaptionClassTest);

        // [GIVEN] CaptionClass expression with a valid caption area (not equal to three).
        CaptionClassExpression := 'Some caption area,Some caption expression';
        GlobalLanguage(1033); // English - United States

        // [WHEN] The page with the given CaptionClass is opened.
        CaptionClassTestPage.OpenView();

        // [THEN] The caption was changed after an OnResolveCaptionClass event was emitted.
        Assert.AreEqual('Result caption', CaptionClassTestPage."Test field".Caption(), 'Wrong caption on page');

        Assert.AreEqual(GlobalLanguage(), CaptionLanguage, 'Wrong caption language');
        Assert.AreEqual('Some caption area,Some caption expression', OriginalCaptionClassExpr, 'Wrong original CaptionClass expression');
        Assert.AreEqual('Result caption', ResolvedCaption, 'Wrong resolved caption');

        UnbindSubscription(CaptionClassTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnAfterCaptionClassResolve', '', true, true)]
    local procedure OnAfterResolveCaptionClassSubscriber(Language: Integer; CaptionExpression: Text; Caption: Text[1024])
    begin
        // Set global variables.
        CaptionLanguage := Language;
        OriginalCaptionClassExpr := CaptionExpression;
        ResolvedCaption := Caption;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    [Normal]
    local procedure HandleOnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        Assert.AreEqual('Some caption area', CaptionArea, 'Wrong caption area');
        Assert.AreEqual('Some caption expression', CaptionExpr, 'Wrong caption expression');
        Assert.AreEqual(GlobalLanguage(), Language, 'Wrong caption language');

        Resolved := true;
        Caption := 'Result caption';
    end;

    procedure GetCaptionClass(): Text
    begin
        exit(CaptionClassExpression);
    end;
}

