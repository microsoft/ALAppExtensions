namespace Microsoft.Sales.Document.Test;

using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;

codeunit 133516 "SLS Prompt Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        TestUtility: Codeunit "SLS Test Utility";
        IsInitialized: Boolean;
        JsonPropValueErr: Label '"%1" property is incorrect', Comment = '%1 = Json property name';
        JsonPropIsMissingErr: Label 'Expected data is missing. Expected Json property and value: "%1": %2', Comment = '%1 = Json property name, %2 = Json property value';

    [Test]
    procedure TestSLSCopilotResponse()
    var
        AITestContext: Codeunit "AIT Test Context";
        ExpectedItemProps: Codeunit "Test Input Json";
        ExpectedDocProps: Codeunit "Test Input Json";
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: Text;
        ExpectedSearchItemExists: Boolean;
        ExpectedResultsExist: Boolean;
    begin
        Initialize();

        // [GIVEN] A question from the dataset and expected properties
        ExpectedItemProps := AITestContext.GetInput().Element('Expected').ElementExists('search_item', ExpectedSearchItemExists);
        ExpectedDocProps := AITestContext.GetInput().Element('Expected').ElementExists('results', ExpectedResultsExist);

        // [WHEN] Sales lines are suggested
        TestUtil.RepeatAtMost3TimesToFetchCompletion(CallCompletionAnswerTxt, AITestContext.GetQuestion().ValueAsText());

        // [THEN] Copilot response is based on the expected properties
        AITestContext.SetTestOutput(CallCompletionAnswerTxt); // Log the response

        if ExpectedSearchItemExists then
            CheckSearchItemJSONContent(CallCompletionAnswerTxt, ExpectedItemProps);

        if ExpectedResultsExist then
            CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, ExpectedDocProps);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        IsInitialized := true;
    end;

    local procedure CheckSearchItemJSONContent(CompletionAnswerTxt: Text; ExpectedItemProps: Codeunit "Test Input Json")
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionArgument: JsonToken;
        FunctionArgumentObject: JsonObject;
        ItemResults: JsonToken;
        ItemResultsArray: JsonArray;
        JsonItem: JsonToken;
        i: Integer;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerTxt);

        AssertFunctionName(Function, 'search_items_with_filters');

        Function.AsObject().Get('arguments', FunctionArgument);
        FunctionArgumentObject.ReadFrom(FunctionArgument.AsValue().AsText());

        if FunctionArgumentObject.Get('search_items', ItemResults) then begin
            ItemResultsArray := ItemResults.AsArray();
            Assert.AreEqual(ExpectedItemProps.GetElementCount(), ItemResultsArray.Count(), '"search_items" count is not correct');
        end
        else begin
            Assert.IsTrue(ExpectedItemProps.GetElementCount() = 0, '"search_items" should be empty');
            exit;
        end;

        for i := 0 to ExpectedItemProps.GetElementCount() - 1 do begin
            ItemResultsArray.Get(i, JsonItem); // No need to check if the index is valid as the count is already checked

            ValidateJsonPropertyInArray(ExpectedItemProps, i, JsonItem, 'split_name_terms');
            ValidateJsonPropertyInArray(ExpectedItemProps, i, JsonItem, 'origin_name');
            ValidateJsonPropertyInArray(ExpectedItemProps, i, JsonItem, 'quantity');
            ValidateJsonPropertyInArray(ExpectedItemProps, i, JsonItem, 'features');
            ValidateJsonPropertyInArray(ExpectedItemProps, i, JsonItem, 'common_synonyms_of_name');
            ValidateJsonPropertyInArray(ExpectedItemProps, i, JsonItem, 'unit_of_measure');
        end;
    end;

    local procedure CheckDocumentLookupJSONContent(CompletionAnswerTxt: Text; ExpectedDocProps: Codeunit "Test Input Json")
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionArgument: JsonToken;
        FunctionArgumentObject: JsonObject;
        ResultsTok: JsonToken;
        ResultsArray: JsonArray;
        JsonItem: JsonToken;
        i: Integer;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerTxt);

        AssertFunctionName(Function, 'search_items_with_filters');

        Function.AsObject().Get('arguments', FunctionArgument);
        FunctionArgumentObject.ReadFrom(FunctionArgument.AsValue().AsText());

        if FunctionArgumentObject.Get('results', ResultsTok) then begin
            ResultsArray := ResultsTok.AsArray();
            Assert.AreEqual(ExpectedDocProps.GetElementCount(), ResultsArray.Count(), 'ResultsArray count is not correct');
        end
        else begin
            Assert.IsTrue(ExpectedDocProps.GetElementCount() = 0, '"results" should be empty');
            exit;
        end;

        for i := 0 to ExpectedDocProps.GetElementCount() - 1 do begin // Considering the order of the elements in the response is same as the order in the expected element properties
            ResultsArray.Get(i, JsonItem); // No need to check if the index is valid as the count is already checked

            // Check expected properties only
            ValidateJsonPropertyInArray(ExpectedDocProps, i, JsonItem, 'document_type');
            ValidateJsonPropertyInArray(ExpectedDocProps, i, JsonItem, 'document_number');
            ValidateJsonPropertyInArray(ExpectedDocProps, i, JsonItem, 'start_date');
            ValidateJsonPropertyInArray(ExpectedDocProps, i, JsonItem, 'end_date');
        end;
    end;

    local procedure ValidateJsonPropertyInArray(ExpectedPropsArray: Codeunit "Test Input Json"; Index: Integer; ActualJsonToken: JsonToken; PropertyName: Text)
    var
        ExpectedElement: Codeunit "Test Input Json";
        ElementExists: Boolean;
    begin
        ExpectedElement := ExpectedPropsArray.ElementAt(Index).ElementExists(PropertyName, ElementExists);
        if ElementExists then
            ValidateJsonProperty(ExpectedElement, ActualJsonToken, PropertyName);
    end;

    local procedure ValidateJsonProperty(ExpectedElement: Codeunit "Test Input Json"; ActualJsonToken: JsonToken; PropertyName: Text);
    var
        IsPropertyFound: Boolean;
        ActualToken: JsonToken;
    begin
        IsPropertyFound := ActualJsonToken.AsObject().Get(PropertyName, ActualToken);
        case PropertyName of
            'split_name_terms':
                if IsPropertyFound then
                    AssertJsonArraysContentAreSame(ExpectedElement.AsJsonToken().AsArray(), ActualToken.AsArray(), PropertyName)
                else
                    AssertMissingJsonArrayPropertyIsEmpty(ExpectedElement, PropertyName);
            'features': // Not checking 'common_synonyms_of_name' as it is not consistent in the response
                if IsPropertyFound then
                    AssertExpectedArrayContainsActualArrayElements(ExpectedElement.AsJsonToken().AsArray(), ActualToken.AsArray(), PropertyName)
                else
                    AssertMissingJsonArrayPropertyIsEmpty(ExpectedElement, PropertyName);

            'origin_name', 'unit_of_measure', 'document_type', 'document_number':
                if IsPropertyFound then
                    Assert.AreEqual(ExpectedElement.ValueAsText().ToLower(), ActualToken.AsValue().AsText().ToLower(), StrSubstNo(JsonPropValueErr, PropertyName))
                else
                    Assert.AreEqual('', ExpectedElement.ValueAsText(), StrSubstNo(JsonPropIsMissingErr, PropertyName, '"' + ExpectedElement.ValueAsText() + '"'));

            'quantity':
                if IsPropertyFound then
                    Assert.AreEqual(ExpectedElement.ValueAsDecimal(), ActualToken.AsValue().AsDecimal(), StrSubstNo(JsonPropValueErr, PropertyName))
                else
                    Assert.AreEqual(0, ExpectedElement.ValueAsDecimal(), StrSubstNo(JsonPropIsMissingErr, PropertyName, ExpectedElement.ValueAsDecimal()));

            'start_date', 'end_date':
                if IsPropertyFound then
                    Assert.AreEqual(GetDateFromText(ExpectedElement.ValueAsText()), ActualToken.AsValue().AsText(), StrSubstNo(JsonPropValueErr, PropertyName))
                else
                    Assert.AreEqual('', GetDateFromText(ExpectedElement.ValueAsText()), StrSubstNo(JsonPropIsMissingErr, PropertyName, '"' + ExpectedElement.ValueAsText() + '"'));
        end;
    end;

    local procedure AssertMissingJsonArrayPropertyIsEmpty(ExpectedElement: Codeunit "Test Input Json"; PropertyName: Text);
    begin
        Assert.AreEqual(0, ExpectedElement.AsJsonToken().AsArray().Count(), StrSubstNo(JsonPropIsMissingErr, PropertyName, '[' + ConvertJsonArrayToText(ExpectedElement.AsJsonToken().AsArray(), ',') + ']'));
    end;

    local procedure AssertFunctionName(FunctionToken: JsonToken; ExpectedName: Text)
    var
        FunctionName: JsonToken;
    begin
        FunctionToken.AsObject().Get('name', FunctionName);
        Assert.AreEqual(ExpectedName, FunctionName.AsValue().AsText(), 'Function name is incorrect.');
    end;

    local procedure AssertJsonArraysContentAreSame(ExpectedArray: JsonArray; ActualArray: JsonArray; JsonArrayPropertyName: Text)
    var
        i: Integer;
        TempToken: JsonToken;
        ListOfJsonTokens: List of [Text];
        JsonArrayLengthMismatchErr: Label 'Array length for "%1" is incorrect.\Expected Array: [%2] \Actual Array: [%3]', Comment = '%1 = Json array property name, %2 = Expected array values, %3 = Actual array values';
        JsonTokenNotFoundErr: Label '"%1" not found in the json array property "%2": [%3]', Comment = '%1 = Json token, %2 = Json array property name, %3 = Actual json array';
    begin
        Assert.AreEqual(ExpectedArray.Count(), ActualArray.Count(), StrSubstNo(JsonArrayLengthMismatchErr, JsonArrayPropertyName, ConvertJsonArrayToText(ExpectedArray, ','), ConvertJsonArrayToText(ActualArray, ',')));

        // Copy JsonArray tokens to a list
        foreach TempToken in ActualArray do
            ListOfJsonTokens.Add(TempToken.AsValue().AsText().ToLower());

        // Check if all expected tokens are present in the actual array
        for i := 0 to ExpectedArray.Count() - 1 do begin
            ExpectedArray.Get(i, TempToken);
            Assert.IsTrue(ListOfJsonTokens.Contains(TempToken.AsValue().AsText().ToLower()), StrSubstNo(JsonTokenNotFoundErr, TempToken.AsValue().AsText(), JsonArrayPropertyName, ConvertJsonArrayToText(ActualArray, ',')));
        end;
    end;

    // Lenient check
    local procedure AssertExpectedArrayContainsActualArrayElements(ExpectedJsonArray: JsonArray; ActualJsonArray: JsonArray; JsonArrayPropertyName: Text) // Lenient check
    var
        i: Integer;
        TempToken: JsonToken;
        ExpectedJsonArrayAsText: Text;
        JsonTokenNotFoundErr: Label '"%1" not found in the json array property "%2": [%3]', Comment = '%1 = Json token, %2 = Json array property name, %3 = json array values';
    begin
        if ActualJsonArray.Count() = 0 then
            exit;

        // Copy JsonArray tokens to a list
        ExpectedJsonArray.WriteTo(ExpectedJsonArrayAsText);

        // Check if all the actual tokens are present in the expected array
        for i := 0 to ActualJsonArray.Count() - 1 do begin
            ActualJsonArray.Get(i, TempToken);
            Assert.IsTrue(ExpectedJsonArrayAsText.ToLower().Contains(TempToken.AsValue().AsText().ToLower()), StrSubstNo(JsonTokenNotFoundErr, TempToken.AsValue().AsText(), JsonArrayPropertyName, ExpectedJsonArrayAsText));
        end;
    end;

    local procedure ConvertJsonArrayToText(JsonArray: JsonArray; Delimiter: Char): Text
    var
        StringBuilder: TextBuilder;
        JsonToken: JsonToken;
        ValueText: Text;
        Index: Integer;
    begin
        for Index := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(Index, JsonToken);
            ValueText := JsonToken.AsValue().AsText();
            StringBuilder.Append(ValueText);
            if Index < JsonArray.Count - 1 then
                StringBuilder.Append(Delimiter);
        end;
        exit(StringBuilder.ToText());
    end;

    local procedure GetDateFromText(DateDescription: Text) Result: Text
    begin
        case DateDescription of
            'LAST_YEAR':
                Result := Format(Format(CalcDate('<CY-1Y>', Today()), 0, '<year4>-<month,2>-<day,2>'));
            'START_LAST_YEAR':
                Result := Format(Format(CalcDate('<-CY-1Y>', Today()), 0, '<year4>-<month,2>-<day,2>'));
            'LAST_WEEK':
                Result := FORMAT(Today() - 7, 0, '<Year4>-<Month,2>-<Day,2>');
            'YESTERDAY':
                Result := FORMAT(Today() - 1, 0, '<Year4>-<Month,2>-<Day,2>');
            'TODAY':
                Result := FORMAT(Today(), 0, '<Year4>-<Month,2>-<Day,2>');
            'LAST_FEB_01':
                if (System.Date2DMY(Today(), 2) < 3) then
                    Result := Format(System.Date2DMY(Today(), 3) - 1) + '-02-01'
                else
                    Result := Format(System.Date2DMY(Today(), 3)) + '-02-01';
            'LAST_CHRISTMAS':
                Result := Format(System.Date2DMY(Today(), 3) - 1) + '-12-24'
            else
                Result := DateDescription;
        end;
    end;
}