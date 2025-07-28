namespace Microsoft.Sales.Document.Test;
using System.TestTools.AITestToolkit;

codeunit 133520 "Extract Info. from csv Prompt"
{
    Subtype = Test;
    TestType = Uncategorized;
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
        ExecutePromptAndVerifyReturnedJson(AITTestContext.GetInput().ToText(), ExtractInformationFromCsvFunctionLbl);
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
        ExpectedColumnDelimitor: Text;
        ExpectedProductInfoColumnIndex: List of [Integer];
        ExpectedQuantityColumnIndex: Integer;
        ExpectedUoMColumnIndex: Integer;
        ExpectedCsVHeaderExists: Boolean;
        ExpectedColumnInfo: List of [List of [Text]];
    begin
        ReadDatasetInput(TestInput, UserQuery, ExpectedColumnDelimitor, ExpectedProductInfoColumnIndex, ExpectedQuantityColumnIndex, ExpectedUoMColumnIndex, ExpectedCsVHeaderExists, ExpectedColumnInfo);
        TestUtility.RepeatAtMost3TimesToFetchCompletionForAttachment(CallCompletionAnswerTxt, UserQuery);
        AITTestContext.SetTestOutput(CallCompletionAnswerTxt);
        CheckReturnedJSONContent(CallCompletionAnswerTxt, ExtractInformationFromCsvFunction, ExpectedColumnDelimitor, ExpectedProductInfoColumnIndex, ExpectedQuantityColumnIndex, ExpectedUoMColumnIndex, ExpectedCsVHeaderExists, ExpectedColumnInfo);
    end;

    local procedure ReadDatasetInput(TestInput: Text; var UserQuery: Text; var ExpectedColumnDelimitor: Text; var ExpectedProductInfoColumnIndex: List of [Integer]; var ExpectedQuantityColumnIndex: Integer; var ExpectedUoMColumnIndex: Integer; var ExpectedCsVHeaderExists: Boolean; var ExpectedColumnInfo: List of [List of [Text]])
    var
        JsonContent: JsonObject;
        JsonToken, JsonToken1 : JsonToken;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        UserQueryKeyLbl: Label 'question', Locked = true;
        ExpectedColumnIdentifierKeyLbl: Label 'ExpectedColumnIdentifier', Locked = true;
        ExpectedProductInfoColumnIndexKeyLbl: Label 'ExpectedProductInfoColumnIndex', Locked = true;
        ExpectedQuantityColumnIndexKeyLbl: Label 'ExpectedQuantityColumnIndex', Locked = true;
        ExpectedUoMColumnIndexKeyLbl: Label 'ExpectedUoMColumnIndex', Locked = true;
        ExpectedCsvHasHeaderKeyLbl: Label 'ExpectedCsvHasHeader', Locked = true;
        ExpectedCsvColumnsKeyLbl: Label 'ExpectedCsvColumns', Locked = true;
        ColumnNameKeyLbl: Label 'ExpectedColumnName', Locked = true;
        ColumnTypeKeyLbl: Label 'ExpectedColumnType', Locked = true;
        ColumnInfo: List of [Text];

    begin
        JsonContent.ReadFrom(TestInput);

        JsonContent.Get(UserQueryKeyLbl, JsonToken);
        UserQuery := JsonToken.AsValue().AsText();

        if JsonContent.Get(ExpectedColumnIdentifierKeyLbl, JsonToken) then
            ExpectedColumnDelimitor := JsonToken.AsValue().AsText();

        if JsonContent.Get(ExpectedProductInfoColumnIndexKeyLbl, JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                ExpectedProductInfoColumnIndex.Add(JsonToken.AsValue().AsInteger());
        end;

        if JsonContent.Get(ExpectedQuantityColumnIndexKeyLbl, JsonToken) then
            ExpectedQuantityColumnIndex := JsonToken.AsValue().AsInteger();

        if JsonContent.Get(ExpectedUoMColumnIndexKeyLbl, JsonToken) then
            ExpectedUoMColumnIndex := JsonToken.AsValue().AsInteger();

        if JsonContent.Get(ExpectedCsvHasHeaderKeyLbl, JsonToken) then
            ExpectedCsVHeaderExists := JsonToken.AsValue().AsBoolean();

        if JsonContent.Get(ExpectedCsvColumnsKeyLbl, JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do begin
                Clear(ColumnInfo);
                JsonObject := JsonToken.AsObject();
                JsonObject.Get(ColumnNameKeyLbl, JsonToken1);
                ColumnInfo.Add(JsonToken1.AsValue().AsText());
                JsonObject.Get(ColumnTypeKeyLbl, JsonToken1);
                ColumnInfo.Add(JsonToken1.AsValue().AsText());
                ExpectedColumnInfo.Add(ColumnInfo);
            end;
        end;
    end;

    local procedure CheckReturnedJSONContent(CompletionAnswerTxt: Text; ExpectedFunctionName: Text; ExpectedColumnDelimitor: Text; ExpectedProductInfoColumnIndex: List of [Integer]; ExpectedQuantityColumnIndex: Integer; ExpectedUoMColumnIndex: Integer; ExpectedCsVHeaderExists: Boolean; ExpectedColumnInfo: List of [List of [Text]])
    var
        Utility: Codeunit "SLS Test Utility";
        Function: JsonToken;
        FunctionName: JsonToken;
        FunctionArgument: JsonToken;
        FunctionArgumentObject: JsonObject;
        JsonToken, JsonToken1 : JsonToken;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        IntegerArray: List of [Integer];
        ColumnIndex: Integer;
        ColumnInfo: List of [Text];
        ActualInteger: Integer;
    begin
        Function := Utility.GetFunctionToken(CompletionAnswerTxt);
        Function.AsObject().Get('name', FunctionName);
        Assert.AreEqual(ExpectedFunctionName, FunctionName.AsValue().AsText(), 'Function name is not correct');
        Function.AsObject().Get('arguments', FunctionArgument);

        FunctionArgumentObject.ReadFrom(FunctionArgument.AsValue().AsText());

        /************ Check the column delimiter ************/
        if FunctionArgumentObject.Get('column_delimiter', JsonToken) then
            Assert.AreEqual(ExpectedColumnDelimitor, JsonToken.AsValue().AsText(), 'Column delimiter is not correct')
        else
            Assert.AreEqual('', ExpectedColumnDelimitor, 'Column delimiter is not correct');

        /************ Check the product information column information ************/
        if FunctionArgumentObject.Get('product_info_column_index', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                IntegerArray.Add(JsonToken.AsValue().AsInteger());

            Assert.AreEqual(IntegerArray.Count, ExpectedProductInfoColumnIndex.Count, 'Number of Product info column index is not correct');

            foreach ColumnIndex in IntegerArray do
                Assert.IsTrue(ExpectedProductInfoColumnIndex.Contains(ColumnIndex), 'Product info column index is not correct. Column index: ' + Format(ColumnIndex) + ' is not in the expected list');
        end else
            Assert.AreEqual(0, ExpectedProductInfoColumnIndex.Count, 'No. of Product info column index is 0');

        /************ Check the quantity and UoM column information ************/
        if FunctionArgumentObject.Get('quantity_column_index', JsonToken) then begin
            Clear(ActualInteger);
            if TryGetJsonTokenAsInteger(JsonToken, ActualInteger) then;
            Assert.AreEqual(ExpectedQuantityColumnIndex, ActualInteger, 'Quantity column index is not correct')
        end else
            Assert.AreEqual(0, ExpectedQuantityColumnIndex, 'Quantity column index is not correct');

        if FunctionArgumentObject.Get('unit_of_measure_column_index', JsonToken) then begin
            Clear(ActualInteger);
            if TryGetJsonTokenAsInteger(JsonToken, ActualInteger) then;
            Assert.AreEqual(ExpectedUoMColumnIndex, ActualInteger, 'UoM column index is not correct')
        end else
            Assert.AreEqual(0, ExpectedUoMColumnIndex, 'UoM column index is not correct');

        /************ Check the csv has header information ************/
        if FunctionArgumentObject.Get('csv_has_header_row', JsonToken) then
            Assert.AreEqual(ExpectedCsVHeaderExists, JsonToken.AsValue().AsBoolean(), 'CSV header exists is not correct')
        else
            Assert.AreEqual(false, ExpectedCsVHeaderExists, 'CSV header exists is not correct');

        /************ Check the column information ************/
        if FunctionArgumentObject.Get('csv_columns', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            Assert.AreEqual(ExpectedColumnInfo.Count, JsonArray.Count, 'Column info is not correct');

            foreach JsonToken in JsonArray do begin
                JsonObject := JsonToken.AsObject();
                Clear(ColumnInfo);
                JsonObject.Get('column_name', JsonToken1);
                ColumnInfo.Add(JsonToken1.AsValue().AsText());
                JsonObject.Get('column_type', JsonToken1);
                ColumnInfo.Add(JsonToken1.AsValue().AsText());
                Assert.IsTrue(ContainsList(ExpectedColumnInfo, ColumnInfo), 'Column info is not correct. Column Name: ' + ColumnInfo.Get(1) + ' and Column Type: ' + ColumnInfo.Get(2) + ' is not in the expected list');
            end;
        end else
            Assert.AreEqual(0, ExpectedColumnInfo.Count, 'Column info is not correct');
    end;

    local procedure ContainsList(ListOfLists: List of [List of [Text]]; TargetList: List of [Text]): Boolean
    var
        ListOfText: List of [Text];
    begin
        foreach ListOfText in ListOfLists do
            if AreListsEqual(ListOfText, TargetList) then
                exit(true);
        exit(false);
    end;

    local procedure AreListsEqual(List1: List of [Text]; List2: List of [Text]): Boolean
    var
        i: Integer;
    begin
        if List1.Count() <> List2.Count() then
            exit(false);

        for i := 1 to List1.Count do
            if not List1.Contains(List2.Get(i)) then
                exit(false);
        exit(true);
    end;

    [TryFunction]
    local procedure TryGetJsonTokenAsInteger(JsonToken: JsonToken; var TokenAsInteger: Integer)
    begin
        TokenAsInteger := JsonToken.AsValue().AsInteger();
    end;
}
