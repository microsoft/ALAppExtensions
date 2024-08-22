namespace Microsoft.Sales.Document.Test;
using System.TestTools.AITestToolkit;

codeunit 149821 "Magic Function Attmt. Prompt"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        MagicFunctionLbl: Label 'magic_function';

    [Test]
    procedure TestHandlingOfCsvFileData()
    var
        AITTestContext: Codeunit "AIT Test Context";
    begin
        ExecutePromptAndVerifyReturnedJson(AITTestContext.GetInput().ToText(), MagicFunctionLbl);
    end;

    internal procedure ExecutePromptAndVerifyReturnedJson(TestInput: Text; ExtractInformationFromCsvFunction: Text)
    var
        AITTestContext: Codeunit "AIT Test Context";
        TestUtility: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: Text;
        JsonContent: JsonObject;
        JsonToken: JsonToken;
        UserQueryKeyLbl: Label 'user_query', Locked = true;
        UserQuery: Text;
    begin
        JsonContent.ReadFrom(TestInput);
        JsonContent.Get(UserQueryKeyLbl, JsonToken);
        UserQuery := JsonToken.AsValue().AsText();
        TestUtility.RepeatAtMost3TimesToFetchCompletionForAttachment(CallCompletionAnswerTxt, UserQuery);
        AITTestContext.SetTestOutput(CallCompletionAnswerTxt);
        TestUtility.CheckMagicFunction(CallCompletionAnswerTxt);
    end;
}