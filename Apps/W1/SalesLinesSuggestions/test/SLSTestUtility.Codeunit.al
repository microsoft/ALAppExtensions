namespace Microsoft.Sales.Document.Test;

using Microsoft.Sales.Document;
using System.TestLibraries.Utilities;
codeunit 139785 "SLS Test Utility"
{

    // JSON parsing functions
    procedure GetFunctionToken(AnswerJson: JsonObject): JsonToken;
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

    procedure GetFunctionToken(AnswerText: Text) result: JsonToken;
    var
        AnswerJson: JsonObject;
    begin
        AnswerJson.ReadFrom(AnswerText);
        exit(GetFunctionToken(AnswerJson));
    end;

    procedure ReadJson(data: Text) result: JsonObject;
    begin
        result.ReadFrom(data);
    end;


    // Completion functions
    [TryFunction]
    local procedure TryGetCompletion(var CompletionAnswerTxt: SecretText; UserSearchTest: Text)
    var
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        Prompt: Codeunit "SLS Prompts";
        IntentSystemPrompt: SecretText;
    begin
        IntentSystemPrompt := Prompt.GetSLSSystemPrompt();
        CompletionAnswerTxt := SalesLineAISuggestionImpl.AICall(IntentSystemPrompt, UserSearchTest);
    end;

    procedure RepeatAtMost100TimesToFetchCompletion(var CompletionAnswerTxt: SecretText; UserSearchTest: Text)
    var
        i: Integer;
    begin
        while not TryGetCompletion(CompletionAnswerTxt, UserSearchTest) do begin
            Sleep(100);
            i += 1;
            if i > 100 then
                error('Cannot get completion answer with 100 tries');
        end;
    end;

    [NonDebuggable]
    procedure GetClearCompletionAnswer(CompletionAnswerTxt: SecretText) result: Text
    begin
        exit(CompletionAnswerTxt.Unwrap());
    end;

    procedure CheckSearchItemJSONContent(CompletionAnswerTxt: SecretText; ItemCount: Integer; LibraryVariableStorage: Codeunit "Library - Variable Storage")
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionName: JsonToken;
        FunctionArgument: JsonToken;
        FunctionArgumentObject: JsonObject;
        ItemResults: JsonToken;
        ItemResultsArray: JsonArray;
        JsonItem: JsonToken;
        TempToken: JsonToken;
    begin
        Function := Utility.GetFunctionToken(GetClearCompletionAnswer(CompletionAnswerTxt));
        Function.AsObject().Get('name', FunctionName);
        Assert.AreEqual('search_items', FunctionName.AsValue().AsText(), 'Function name is not search_items.');
        Function.AsObject().Get('arguments', FunctionArgument);

        FunctionArgumentObject := Utility.ReadJson(FunctionArgument.AsValue().AsText());
        FunctionArgumentObject.Get('results', ItemResults);
        // ItemResults.AsObject().Get('items', ItemResults);
        ItemResultsArray := ItemResults.AsArray();
        Assert.AreEqual(ItemCount, ItemResultsArray.Count(), 'ItemResultsArray count is not correct');

        foreach JsonItem in ItemResultsArray do begin
            JsonItem.AsObject().Get('name', TempToken);
            Assert.AreEqual(LibraryVariableStorage.DequeueText().ToLower(), TempToken.AsValue().AsText().ToLower(), 'Item name is not correct');
            JsonItem.AsObject().Get('origin_name', TempToken);
            Assert.AreEqual(LibraryVariableStorage.DequeueText().ToLower(), TempToken.AsValue().AsText().ToLower(), 'Item origin name is not correct');
            JsonItem.AsObject().Get('quantity', TempToken);
            Assert.AreEqual(LibraryVariableStorage.DequeueText(), TempToken.AsValue().AsText(), 'Item quantity is not correct');
            JsonItem.AsObject().Get('features', TempToken);
            CheckFeatures(TempToken, LibraryVariableStorage);
        end;
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure CheckFeatures(FeaturesJSONToken: JsonToken; LibraryVariableStorage: Codeunit "Library - Variable Storage")
    var
        FeatureArray: JsonArray;
        TempToken: JsonToken;
        FeatureInOneLine: Text;
    begin
        FeatureArray := FeaturesJSONToken.AsArray();
        if FeatureArray.Count() = 0 then
            exit;
        FeatureInOneLine := LibraryVariableStorage.DequeueText().ToLower();
        foreach TempToken in FeatureArray do
            Assert.IsSubstring(FeatureInOneLine, TempToken.AsValue().AsText().ToLower());
    end;

    [NonDebuggable]
    procedure CheckMagicFunction(CompletionAnswerTxt: SecretText);
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionName: JsonToken;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerTxt.Unwrap());
        Function.AsObject().Get('name', FunctionName);
        Assert.AreEqual('magic_function', FunctionName.AsValue().AsText(), 'Function name is not correct');
    end;

    [NonDebuggable]
    procedure CheckDocumentLookupJSONContent(CompletionAnswerTxt: SecretText; ExpectedFunctionName: Text; ExpectedDocumentType: Text; ExpectedDocumentNo: Text; ExpectedStartDate: Text; ExpectedEndDate: Text)
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionName: JsonToken;
        FunctionArgument: JsonToken;
        FunctionArgumentObject: JsonObject;
        ItemResults: JsonToken;
        ItemResultsArray: JsonArray;
        JsonItem: JsonToken;
        DocNoToken: JsonToken;
        DocumentTypeToken: JsonToken;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerTxt.Unwrap());
        Function.AsObject().Get('name', FunctionName);
        Assert.AreEqual(ExpectedFunctionName, FunctionName.AsValue().AsText(), 'Function name is not correct');
        Function.AsObject().Get('arguments', FunctionArgument);

        FunctionArgumentObject := Utility.ReadJson(FunctionArgument.AsValue().AsText());
        FunctionArgumentObject.Get('results', ItemResults);
        ItemResultsArray := ItemResults.AsArray();

        ItemResultsArray.Get(0, JsonItem);
        JsonItem.AsObject().Get('document_type', DocumentTypeToken);
        Assert.AreEqual(ExpectedDocumentType, DocumentTypeToken.AsValue().AsText(), 'Document type is not correct');
        JsonItem.AsObject().Get('document_no', DocNoToken);
        Assert.AreEqual(ExpectedDocumentNo, DocNoToken.AsValue().AsText(), 'Document no is not correct');
        JsonItem.AsObject().Get('start_date', DocumentTypeToken);
        Assert.AreEqual(ExpectedStartDate, DocumentTypeToken.AsValue().AsText(), 'Start date is not correct');
        JsonItem.AsObject().Get('end_date', DocumentTypeToken);
        Assert.AreEqual(ExpectedEndDate, DocumentTypeToken.AsValue().AsText(), 'End date is not correct');
    end;


    var
        Assert: Codeunit Assert;


}