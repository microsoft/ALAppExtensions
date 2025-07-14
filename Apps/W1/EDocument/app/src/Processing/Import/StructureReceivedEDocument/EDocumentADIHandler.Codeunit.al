// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Helpers;
using System.Utilities;
using System.Text;
using System.AI;
using System.AI.DocumentIntelligence;

codeunit 6174 "E-Document ADI Handler" implements IStructureReceivedEDocument, IStructuredFormatReader, IStructuredDataType
{
    Access = Internal;

    var
        EDocumentJsonHelper: Codeunit "EDocument Json Helper";
        StructuredData: Text;
        FileFormat: Enum "E-Doc. File Format";
        ReadIntoDraftImpl: Enum "E-Doc. Read into Draft";

    procedure StructureReceivedEDocument(EDocumentDataStorage: Record "E-Doc. Data Storage"): Interface IStructuredDataType
    var
        Base64Convert: Codeunit "Base64 Convert";
        AzureDocumentIntelligence: Codeunit "Azure Document Intelligence";
        CopilotCapability: Codeunit "Copilot Capability";
        FromTempBlob: Codeunit "Temp Blob";
        Instream: InStream;
        Data: Text;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"E-Document Analysis") then
            AzureDocumentIntelligence.RegisterCopilotCapability(Enum::"Copilot Capability"::"E-Document Analysis", Enum::"Copilot Availability"::Preview, '');

        AzureDocumentIntelligence.SetCopilotCapability(Enum::"Copilot Capability"::"E-Document Analysis");

        FromTempBlob := EDocumentDataStorage.GetTempBlob();
        FromTempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        Data := Base64Convert.ToBase64(InStream);
        StructuredData := AzureDocumentIntelligence.AnalyzeInvoice(Data);
        // If the call to ADI fails the system module will return an empty string, in such case we want to carry on with a blank draft
        if StructuredData = '' then begin
            FileFormat := "E-Doc. File Format"::Unspecified;
            ReadIntoDraftImpl := "E-Doc. Read into Draft"::"Blank Draft";
        end else begin
            FileFormat := "E-Doc. File Format"::JSON;
            ReadIntoDraftImpl := "E-Doc. Read into Draft"::ADI;
        end;
        exit(this);
    end;

    procedure GetFileFormat(): Enum "E-Doc. File Format"
    begin
        exit(this.FileFormat);
    end;

    procedure GetContent(): Text
    begin
        exit(this.StructuredData);
    end;

    procedure GetReadIntoDraftImpl(): Enum "E-Doc. Read into Draft"
    begin
        exit(this.ReadIntoDraftImpl);
    end;

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        TempEDocPurchaseHeader: Record "E-Document Purchase Header" temporary;
        TempEDocPurchaseLine: Record "E-Document Purchase Line" temporary;
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        // Clean up old data, since we are re-reading data
        EDocumentPurchaseHeader.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocumentPurchaseHeader.DeleteAll();
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocumentPurchaseLine.DeleteAll();

        ReadIntoBuffer(EDocument, TempBlob, TempEDocPurchaseHeader, TempEDocPurchaseLine);
        EDocumentPurchaseHeader := TempEDocPurchaseHeader;
        EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
        EDocumentPurchaseHeader.Insert();
        OnInsertedEDocumentPurchaseHeader(EDocument, EDocumentPurchaseHeader);

        if TempEDocPurchaseLine.FindSet() then begin
            repeat
                EDocumentPurchaseLine := TempEDocPurchaseLine;
                EDocumentPurchaseLine."E-Document Entry No." := EDocument."Entry No";
                EDocumentPurchaseLine."Line No." := EDocumentPurchaseLine.GetNextLineNo(EDocument."Entry No");
                EDocumentPurchaseLine.Insert();
            until TempEDocPurchaseLine.Next() = 0;

            OnInsertedEDocumentPurchaseLines(EDocument, EDocumentPurchaseHeader, EDocumentPurchaseLine);
        end;

        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    local procedure ReadIntoBuffer(
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        var TempEDocPurchaseHeader: Record "E-Document Purchase Header" temporary;
        var TempEDocPurchaseLine: Record "E-Document Purchase Line" temporary)
    var
        InStream: InStream;
        SourceJsonObject: JsonObject;
        BlobAsText: Text;
    begin
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(BlobAsText);
        SourceJsonObject.ReadFrom(BlobAsText);

        PopulateEDocumentPurchaseHeader(EDocumentJsonHelper.GetHeaderFields(SourceJsonObject), TempEDocPurchaseHeader);
        PopulateEDocumentPurchaseLines(EDocumentJsonHelper.GetLinesArray(SourceJsonObject), EDocument."Entry No", TempEDocPurchaseLine);
        TempEDocPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    var
        TempEDocPurchaseHeader: Record "E-Document Purchase Header" temporary;
        TempEDocPurchaseLine: Record "E-Document Purchase Line" temporary;
        EDocReadablePurchaseDoc: Page "E-Doc. Readable Purchase Doc.";
    begin
        ReadIntoBuffer(EDocument, TempBlob, TempEDocPurchaseHeader, TempEDocPurchaseLine);
        EDocReadablePurchaseDoc.SetBuffer(TempEDocPurchaseHeader, TempEDocPurchaseLine);
        EDocReadablePurchaseDoc.Run();
    end;

    local procedure PopulateEDocumentPurchaseLines(ItemsArray: JsonArray; EDocumentEntryNo: Integer; var TempEDocPurchaseLine: Record "E-Document Purchase Line" temporary)
    var
        JsonTokenTemp, ItemToken : JsonToken;
        ItemObject, LineObject : JsonObject;
        LineNumber: Integer;
    begin
        TempEDocPurchaseLine.DeleteAll();

        for LineNumber := 0 to ItemsArray.Count() do begin
            if not ItemsArray.Get(LineNumber, ItemToken) then
                continue;
            Clear(TempEDocPurchaseLine);
            TempEDocPurchaseLine.Validate("E-Document Entry No.", EDocumentEntryNo);
            TempEDocPurchaseLine."Line No." := 10000 + (LineNumber * 10000);
            ItemObject := ItemToken.AsObject();
            ItemObject.Get('fields', JsonTokenTemp);
            LineObject := JsonTokenTemp.AsObject();
            PopulateEDocumentPurchaseLine(LineObject, TempEDocPurchaseLine);
            TempEDocPurchaseLine.Insert();
        end;
    end;

