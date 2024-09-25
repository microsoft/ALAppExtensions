namespace Microsoft.Sales.Document.Test;

using Microsoft.Sales.Document;
using System.Environment.Configuration;
using System.TestTools.TestRunner;
using System.TestTools.AITestToolkit;

codeunit 149800 "Magic Function Prompt Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GlobalSalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        TestUtility: Codeunit "SLS Test Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('AssertErrorNotificationHandler')]
    procedure AssertErrorNotificationAndEmptySuggestionE2E()
    var
        AITestContext: Codeunit "AIT Test Context";
        SalesOrderPage: TestPage "Sales Order";
        SalesLineAISuggestionsPage: TestPage "Sales Line AI Suggestions";
    begin
        Initialize();

        // [GIVEN] A sales order
        SalesOrderPage.OpenEdit();
        SalesOrderPage.GoToRecord(GlobalSalesHeader);

        // [WHEN] Sales lines are suggested based on the question from the dataset
        SalesLineAISuggestionsPage.Trap();
        SalesOrderPage.SalesLines."Suggest Sales Lines Prompting".Invoke();
        SalesLineAISuggestionsPage.SearchQueryTxt.SetValue(AITestContext.GetQuestion().ValueAsText());
        SalesLineAISuggestionsPage.Generate.Invoke(); // AssertErrorNotificationHandler will be called

        // [THEN] There should not be any suggestions
        Assert.IsFalse(SalesLineAISuggestionsPage.SalesLinesSub.First(), 'There should not be any suggestions');
    end;

    [Test]
    procedure AssertMagicFunctionOrFailedResponseUnitTest()
    var
        TestUtil: Codeunit "SLS Test Utility";
        AITestContext: Codeunit "AIT Test Context";
        CompletionAnswerTxt: Text;
    begin
        Initialize();

        // [GIVEN] A question from the dataset
        // [WHEN] Sales lines are suggested
        TestUtil.RepeatAtMost3TimesToFetchCompletion(CompletionAnswerTxt, AITestContext.GetQuestion().ValueAsText());

        // [THEN] Magic function should be returned or the response should be empty
        if StrLen(CompletionAnswerTxt) > 0 then // CompletionAnswerTxt is empty if there is no function returned form the api call
            AssertMagicFunction(CompletionAnswerTxt);
    end;

    [Test]
    procedure AssertMagicFunctionOrFailedResponseUnitTestWithEmbeddedInput()
    var
        TestUtil: Codeunit "SLS Test Utility";
        AITestContext: Codeunit "AIT Test Context";
        CompletionAnswerTxt: Text;
        InputTemplateLbl: Label 'Add 2 athens desk and %1.', Comment = '%1 = input string';
    begin
        Initialize();

        // [GIVEN] A question from the dataset
        // [WHEN] Sales lines are suggested
        TestUtil.RepeatAtMost3TimesToFetchCompletion(CompletionAnswerTxt, StrSubstNo(InputTemplateLbl, AITestContext.GetQuestion().ValueAsText()));

        // [THEN] Magic function should be returned or the response should be empty
        if StrLen(CompletionAnswerTxt) > 0 then // CompletionAnswerTxt is empty if there is no function returned form the api call
            AssertMagicFunction(CompletionAnswerTxt);
    end;

    [SendNotificationHandler]
    procedure AssertErrorNotificationHandler(var Notification: Notification): Boolean
    var
        ExpectedMessage1Msg: Label 'There are no suggestions for this description. Please rephrase it.';
        ExpectedMessage2Msg: Label 'Sorry, something went wrong. Please rephrase and try again.';
        AssertMsg: Label 'Notification message is incorrect. Expected: %1 or %2, Actual: %3', Comment = '%1 = ExpectedMessage1Msg, %2 = ExpectedMessage2Msg, %3 = Notification.Message';
    begin
        if not (Notification.Message.Contains(ExpectedMessage1Msg) or Notification.Message.Contains(ExpectedMessage2Msg)) then
            Assert.Fail(StrSubstNo(AssertMsg, ExpectedMessage1Msg, ExpectedMessage2Msg, Notification.Message));
    end;

    local procedure Initialize()
    var
        MyNotifications: Record "My Notifications";
    begin
        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        // Create a new sales header record
        LibrarySales.CreateSalesOrder(GlobalSalesHeader);

        // Disable notifications
        MyNotifications.SetRange("User Id", UserId);
        MyNotifications.SetRange(Enabled, true);
        MyNotifications.ModifyAll(Enabled, false);

        IsInitialized := true;
    end;

    local procedure AssertMagicFunction(CompletionAnswerTxt: Text)
    var
        AITestContext: Codeunit "AIT Test Context";
        TestOutputJson: Codeunit "Test Output Json";
        TestUtil: Codeunit "SLS Test Utility";
        FunctionArray: JsonArray;
        Function: JsonToken;
        FunctionName: JsonToken;
        MagicFunctionFound: Boolean;
        AssertMsg: Label 'The completion answer is not a magic function. Expected: magic_function, Actual: %1', Comment = 'Actual: %1';
    begin
        TestOutputJson.Initialize();
        TestOutputJson.Add('completion_answer', CompletionAnswerTxt);
        AITestContext.SetTestOutput(TestOutputJson.ToText()); // Log the response

        FunctionArray := TestUtil.GetFunctionArray(CompletionAnswerTxt);
        foreach Function in FunctionArray do begin
            Function.AsObject().Get('name', FunctionName);
            if FunctionName.AsValue().AsText() = 'magic_function' then
                MagicFunctionFound := true;
        end;

        if (FunctionArray.Count > 0) and not MagicFunctionFound then
            Assert.Fail(StrSubstNo(AssertMsg, FunctionName.AsValue().AsText()));
    end;
}