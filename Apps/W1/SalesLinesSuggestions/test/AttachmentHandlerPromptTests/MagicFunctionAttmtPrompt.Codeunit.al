namespace Microsoft.Sales.Document.Test;
using System.TestTools.AITestToolkit;

codeunit 133523 "Magic Function Attmt. Prompt"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        TestUtility: Codeunit "SLS Test Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        MagicFunctionLbl: Label 'magic_function';
        ExtractInformationFromCsvFunctionLbl: Label 'extract_information_from_csv';

    [Test]
    procedure TestHandlingOfCsvFileData()
    var
        AITTestContext: Codeunit "AIT Test Context";
    begin
        Initialize();
        ExecutePromptAndVerifyReturnedJson(AITTestContext.GetQuestion().ValueAsText());
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        IsInitialized := true;
    end;

    local procedure ExecutePromptAndVerifyReturnedJson(TestInput: Text)
    var
        AITTestContext: Codeunit "AIT Test Context";
        CallCompletionAnswerTxt: Text;
        UserQuery: Text;
    begin
        UserQuery := TestInput;
        TestUtility.RepeatAtMost3TimesToFetchCompletionForAttachment(CallCompletionAnswerTxt, UserQuery);
        AITTestContext.SetTestOutput(CallCompletionAnswerTxt);

        if not CallCompletionAnswerTxt.Contains(MagicFunctionLbl) then
            if CallCompletionAnswerTxt.Contains(ExtractInformationFromCsvFunctionLbl) then
                Assert.Fail(ExtractInformationFromCsvFunctionLbl + 'was called');
    end;
}
