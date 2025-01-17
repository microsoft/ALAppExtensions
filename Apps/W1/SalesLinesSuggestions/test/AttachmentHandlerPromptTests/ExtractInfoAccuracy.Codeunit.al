namespace Microsoft.Sales.Document.Test;
using System.TestTools.AITestToolkit;

codeunit 133518 "Extract Info. Accuracy"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        TestUtility: Codeunit "SLS Test Utility";
        IsInitialized: Boolean;
        ExtractInformationFromCsvFunctionLbl: Label 'extract_information_from_csv';

    [Test]
    procedure TestHandlingOfCsvFileData()
    var
        AITTestContext: Codeunit "AIT Test Context";
    begin
        Initialize();
        ExecutePromptAndVerifyReturnedJson(AITTestContext.GetQuestion().ValueAsText(), ExtractInformationFromCsvFunctionLbl);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        IsInitialized := true;
    end;

    local procedure ExecutePromptAndVerifyReturnedJson(TestInput: Text; ExtractInformationFromCsvFunction: Text)
    var
        AITTestContext: Codeunit "AIT Test Context";
        CallCompletionAnswerTxt: Text;
        UserQuery: Text;
    begin
        UserQuery := TestInput;
        TestUtility.RepeatAtMost3TimesToFetchCompletionForAttachment(CallCompletionAnswerTxt, UserQuery);
        AITTestContext.SetTestOutput(CallCompletionAnswerTxt);
        CheckReturnedJSONContent(CallCompletionAnswerTxt, ExtractInformationFromCsvFunction);
    end;

    local procedure CheckReturnedJSONContent(CompletionAnswerTxt: Text; ExpectedFunctionName: Text)
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