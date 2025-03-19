// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
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

        TempBlob.CreateInStream(InStream);
        InStream.Read(BlobAsText);
        SourceJsonObject.ReadFrom(BlobAsText);

        PopulateEDocumentPurchaseHeader(GetHeaderFields(SourceJsonObject), EDocumentPurchaseHeader);
        EDocumentPurchaseHeader.Modify();

        InsertEDocumentPurchaseLines(GetLinesArray(SourceJsonObject), EDocumentPurchaseHeader."E-Document Entry No.");
        exit(Enum::"E-Doc. Structured Data Process"::"Purchase Document");
    end;

    local procedure InsertEDocumentPurchaseLines(ItemsArray: JsonArray; EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        JsonTokenTemp, ItemToken : JsonToken;
        ItemObject, LineObject : JsonObject;
    begin
        foreach ItemToken in ItemsArray do begin
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine."E-Document Entry No." := EDocumentEntryNo;
            ItemObject := ItemToken.AsObject();
            ItemObject.Get('fields', JsonTokenTemp);
            LineObject := JsonTokenTemp.AsObject();
            PopulateEDocumentPurchaseLine(LineObject, EDocumentPurchaseLine);
            EDocumentPurchaseLine.Insert();
        end;
    end;

#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
    local procedure PopulateEDocumentPurchaseHeader(FieldsJsonObject: JsonObject; var EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    begin
        SetStringValueInField('customerName', MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Company Name");
        SetStringValueInField('customerId', MaxStrLen(EDocumentPurchaseHeader."Customer Company Id"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Company Id");
        SetStringValueInField('purchaseOrder', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), FieldsJsonObject, EDocumentPurchaseHeader."Purchase Order No.");
        SetStringValueInField('invoiceId', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), FieldsJsonObject, EDocumentPurchaseHeader."Sales Invoice No.");
        SetDateValueInField('dueDate', FieldsJsonObject, EDocumentPurchaseHeader."Due Date");
        SetStringValueInField('vendorName', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor Company Name");
        SetStringValueInField('vendorAddress', MaxStrLen(EDocumentPurchaseHeader."Vendor Address"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor Address");
        SetStringValueInField('vendorAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Vendor Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor Address Recipient");
        SetStringValueInField('customerAddress', MaxStrLen(EDocumentPurchaseHeader."Customer Address"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Address");
        SetStringValueInField('customerAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Customer Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Customer Address Recipient");
        SetStringValueInField('billingAddress', MaxStrLen(EDocumentPurchaseHeader."Billing Address"), FieldsJsonObject, EDocumentPurchaseHeader."Billing Address");
        SetStringValueInField('billingAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Billing Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Billing Address Recipient");
        SetStringValueInField('shippingAddress', MaxStrLen(EDocumentPurchaseHeader."Shipping Address"), FieldsJsonObject, EDocumentPurchaseHeader."Shipping Address");
        SetStringValueInField('shippingAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Shipping Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Shipping Address Recipient");
        SetNumberValueInField('subTotal', FieldsJsonObject, EDocumentPurchaseHeader."Sub Total");
        SetNumberValueInField('totalTax', FieldsJsonObject, EDocumentPurchaseHeader."Total VAT");
        SetCurrencyValueInField('invoiceTotal', FieldsJsonObject, EDocumentPurchaseHeader.Total, EDocumentPurchaseHeader."Currency Code");
        SetNumberValueInField('amountDue', FieldsJsonObject, EDocumentPurchaseHeader."Amount Due");
        SetNumberValueInField('previousUnpaidBalance', FieldsJsonObject, EDocumentPurchaseHeader."Previous Unpaid Balance");
        SetStringValueInField('remittanceAddress', MaxStrLen(EDocumentPurchaseHeader."Remittance Address"), FieldsJsonObject, EDocumentPurchaseHeader."Remittance Address");
        SetStringValueInField('remittanceAddressRecipient', MaxStrLen(EDocumentPurchaseHeader."Remittance Address Recipient"), FieldsJsonObject, EDocumentPurchaseHeader."Remittance Address Recipient");
        SetDateValueInField('serviceStartDate', FieldsJsonObject, EDocumentPurchaseHeader."Service Start Date");
        SetDateValueInField('serviceEndDate', FieldsJsonObject, EDocumentPurchaseHeader."Service End Date");
        SetStringValueInField('vendorTaxId', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), FieldsJsonObject, EDocumentPurchaseHeader."Vendor VAT Id");
        SetStringValueInField('customerTaxId', MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"), FieldsJsonObject, EDocumentPurchaseHeader."Customer VAT Id");
        SetStringValueInField('paymentTerm', MaxStrLen(EDocumentPurchaseHeader."Payment Terms"), FieldsJsonObject, EDocumentPurchaseHeader."Payment Terms");
    end;

    local procedure PopulateEDocumentPurchaseLine(FieldsJsonObject: JsonObject; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        SetCurrencyValueInField('amount', FieldsJsonObject, EDocumentPurchaseLine."Sub Total", EDocumentPurchaseLine."Currency Code");
        SetStringValueInField('description', MaxStrLen(EDocumentPurchaseLine.Description), FieldsJsonObject, EDocumentPurchaseLine.Description);
        SetNumberValueInField('unitPrice', FieldsJsonObject, EDocumentPurchaseLine."Unit Price");
        SetNumberValueInField('quantity', FieldsJsonObject, EDocumentPurchaseLine.Quantity);
        SetStringValueInField('productCode', MaxStrLen(EDocumentPurchaseLine."Product Code"), FieldsJsonObject, EDocumentPurchaseLine."Product Code");
        SetStringValueInField('unit', MaxStrLen(EDocumentPurchaseLine."Unit of Measure"), FieldsJsonObject, EDocumentPurchaseLine."Unit of Measure");
        SetDateValueInField('date', FieldsJsonObject, EDocumentPurchaseLine.Date);
        SetNumberValueInField('tax', FieldsJsonObject, EDocumentPurchaseLine."VAT Rate");
    end;
#pragma warning restore AA0139

    local procedure GetHeaderFields(SourceJsonObject: JsonObject): JsonObject
    var
        JsonToken: JsonToken;
        ContentObject: JsonObject;
    begin
        ContentObject := GetInnerObject(SourceJsonObject);
        ContentObject.Get('fields', JsonToken);
        exit(JsonToken.AsObject());
    end;

    local procedure GetLinesArray(SourceJsonObject: JsonObject): JsonArray
    var
        JsonToken: JsonToken;
        ContentObject: JsonObject;
    begin
        ContentObject := GetInnerObject(SourceJsonObject);
        if ContentObject.Get('items', JsonToken) then
            exit(JsonToken.AsArray());
    end;

    local procedure GetInnerObject(SourceJsonObject: JsonObject): JsonObject
    var
        JsonToken: JsonToken;
        OutputsObject, InnerObject : JsonObject;
    begin
        SourceJsonObject.Get('outputs', JsonToken);
        OutputsObject := JsonToken.AsObject();
        OutputsObject.Get('1', JsonToken);
        InnerObject := JsonToken.AsObject();
        InnerObject.Get('result', JsonToken);
        exit(JsonToken.AsObject());
    end;

    internal procedure SetStringValueInField(FieldName: Text; MaxStrLen: Integer; var FieldsJsonObject: JsonObject; var Field: Text)
    var
        JsonToken: JsonToken;
    begin
        if not FieldsJsonObject.Contains(FieldName) then
            exit;
        // CAPI returns all parameters, even if they are null. This avoid errors when trying to access a null object
        FieldsJsonObject.Get(FieldName, JsonToken);
        if JsonToken.IsValue() then
            exit;
        Field := CopyStr(FieldsJsonObject.GetObject(FieldName).GetText('value_text'), 1, MaxStrLen);
    end;

    internal procedure SetDateValueInField(FieldName: Text; var FieldsJsonObject: JsonObject; var Field: Date)
    var
        DateParts: List of [Text];
        JsonToken: JsonToken;
        Year, Month, Day : Integer;
    begin
        if not FieldsJsonObject.Contains(FieldName) then
            exit;
        // CAPI returns all parameters, even if they are null. This avoid errors when trying to access a null object
        FieldsJsonObject.Get(FieldName, JsonToken);
        if JsonToken.IsValue() then
            exit;

        DateParts := FieldsJsonObject.GetObject(FieldName).GetText('value_date').Split('-');
        Evaluate(Day, DateParts.Get(3));
        Evaluate(Month, DateParts.Get(2));
        Evaluate(Year, DateParts.Get(1));
        Field := DMY2Date(Day, Month, Year);
    end;

    internal procedure SetCurrencyValueInField(FieldName: Text; var FieldsJsonObject: JsonObject; var Amount: Decimal; var CurrencyCode: Code[10])
    var
        JsonToken: JsonToken;
    begin
        if not FieldsJsonObject.Contains(FieldName) then
            exit;
        // CAPI returns all parameters, even if they are null. This avoid errors when trying to access a null object
        FieldsJsonObject.Get(FieldName, JsonToken);
        if JsonToken.IsValue() then
            exit;

        Amount := FieldsJsonObject.GetObject(FieldName).GetDecimal('value_number');
        // We are missing the currency code in the JSON provided by CAPI
        CurrencyCode := CopyStr(FieldsJsonObject.GetObject(FieldName).GetText('currency_symbol'), 1, MaxStrLen(CurrencyCode));
    end;

    internal procedure SetNumberValueInField(FieldName: Text; var FieldsJsonObject: JsonObject; var DecimalValue: Decimal)
    var
        JsonToken: JsonToken;
    begin
        if not FieldsJsonObject.Contains(FieldName) then
            exit;
        // CAPI returns all parameters, even if they are null. This avoid errors when trying to access a null object
        FieldsJsonObject.Get(FieldName, JsonToken);
        if JsonToken.IsValue() then
            exit;
        DecimalValue := FieldsJsonObject.GetObject(FieldName).GetDecimal('value_number');
    end;
}