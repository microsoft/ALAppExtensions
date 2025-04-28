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

codeunit 6174 "E-Document ADI Handler" implements IBlobType, IBlobToStructuredDataConverter, IStructuredFormatReader
{
    Access = Internal;

    procedure IsStructured(): Boolean
    begin
        exit(false);
    end;

    procedure HasConverter(): Boolean
    begin
        exit(true);
    end;

    procedure GetStructuredDataConverter(): Interface IBlobToStructuredDataConverter
    begin
        exit(this);
    end;

    procedure Convert(EDocument: Record "E-Document"; FromTempblob: Codeunit "Temp Blob"; FromType: Enum "E-Doc. Data Storage Blob Type"; var ConvertedType: Enum "E-Doc. Data Storage Blob Type") StructuredData: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        AzureDocumentIntelligence: Codeunit "Azure Document Intelligence";
        CopilotCapability: Codeunit "Copilot Capability";
        Instream: InStream;
        Data: Text;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"E-Document Analysis") then
            AzureDocumentIntelligence.RegisterCopilotCapability(Enum::"Copilot Capability"::"E-Document Analysis", Enum::"Copilot Availability"::Preview, '');

        AzureDocumentIntelligence.SetCopilotCapability(Enum::"Copilot Capability"::"E-Document Analysis");

        FromTempblob.CreateInStream(InStream, TextEncoding::UTF8);
        Data := Base64Convert.ToBase64(InStream);
        StructuredData := AzureDocumentIntelligence.AnalyzeInvoice(Data);
        ConvertedType := Enum::"E-Doc. Data Storage Blob Type"::JSON;
    end;

    procedure Read(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Structured Data Process"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        InStream: InStream;
        SourceJsonObject: JsonObject;
        BlobAsText: Text;
    begin
        if not EDocumentPurchaseHeader.Get(EDocument."Entry No") then begin
            EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
            EDocumentPurchaseHeader.Insert();
        end;

        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(BlobAsText);
        SourceJsonObject.ReadFrom(BlobAsText);

        PopulateEDocumentPurchaseHeader(EDocumentJsonHelper.GetHeaderFields(SourceJsonObject), EDocumentPurchaseHeader);
        EDocumentPurchaseHeader.Modify();

        InsertEDocumentPurchaseLines(EDocumentJsonHelper.GetLinesArray(SourceJsonObject), EDocumentPurchaseHeader."E-Document Entry No.");

        exit(Enum::"E-Doc. Structured Data Process"::"Purchase Document");
    end;

    local procedure InsertEDocumentPurchaseLines(ItemsArray: JsonArray; EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        JsonTokenTemp, ItemToken : JsonToken;
        ItemObject, LineObject : JsonObject;
        LineNumber: Integer;
    begin
        for LineNumber := 0 to ItemsArray.Count() do begin
            if not ItemsArray.Get(LineNumber, ItemToken) then
                continue;
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine.Validate("E-Document Entry No.", EDocumentEntryNo);
            EDocumentPurchaseLine."Line No." := ((LineNumber + 1) * 10000);
            ItemObject := ItemToken.AsObject();
            ItemObject.Get('fields', JsonTokenTemp);
            LineObject := JsonTokenTemp.AsObject();
            PopulateEDocumentPurchaseLine(LineObject, EDocumentPurchaseLine);
            EDocumentPurchaseLine.Insert();
        end;
    end;

#pragma warning disable AA0139 // false positive: overflow handled by EDocumentJsonHelper.EDocumentJsonHelper.SetStringValueInField
    local procedure PopulateEDocumentPurchaseHeader(FieldsJsonObject: JsonObject; var EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    begin
        EDocumentJsonHelper.SetStringValueInField('customerName', MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Company Name");
        EDocumentJsonHelper.SetStringValueInField('customerId', MaxStrLen(EDocumentPurchaseHeader."Customer Company Id"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Company Id");
        EDocumentJsonHelper.SetStringValueInField('purchaseOrder', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), FieldsJsonObject, EDocumentPurchaseHeader."Purchase Order No.");
        EDocumentJsonHelper.SetStringValueInField('invoiceId', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), FieldsJsonObject, EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentJsonHelper.SetDateValueInField('dueDate', FieldsJsonObject, EDocumentPurchaseHeader."Due Date");
        EDocumentJsonHelper.SetStringValueInField('vendorName', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor Company Name");
        EDocumentJsonHelper.SetStringValueInField('vendorAddress', MaxStrLen(EDocumentPurchaseHeader."Vendor Address"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor Address");
        EDocumentJsonHelper.SetStringValueInField('vendorAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Vendor Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor Address Recipient");
        EDocumentJsonHelper.SetStringValueInField('customerAddress', MaxStrLen(EDocumentPurchaseHeader."Customer Address"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Address");
        EDocumentJsonHelper.SetStringValueInField('customerAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Customer Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Address Recipient");
        EDocumentJsonHelper.SetStringValueInField('billingAddress', MaxStrLen(EDocumentPurchaseHeader."Billing Address"), FieldsJsonObject, EDocumentPurchaseHeader."Billing Address");
        EDocumentJsonHelper.SetStringValueInField('billingAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Billing Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Billing Address Recipient");
        EDocumentJsonHelper.SetStringValueInField('shippingAddress', MaxStrLen(EDocumentPurchaseHeader."Shipping Address"), FieldsJsonObject, EDocumentPurchaseHeader."Shipping Address");
        EDocumentJsonHelper.SetStringValueInField('shippingAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Shipping Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Shipping Address Recipient");
        EDocumentJsonHelper.SetCurrencyValueInField('subTotal', FieldsJsonObject, EDocumentPurchaseHeader."Sub Total", EDocumentPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('totalTax', FieldsJsonObject, EDocumentPurchaseHeader."Total VAT", EDocumentPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('invoiceTotal', FieldsJsonObject, EDocumentPurchaseHeader.Total, EDocumentPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('amountDue', FieldsJsonObject, EDocumentPurchaseHeader."Amount Due", EDocumentPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetCurrencyValueInField('previousUnpaidBalance', FieldsJsonObject, EDocumentPurchaseHeader."Previous Unpaid Balance", EDocumentPurchaseHeader."Currency Code");
        EDocumentJsonHelper.SetStringValueInField('remittanceAddress', MaxStrLen(EDocumentPurchaseHeader."Remittance Address"), FieldsJsonObject, EDocumentPurchaseHeader."Remittance Address");
        EDocumentJsonHelper.SetStringValueInField('remittanceAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Remittance Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Remittance Address Recipient");
        EDocumentJsonHelper.SetDateValueInField('serviceStartDate', FieldsJsonObject, EDocumentPurchaseHeader."Service Start Date");
        EDocumentJsonHelper.SetDateValueInField('serviceEndDate', FieldsJsonObject, EDocumentPurchaseHeader."Service End Date");
        EDocumentJsonHelper.SetStringValueInField('vendorTaxId', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor VAT Id");
        EDocumentJsonHelper.SetStringValueInField('customerTaxId', MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"), FieldsJsonObject, EDocumentPurchaseHeader."Customer VAT Id");
        EDocumentJsonHelper.SetStringValueInField('paymentTerm', MaxStrLen(EDocumentPurchaseHeader."Payment Terms"), FieldsJsonObject, EDocumentPurchaseHeader."Payment Terms");
    end;

    local procedure PopulateEDocumentPurchaseLine(FieldsJsonObject: JsonObject; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        EDocumentJsonHelper.SetCurrencyValueInField('amount', FieldsJsonObject, EDocumentPurchaseLine."Sub Total", EDocumentPurchaseLine."Currency Code");
        EDocumentJsonHelper.SetStringValueInField('description', MaxStrLen(EDocumentPurchaseLine.Description), FieldsJsonObject, EDocumentPurchaseLine.Description);
        EDocumentJsonHelper.SetCurrencyValueInField('unitPrice', FieldsJsonObject, EDocumentPurchaseLine."Unit Price", EDocumentPurchaseLine."Currency Code");
        EDocumentJsonHelper.SetNumberValueInField('quantity', FieldsJsonObject, EDocumentPurchaseLine.Quantity);
        EDocumentJsonHelper.SetStringValueInField('productCode', MaxStrLen(EDocumentPurchaseLine."Product Code"), FieldsJsonObject, EDocumentPurchaseLine."Product Code");
        EDocumentJsonHelper.SetStringValueInField('unit', MaxStrLen(EDocumentPurchaseLine."Unit of Measure"), FieldsJsonObject, EDocumentPurchaseLine."Unit of Measure");
        EDocumentJsonHelper.SetDateValueInField('date', FieldsJsonObject, EDocumentPurchaseLine.Date);
        EDocumentJsonHelper.SetCurrencyValueInField('tax', FieldsJsonObject, EDocumentPurchaseLine."VAT Rate", EDocumentPurchaseLine."Currency Code");
    end;
#pragma warning restore AA0139

    var
        EDocumentJsonHelper: Codeunit "EDocument Json Helper";
}