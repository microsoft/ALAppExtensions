namespace Microsoft.Sales.Document.Test;
using System.TestTools.AITestToolkit;

codeunit 149826 "Extract Info. Accuracy"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        ExtractInformationFromCsvFunctionLbl: Label 'extract_information_from_csv';

    [Test]
    procedure TestHandlingOfCsvFileData()
    var
        AITTestContext: Codeunit "AIT Test Context";
    begin
        ExecutePromptAndVerifyReturnedJson(AITTestContext.GetInput().ToText(), ExtractInformationFromCsvFunctionLbl);
    end;

    internal procedure ExecutePromptAndVerifyReturnedJson(TestInput: Text; ExtractInformationFromCsvFunction: Text)
    var
        AITTestContext: Codeunit "AIT Test Context";
        TestUtility: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: Text;
        UserQuery: Text;
    begin
        ReadDatasetInput(TestInput, UserQuery);
        TestUtility.RepeatAtMost3TimesToFetchCompletionForAttachment(CallCompletionAnswerTxt, UserQuery);
        AITTestContext.SetTestOutput(CallCompletionAnswerTxt);
        CheckReturnedJSONContent(CallCompletionAnswerTxt, ExtractInformationFromCsvFunction);
    end;

    internal procedure ReadDatasetInput(TestInput: Text; var UserQuery: Text)
    var
        JsonContent: JsonObject;
        JsonToken: JsonToken;
        UserQueryKeyLbl: Label 'user_query', Locked = true;
    begin
        JsonContent.ReadFrom(TestInput);
        JsonContent.Get(UserQueryKeyLbl, JsonToken);
        UserQuery := JsonToken.AsValue().AsText();
    end;

    [NonDebuggable]
    procedure CheckReturnedJSONContent(CompletionAnswerTxt: Text; ExpectedFunctionName: Text)
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionName: JsonToken;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerTxt);
        Function.AsObject().Get('name', FunctionName);
        Assert.AreEqual(ExpectedFunctionName, FunctionName.AsValue().AsText(), 'Function name is not correct');
    end;
}