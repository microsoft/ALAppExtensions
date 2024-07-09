namespace Microsoft.Sales.Document.Test;

using Microsoft.Sales.Document;
using Microsoft.Sales.Document.Attachment;
codeunit 139785 "SLS Test Utility"
{
    Access = Internal;

    // JSON parsing functions
    local procedure GetFunctionToken(AnswerJson: JsonObject): JsonToken;
    var
        ToolsArrayToken: JsonToken;
        ToolType: JsonToken;
        Tool: JsonToken;
        Function: JsonToken;
    begin
        if AnswerJson.Get('tool_calls', ToolsArrayToken) then
            foreach Tool in ToolsArrayToken.AsArray() do begin
                Tool.AsObject().Get('type', ToolType);
                if ToolType.AsValue().asText() = 'function' then begin
                    Tool.AsObject().Get('function', Function);
                    exit(Function);
                end;
            end
    end;

    internal procedure GetFunctionToken(AnswerText: Text) result: JsonToken;
    var
        AnswerJson: JsonObject;
    begin
        AnswerJson.ReadFrom(AnswerText);
        exit(GetFunctionToken(AnswerJson));
    end;

    // Completion functions
    [TryFunction]
    local procedure TryGetCompletion(var CompletionAnswerTxt: Text; UserSearchTest: Text)
    var
        TempSalesLineAISuggestions: Record "Sales Line AI Suggestions" temporary;
        SalesHeader: Record "Sales Header";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        Prompt: Codeunit "SLS Prompts";
        IntentSystemPrompt: SecretText;
        SearchStyle: Enum "Search Style";
    begin
        IntentSystemPrompt := Prompt.GetSLSSystemPrompt();
        CompletionAnswerTxt := SalesLineAISuggestionImpl.AICall(IntentSystemPrompt, UserSearchTest, SearchStyle, SalesHeader, TempSalesLineAISuggestions);
    end;

    [TryFunction]
    local procedure TryGetCompletionForAttachment(var CompletionAnswerTxt: Text; UserSearchTest: Text)
    var
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        LookupItemsFromCsvFunction: Codeunit "Lookup Items From Csv Function";
        Prompt: Codeunit "SLS Prompts";
        IntentSystemPrompt: SecretText;
    begin
        IntentSystemPrompt := Prompt.GetAttachmentSystemPrompt();
        SalesLineAISuggestionImpl.AICall(IntentSystemPrompt, UserSearchTest, LookupItemsFromCsvFunction, CompletionAnswerTxt);
    end;

    internal procedure RepeatAtMost3TimesToFetchCompletion(var CompletionAnswerTxt: Text; UserSearchTest: Text)
    var
        i: Integer;
    begin
        while not TryGetCompletion(CompletionAnswerTxt, UserSearchTest) do begin
            Sleep(100);
            i += 1;
            if i > 3 then
                Error('Cannot get completion answer with 3 tries');
        end;
    end;

    procedure RepeatAtMost3TimesToFetchCompletionForAttachment(var CompletionAnswerTxt: Text; UserSearchTest: Text)
    var
        i: Integer;
    begin
        while not TryGetCompletionForAttachment(CompletionAnswerTxt, UserSearchTest) do begin
            Sleep(100);
            i += 1;
            if i > 3 then
                Error('Cannot get completion answer with 3 tries');
        end;
    end;

    internal procedure GetFunctionName(CompletionAnswerText: Text): Text
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionName: JsonToken;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerText);
        Function.AsObject().Get('name', FunctionName);
        exit(FunctionName.AsValue().AsText());
    end;

    internal procedure CheckMagicFunction(CompletionAnswerTxt: Text);
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionName: JsonToken;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerTxt);
        Function.AsObject().Get('name', FunctionName);
        Assert.AreEqual('magic_function', FunctionName.AsValue().AsText(), 'Function name is not correct');
    end;

    var
        Assert: Codeunit Assert;
}