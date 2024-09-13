namespace Microsoft.Sales.Document.Test;

using Microsoft.Sales.Document;
using Microsoft.Sales.Document.Attachment;
using System.AI;
using System.TestLibraries.AI;
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

    local procedure GetFunctionArray(AnswerJson: JsonObject) FunctionArray: JsonArray
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
                    FunctionArray.Add(Function);
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

    internal procedure GetFunctionArray(AnswerText: Text) result: JsonArray;
    var
        AnswerJson: JsonObject;
    begin
        AnswerJson.ReadFrom(AnswerText);
        exit(GetFunctionArray(AnswerJson));
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

    internal procedure RegisterCopilotCapability()
    begin
        CopilotTestLibrary.RegisterCopilotCapabilityWithAppId(Enum::"Copilot Capability"::"Sales Lines Suggestions", GetSalesLineSuggestionAppId());
    end;

    local procedure GetSalesLineSuggestionAppId(): Text
    begin
        exit('dd3f226b-40bf-4b3c-9988-9b1e0f74edd8');
    end;

    var
        Assert: Codeunit Assert;
        CopilotTestLibrary: Codeunit "Copilot Test Library";
}