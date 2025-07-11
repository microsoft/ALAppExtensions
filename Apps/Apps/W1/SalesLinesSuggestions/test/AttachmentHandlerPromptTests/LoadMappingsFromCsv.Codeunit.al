namespace Microsoft.Sales.Document.Test;
using System.TestTools.AITestToolkit;
using Microsoft.Sales.Document;
using Microsoft.Sales.Document.Attachment;
using System.Utilities;

codeunit 133521 "Load Mappings from csv"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        TestUtility: Codeunit "SLS Test Utility";
        IsInitialized: Boolean;

    [Test]
    procedure TestHandlingOfCsvFileData()
    var
        AITTestContext: Codeunit "AIT Test Context";
    begin
        Initialize();
        ExecutePromptAndVerifyReturnedJson(AITTestContext.GetInput().ToText());
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
        SalesHeader: Record "Sales Header";
        SalesLineFromAttachment: Codeunit "Sales Line From Attachment";
        TempBlob: Codeunit "Temp Blob";
        SalesLineFromAttachmentPage: TestPage "Sales Line From Attachment";
        Mode: PromptMode;
        FileName: Text;
        UserQuery: Text;
        ExpectedProductInfoColumnIndex: List of [Integer];
        ExpectedQuantityColumnIndex: Integer;
        ExpectedUoMColumnIndex: Integer;
        ExpectedColumnInfo: List of [List of [Text]];
        Outstream: OutStream;
    begin
        ReadDatasetInput(TestInput, UserQuery, ExpectedProductInfoColumnIndex, ExpectedQuantityColumnIndex, ExpectedUoMColumnIndex, ExpectedColumnInfo);
        TempBlob.CreateOutStream(Outstream);
        Outstream.WriteText(UserQuery);
        FileName := 'Test.csv';
        SalesLineFromAttachmentPage.Trap();
        SalesLineFromAttachment.AttachAndSuggest(SalesHeader, Mode::Prompt, TempBlob, FileName);
        ValidateSalesLineAttachmentPage(SalesLineFromAttachmentPage, ExpectedProductInfoColumnIndex, ExpectedQuantityColumnIndex, ExpectedUoMColumnIndex, ExpectedColumnInfo);
    end;

    local procedure ReadDatasetInput(TestInput: Text; var UserQuery: Text; var ExpectedProductInfoColumnIndex: List of [Integer]; var ExpectedQuantityColumnIndex: Integer; var ExpectedUoMColumnIndex: Integer; var ExpectedColumnInfo: List of [List of [Text]])
    var
        JsonContent: JsonObject;
        JsonToken, JsonToken1 : JsonToken;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        UserQueryKeyLbl: Label 'question', Locked = true;
        ExpectedProductInfoColumnIndexKeyLbl: Label 'ExpectedProductInfoColumnIndex', Locked = true;
        ExpectedQuantityColumnIndexKeyLbl: Label 'ExpectedQuantityColumnIndex', Locked = true;
        ExpectedUoMColumnIndexKeyLbl: Label 'ExpectedUoMColumnIndex', Locked = true;
        ExpectedCsvColumnsKeyLbl: Label 'ExpectedCsvColumns', Locked = true;
        ColumnNameKeyLbl: Label 'ExpectedColumnName', Locked = true;
        ColumnTypeKeyLbl: Label 'ExpectedColumnType', Locked = true;
        ColumnInfo: List of [Text];

    begin
        JsonContent.ReadFrom(TestInput);

        JsonContent.Get(UserQueryKeyLbl, JsonToken);
        UserQuery := JsonToken.AsValue().AsText();

        if JsonContent.Get(ExpectedProductInfoColumnIndexKeyLbl, JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                ExpectedProductInfoColumnIndex.Add(JsonToken.AsValue().AsInteger());
        end;

        if JsonContent.Get(ExpectedQuantityColumnIndexKeyLbl, JsonToken) then
            ExpectedQuantityColumnIndex := JsonToken.AsValue().AsInteger();

        if JsonContent.Get(ExpectedUoMColumnIndexKeyLbl, JsonToken) then
            ExpectedUoMColumnIndex := JsonToken.AsValue().AsInteger();

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

    local procedure ValidateSalesLineAttachmentPage(var SalesLineFromAttachmentPage: TestPage "Sales Line From Attachment"; ExpectedProductInfoColumnIndex: List of [Integer]; ExpectedQuantityColumnIndex: Integer; ExpectedUoMColumnIndex: Integer; ExpectedColumnInfo: List of [List of [Text]])
    var
        RowIndex: Integer;
        ExpectedColumnName: Text;
        ExpectedColumnType: Enum "Column Type";
    begin
        RowIndex := 1;
        if SalesLineFromAttachmentPage.AttachmentMappingPart.First() then
            repeat
                ExpectedColumnName := ExpectedColumnInfo.Get(RowIndex).Get(1);
                Evaluate(ExpectedColumnType, ExpectedColumnInfo.Get(RowIndex).Get(2));

                SalesLineFromAttachmentPage.AttachmentMappingPart.PreviewColumnName.AssertEquals(ExpectedColumnName);
                SalesLineFromAttachmentPage.AttachmentMappingPart.ColumnType.AssertEquals(ExpectedColumnType);

                if ExpectedProductInfoColumnIndex.Contains(RowIndex) then
                    SalesLineFromAttachmentPage.AttachmentMappingPart.ColumnAction.AssertEquals(Enum::"Column Action"::"Product Info.");

                if ExpectedQuantityColumnIndex = RowIndex then
                    SalesLineFromAttachmentPage.AttachmentMappingPart.ColumnAction.AssertEquals(Enum::"Column Action"::"Quantity Info.");

                if ExpectedUoMColumnIndex = RowIndex then
                    SalesLineFromAttachmentPage.AttachmentMappingPart.ColumnAction.AssertEquals(Enum::"Column Action"::"UoM Info.");

                RowIndex += 1;
            until SalesLineFromAttachmentPage.AttachmentMappingPart.Next() = false;
    end;
}