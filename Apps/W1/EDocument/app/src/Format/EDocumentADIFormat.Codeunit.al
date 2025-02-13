namespace Microsoft.EServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using System.Utilities;

codeunit 6174 "E-Document ADI Format" implements IStructuredFormatReader
{

    Access = Internal;

    procedure Read(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Structured Data Process"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        InStream: InStream;
        Json: Text;
        Token, Token2, Token3 : JsonToken;
        OutputsObject: JsonObject;
        InnerObject, JsonObject : JsonObject;
        ResultObject2, FieldsObject : JsonObject;
        ItemsObjects: JsonArray;
        Count: Integer;
    begin
        if not EDocumentPurchaseHeader.Get(EDocument."Entry No") then begin
            EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
            EDocumentPurchaseHeader.Insert();
        end;

        TempBlob.CreateInStream(InStream);
        InStream.Read(Json);
        JsonObject.ReadFrom(Json);
        JsonObject.Get('outputs', Token);
        OutputsObject := Token.AsObject();
        OutputsObject.Get('1', Token);
        InnerObject := Token.AsObject();
        InnerObject.Get('result', Token);
        ResultObject2 := Token.AsObject();
        ResultObject2.Get('fields', Token);
        FieldsObject := Token.AsObject();
        ResultObject2.Get('items', Token);
        ItemsObjects := Token.AsArray();

        // Extract the dueDate
        if FieldsObject.Get('dueDate', Token) then
            if Token.IsObject() then
                if Token.AsObject().Get('value_date', Token) then
                    Evaluate(EDocumentPurchaseHeader."Due Date", Token.AsValue().AsText());

        // Extract the invoiceDate
        if FieldsObject.Get('invoiceDate', Token) then
            if Token.IsObject() then
                if Token.AsObject().Get('value_date', Token) then
                    Evaluate(EDocumentPurchaseHeader."Invoice Date", Token.AsValue().AsText());

        // Extract the invoiceId
        if FieldsObject.Get('invoiceId', Token) then
            if Token.IsObject() then
                if Token.AsObject().Get('value_text', Token) then
                    Evaluate(EDocumentPurchaseHeader."Sales Invoice No.", Token.AsValue().AsText());

        // Extract the Total Amount  
        if FieldsObject.Get('invoiceTotal', Token) then
            if Token.IsObject() then
                if Token.AsObject().Get('value_number', Token) then
                    EDocumentPurchaseHeader.Total := Token.AsValue().AsDecimal();

        // Extract the Total Amount  
        if FieldsObject.Get('totalTax', Token) then
            if Token.IsObject() then
                if Token.AsObject().Get('value_number', Token) then
                    EDocumentPurchaseHeader."Total Tax" := EDocument."Amount Incl. VAT" - Token.AsValue().AsDecimal();

        // Extract the Vendor Name
        if FieldsObject.Get('vendorName', Token) then
            if Token.IsObject() then
                if Token.AsObject().Get('value_text', Token) then
                    EDocumentPurchaseHeader."Vendor Name" := Token.AsValue().AsText();
        // Extract the VAT No 
        if FieldsObject.Get('vendorTaxId', Token) then
            if Token.IsObject() then
                if Token.AsObject().Get('value_text', Token2) then
                    EDocumentPurchaseHeader."Vendor Tax Id" := Token2.AsValue().AsText();

        EDocumentPurchaseHeader.Modify();
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";

        Count := 1;
        foreach Token in ItemsObjects do begin
            if Token.IsObject() then
                Token.AsObject().Get('fields', Token2);
            if Token2.IsObject() then begin
                if EDocumentPurchaseLine."E-Document Line Id" = 0 then begin
                    EDocumentPurchaseLine."E-Document Entry No." := EDocument."Entry No";
                    EDocumentPurchaseLine.Insert();
                end;

                if Token2.AsObject().Get('amount', Token3) then
                    if Token3.IsObject() then
                        if Token3.AsObject().Get('value_number', Token3) then
                            EDocumentPurchaseLine.Amount := Token3.AsValue().AsDecimal();

                if Token2.AsObject().Get('description', Token3) then
                    if Token3.IsObject() then
                        if Token3.AsObject().Get('value_text', Token3) then
                            EDocumentPurchaseLine.Description := Token3.AsValue().AsText();

                if Token2.AsObject().Get('unitPrice', Token3) then
                    if Token3.IsObject() then
                        if Token3.AsObject().Get('value_number', Token3) then
                            EDocumentPurchaseLine."Unit Price" := Token3.AsValue().AsDecimal();

                if Token2.AsObject().Get('quantity', Token3) then
                    if Token3.IsObject() then
                        if Token3.AsObject().Get('value_number', Token3) then
                            EDocumentPurchaseLine.Quantity := Token3.AsValue().AsDecimal();

                if Token2.AsObject().Get('productCode', Token3) then
                    if Token3.IsObject() then
                        if Token3.AsObject().Get('value_text', Token3) then
                            EDocumentPurchaseLine."Product Code" := Token3.AsValue().AsText();

                if Token2.AsObject().Get('unit', Token3) then
                    if Token3.IsObject() then
                        if Token3.AsObject().Get('value_text', Token3) then
                            EDocumentPurchaseLine."Unit Of Measure" := Token3.AsValue().AsText();
            end;

            EDocumentPurchaseLine.Modify();
            Clear(EDocumentPurchaseLine);
        end;

        exit(Enum::"E-Doc. Structured Data Process"::"Purchase Document");
    end;

}