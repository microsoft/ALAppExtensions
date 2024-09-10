namespace Microsoft.Sales.Document.Test;
using System.TestTools.AITestToolkit;
using Microsoft.Sales.Document;
using Microsoft.Sales.Document.Attachment;
using System.Utilities;

codeunit 149823 "Load Suggestions from csv"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestHandlingOfCsvFileData()
    var
        AITTestContext: Codeunit "AIT Test Context";
    begin
        ExecutePromptAndVerifyReturnedJson(AITTestContext.GetInput().ToText());
    end;

    internal procedure ExecutePromptAndVerifyReturnedJson(TestInput: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesLineFromAttachment: Codeunit "Sales Line From Attachment";
        TempBlob: Codeunit "Temp Blob";
        SalesLineFromAttachmentPage: TestPage "Sales Line From Attachment";
        Mode: PromptMode;
        FileName: Text;
        UserQuery: Text;
        ExpectedProducts: List of [Text];
        ExpectedQuantitys: List of [Decimal];
        ExpectedUoMs: List of [Text];
        Outstream: OutStream;
    begin
        ReadDatasetInput(TestInput, UserQuery, ExpectedProducts, ExpectedQuantitys, ExpectedUoMs);
        TempBlob.CreateOutStream(Outstream);
        Outstream.WriteText(UserQuery);
        FileName := 'Test.csv';
        SalesLineFromAttachmentPage.Trap();
        SalesLineFromAttachment.AttachAndSuggest(SalesHeader, Mode::Prompt, TempBlob, FileName);
        SalesLineFromAttachmentPage.Generate.Invoke();
        ValidateSalesLineAttachmentPage(SalesLineFromAttachmentPage, ExpectedProducts, ExpectedQuantitys, ExpectedUoMs);
    end;

    internal procedure ReadDatasetInput(TestInput: Text; var UserQuery: Text; var ExpectedProducts: List of [Text]; var ExpectedQuantitys: List of [Decimal]; var ExpectedUoMs: List of [Text])
    var
        JsonContent: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        UserQueryKeyLbl: Label 'user_query', Locked = true;
        ExpectedProductsKeyLbl: Label 'ExpectedItemNos', Locked = true;
        ExpectedQuantitysKeyLbl: Label 'ExpectedQuantitys', Locked = true;
        ExpectedUoMsKeyLbl: Label 'ExpectedUoMs', Locked = true;
    begin
        JsonContent.ReadFrom(TestInput);

        JsonContent.Get(UserQueryKeyLbl, JsonToken);
        UserQuery := JsonToken.AsValue().AsText();

        if JsonContent.Get(ExpectedProductsKeyLbl, JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                ExpectedProducts.Add(JsonToken.AsValue().AsText());
        end;

        if JsonContent.Get(ExpectedQuantitysKeyLbl, JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                ExpectedQuantitys.Add(JsonToken.AsValue().AsDecimal());
        end;

        if JsonContent.Get(ExpectedUoMsKeyLbl, JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                ExpectedUoMs.Add(JsonToken.AsValue().AsText());
        end;
    end;

    procedure ValidateSalesLineAttachmentPage(var SalesLineFromAttachmentPage: TestPage "Sales Line From Attachment"; ExpectedProducts: List of [Text]; ExpectedQuantitys: List of [Decimal]; ExpectedUoMs: List of [Text])
    var
        RowIndex: Integer;
    begin
        RowIndex := 1;
        if SalesLineFromAttachmentPage.SalesLinesSub.First() then
            repeat
                SalesLineFromAttachmentPage.SalesLinesSub."No.".AssertEquals(ExpectedProducts.Get(RowIndex));
                SalesLineFromAttachmentPage.SalesLinesSub.Quantity.AssertEquals(ExpectedQuantitys.Get(RowIndex));
                SalesLineFromAttachmentPage.SalesLinesSub."Unit of Measure Code".AssertEquals(ExpectedUoMs.Get(RowIndex));
                RowIndex += 1;
            until SalesLineFromAttachmentPage.SalesLinesSub.Next() = false;
    end;
}