#pragma warning disable AA0139 // false positive: overflow handled by EDocumentJsonHelper.EDocumentJsonHelper.SetStringValueInField
    local procedure PopulateEDocumentPurchaseHeader(FieldsJsonObject: JsonObject; var TempEDocPurchaseHeader: Record "E-Document Purchase Header" temporary)
    begin
        EDocumentJsonHelper.SetStringValueInField('customerName', MaxStrLen(TempEDocPurchaseHeader."Customer Company Name"), FieldsJsonObject, TempEDocPurchaseHeader."Customer Company Name");
        EDocumentJsonHelper.SetStringValueInField('customerId', MaxStrLen(TempEDocPurchaseHeader."Customer Company Id"), FieldsJsonObject, TempEDocPurchaseHeader."Customer Company Id");
        EDocumentJsonHelper.SetStringValueInField('purchaseOrder', MaxStrLen(TempEDocPurchaseHeader."Purchase Order No."), FieldsJsonObject, TempEDocPurchaseHeader."Purchase Order No.");
        EDocumentJsonHelper.SetStringValueInField('invoiceId', MaxStrLen(TempEDocPurchaseHeader."Sales Invoice No."), FieldsJsonObject, TempEDocPurchaseHeader."Sales Invoice No.");
        EDocumentJsonHelper.SetDateValueInField('dueDate', FieldsJsonObject, TempEDocPurchaseHeader."Due Date");
        EDocumentJsonHelper.SetDateValueInField('invoiceDate', FieldsJsonObject, TempEDocPurchaseHeader."Document Date");
        EDocumentJsonHelper.SetStringValueInField('vendorName', MaxStrLen(TempEDocPurchaseHeader."Vendor Company Name"), FieldsJsonObject, TempEDocPurchaseHeader."Vendor Company Name");
        EDocumentJsonHelper.SetStringValueInField('vendorAddress', MaxStrLen(TempEDocPurchaseHeader."Vendor Address"), FieldsJsonObject, TempEDocPurchaseHeader."Vendor Address");
        EDocumentJsonHelper.SetStringValueInField('vendorAddressRecipient', MaxStrLen(TempEDocPurchaseHeader."Vendor Address Recipient"), FieldsJsonObject, TempEDocPurchaseHeader."Vendor Address Recipient");
        EDocumentJsonHelper.SetStringValueInField('customerAddress', MaxStrLen(TempEDocPurchaseHeader."Customer Address"), FieldsJsonObject, TempEDocPurchaseHeader."Customer Address");
        EDocumentJsonHelper.SetStringValueInField('customerAddressRecipient', MaxStrLen(TempEDocPurchaseHeader."Customer Address Recipient"), FieldsJsonObject, TempEDocPurchaseHeader."Customer Address Recipient");
        EDocumentJsonHelper.SetStringValueInField('billingAddress', MaxStrLen(TempEDocPurchaseHeader."Billing Address"), FieldsJsonObject, TempEDocPurchaseHeader."Billing Address");
        EDocumentJsonHelper.SetStringValueInField('billingAddressRecipient', MaxStrLen(TempEDocPurchaseHeader."Billing Address Recipient"), FieldsJsonObject, TempEDocPurchaseHeader."Billing Address Recipient");
        EDocumentJsonHelper.SetStringValueInField('shippingAddress', MaxStrLen(TempEDocPurchaseHeader."Shipping Address"), FieldsJsonObject, TempEDocPurchaseHeader."Shipping Address");
        EDocumentJsonHelper.SetStringValueInField('shippingAddressRecipient', MaxStrLen(TempEDocPurchaseHeader."Shipping Address Recipient"), FieldsJsonObject, TempEDocPurchaseHeader."Shipping Address Recipient");
        EDocumentJsonHelper.SetCurrencyValueInField('subTotal', FieldsJsonObject, TempEDocPurchaseHeader."Sub Total", TempEDocPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('totalTax', FieldsJsonObject, TempEDocPurchaseHeader."Total VAT", TempEDocPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('invoiceTotal', FieldsJsonObject, TempEDocPurchaseHeader.Total, TempEDocPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('amountDue', FieldsJsonObject, TempEDocPurchaseHeader."Amount Due", TempEDocPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('previousUnpaidBalance', FieldsJsonObject, TempEDocPurchaseHeader."Previous Unpaid Balance", TempEDocPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetStringValueInField('remittanceAddress', MaxStrLen(TempEDocPurchaseHeader."Remittance Address"), FieldsJsonObject, TempEDocPurchaseHeader."Remittance Address");
        EDocumentJsonHelper.SetStringValueInField('remittanceAddressRecipient', MaxStrLen(TempEDocPurchaseHeader."Remittance Address Recipient"), FieldsJsonObject, TempEDocPurchaseHeader."Remittance Address Recipient");
        EDocumentJsonHelper.SetDateValueInField('serviceStartDate', FieldsJsonObject, TempEDocPurchaseHeader."Service Start Date");
        EDocumentJsonHelper.SetDateValueInField('serviceEndDate', FieldsJsonObject, TempEDocPurchaseHeader."Service End Date");
        EDocumentJsonHelper.SetStringValueInField('vendorTaxId', MaxStrLen(TempEDocPurchaseHeader."Vendor VAT Id"), FieldsJsonObject, TempEDocPurchaseHeader."Vendor VAT Id");
        EDocumentJsonHelper.SetStringValueInField('customerTaxId', MaxStrLen(TempEDocPurchaseHeader."Customer VAT Id"), FieldsJsonObject, TempEDocPurchaseHeader."Customer VAT Id");
        EDocumentJsonHelper.SetStringValueInField('paymentTerm', MaxStrLen(TempEDocPurchaseHeader."Payment Terms"), FieldsJsonObject, TempEDocPurchaseHeader."Payment Terms");
    end;

    local procedure PopulateEDocumentPurchaseLine(FieldsJsonObject: JsonObject; var TempEDocPurchaseLine: Record "E-Document Purchase Line" temporary)
    begin
        EDocumentJsonHelper.SetCurrencyValueInField('amount', FieldsJsonObject, TempEDocPurchaseLine."Sub Total", TempEDocPurchaseLine."Currency Code");
        EDocumentJsonHelper.SetStringValueInField('description', MaxStrLen(TempEDocPurchaseLine.Description), FieldsJsonObject, TempEDocPurchaseLine.Description);
        EDocumentJsonHelper.SetCurrencyValueInField('unitPrice', FieldsJsonObject, TempEDocPurchaseLine."Unit Price", TempEDocPurchaseLine."Currency Code");
        EDocumentJsonHelper.SetNumberValueInField('quantity', FieldsJsonObject, TempEDocPurchaseLine.Quantity);
        if TempEDocPurchaseLine.Quantity <= 0 then
            TempEDocPurchaseLine.Quantity := 1;
        EDocumentJsonHelper.SetStringValueInField('productCode', MaxStrLen(TempEDocPurchaseLine."Product Code"), FieldsJsonObject, TempEDocPurchaseLine."Product Code");
        EDocumentJsonHelper.SetStringValueInField('unit', MaxStrLen(TempEDocPurchaseLine."Unit of Measure"), FieldsJsonObject, TempEDocPurchaseLine."Unit of Measure");
        EDocumentJsonHelper.SetDateValueInField('date', FieldsJsonObject, TempEDocPurchaseLine.Date);
        EDocumentJsonHelper.SetCurrencyValueInField('tax', FieldsJsonObject, TempEDocPurchaseLine."VAT Rate", TempEDocPurchaseLine."Currency Code");
        TempEDocPurchaseLine."Total Discount" := (TempEDocPurchaseLine."Unit Price" * TempEDocPurchaseLine.Quantity) - TempEDocPurchaseLine."Sub Total";
    end;
#pragma warning restore AA0139

    [InternalEvent(false, false)]
    local procedure OnInsertedEDocumentPurchaseHeader(EDocument: Record "E-Document"; EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnInsertedEDocumentPurchaseLines(EDocument: Record "E-Document"; EDocumentPurchaseHeader: Record "E-Document Purchase Header"; EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
    end;
}