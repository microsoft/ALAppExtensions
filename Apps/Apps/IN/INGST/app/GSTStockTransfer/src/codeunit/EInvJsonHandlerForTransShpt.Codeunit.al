// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Sales;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using Microsoft.QRGeneration;
using System.Security.Encryption;
using System.Text;
using Microsoft.Finance.TaxBase;
using System.Utilities;

codeunit 18023 "E-InvJsonHandlerForTransShpt"
{
    trigger OnRun()
    begin
        Initialize();

        if IsInvoice then
            RunTransferShipment();

        if DocumentNo = '' then
            Error(DocumentNoBlankErr);

        ExportAsJson(DocumentNo);
    end;

    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        JObject: JsonObject;
        JsonArrayData: JsonArray;
        IsInvoice: Boolean;
        TransferToGSTReg: Code[20];
        TransferFromGSTINNo: Code[20];
        JsonText: Text;
        DocumentNo: Text[20];
        GSTLbl: Label 'GST', Locked = true;
        B2BLbl: Label 'B2B', Locked = true;
        CGSTLbl: Label 'CGST', Locked = true;
        SGSTLbl: label 'SGST', Locked = true;
        IGSTLbl: Label 'IGST', Locked = true;
        CESSLbl: Label 'CESS', Locked = true;
        IRNTxt: Label 'Irn', Locked = true;
        AcknowledgementNoTxt: Label 'AckNo', Locked = true;
        AcknowledgementDateTxt: Label 'AckDt', Locked = true;
        IRNHashErr: Label 'No matched IRN Hash %1 found to update.', Comment = '%1 = IRN Hash';
        SignedQRCodeTxt: Label 'SignedQRCode', Locked = true;
        DocumentNoBlankErr: Label 'E-Invoicing is not supported if document number is blank in the current document.', Locked = true;


    procedure SetTransferShipmentHeader(TransferShipmentHeaderBuff: Record "Transfer Shipment Header")
    begin
        TransferShipmentHeader := TransferShipmentHeaderBuff;
        IsInvoice := true;
    end;

    local procedure RunTransferShipment()
    begin
        if not IsInvoice then
            exit;

        DocumentNo := TransferShipmentHeader."No.";
        WriteJsonFileHeader();
        ReadTransactionDetails();
        ReadTransferDocumentDetails();
        ReadDocumentTransferFromDetails();
        ReadDocumentTransferToDetails();
        ReadItemListDetail();
        ReadDocumentValueDetails();
    end;

    local procedure Initialize()
    begin
        Clear(JObject);
        Clear(JsonArrayData);
        Clear(JsonText);
    end;

    local procedure WriteJsonFileHeader()
    begin
        JObject.Add('Version', '1.1');
        JsonArrayData.Add(JObject);
    end;

    local procedure ExportAsJson(FileName: Text[20])
    var
        TempBlob: Codeunit "Temp Blob";
        ToFile: Variant;
        InStream: InStream;
        OutStream: OutStream;
    begin
        clear(JsonArrayData);
        JsonArrayData.Add(JObject);
        JsonArrayData.WriteTo(JsonText);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(JsonText);
        ToFile := FileName + '.json';
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, 'e-Invoice', '', '', ToFile);
    end;

    procedure GenerateCanceledInvoice()
    begin
        Initialize();

        if IsInvoice then begin
            DocumentNo := TransferShipmentHeader."No.";
            WriteCancellationJSON(TransferShipmentHeader."IRN Hash", TransferShipmentHeader."Cancel Reason", Format(TransferShipmentHeader."Cancel Reason"))
        end;

        if DocumentNo <> '' then
            ExportAsJson(DocumentNo);
    end;

    local procedure WriteCancellationJSON(IRNHash: Text[64]; CancelReason: Enum "e-Invoice Cancel Reason"; CancelRemark: Text[100])
    var
        CancelJsonObject: JsonObject;
    begin
        WriteCancelJsonFileHeader();
        CancelJsonObject.Add('Canceldtls', '');
        CancelJsonObject.Add('IRN', IRNHash);
        CancelJsonObject.Add('CnlRsn', Format(CancelReason));
        CancelJsonObject.Add('CnlRem', CancelRemark);
        JsonArrayData.Add(CancelJsonObject);
        JObject.Add('ExpDtls', JsonArrayData);
    end;

    local procedure WriteCancelJsonFileHeader()
    begin
        JObject.Add('Version', '1.1');
        JsonArrayData.Add(JObject);
    end;

    local procedure ReadTransactionDetails()
    var
        NatureOfSupplyCategory: Text[7];
        SupplyType: Text[3];
        IgstOnIntra: Text[3];

    begin
        SupplyType := B2BLbl;
        NatureOfSupplyCategory := B2BLbl;
        if GetComponentCode() then
            IgstOnIntra := 'Y'
        else
            IgstOnIntra := 'N';

        WriteTransactionDetails(NatureOfSupplyCategory, 'N', '', IgstOnIntra);
    end;

    local procedure WriteTransactionDetails(
            SupplyCategory: Text[7];
            RegRev: Text[2];
            EcmGstin: Text[15];
            IgstOnIntra: Text[3])
    var
        JTranDetails: JsonObject;
    begin
        JTranDetails.Add('TaxSch', GSTLbl);
        JTranDetails.Add('SupTyp', SupplyCategory);
        JTranDetails.Add('RegRev', RegRev);

        if EcmGstin <> '' then
            JTranDetails.Add('EcmGstin', EcmGstin);

        JTranDetails.Add('IgstOnIntra', IgstOnIntra);
        JObject.Add('TranDtls', JTranDetails);
    end;

    local procedure ReadTransferDocumentDetails()
    var
        PostingDate: Text[10];
        OriginalDocNo: Text[16];
    begin
        Clear(JsonArrayData);

        if IsInvoice then
            PostingDate := Format(TransferShipmentHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');

        OriginalDocNo := CopyStr(GetReferenceInvoiceNo(DocumentNo), 1, 16);
        WriteDocumentHeaderDetails('INV', CopyStr(DocumentNo, 1, 16), PostingDate);
    end;

    local procedure WriteDocumentHeaderDetails(DocTyp: Text[20]; DocNo: Text[16]; PostingDate: Text[10])
    var
        JDocumentHeaderDetails: JsonObject;
    begin
        JDocumentHeaderDetails.Add('Typ', DocTyp);
        JDocumentHeaderDetails.Add('No', DocNo);
        JDocumentHeaderDetails.Add('Dt', PostingDate);
        //JDocumentHeaderDetails.Add('OrgInvNo', OriginalDocNo);
        JObject.Add('DocDtls', JDocumentHeaderDetails);
    end;

    local procedure GetReferenceInvoiceNo(DocNo: Code[20]) RefInvNo: Code[20]
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.LoadFields("Document No.");
        ReferenceInvoiceNo.SetRange("Document No.", DocNo);
        if ReferenceInvoiceNo.FindFirst() then
            RefInvNo := ReferenceInvoiceNo."Reference Invoice Nos."
        else
            RefInvNo := '';
    end;

    local procedure ReadDocumentTransferToDetails()
    var
        Location: Record Location;
        State: Record State;
        TransferToName: Text[100];
        TransferToName2: Text[50];
        TransferToAddress: Text[100];
        TransferToAddress2: Text[100];
        TransferToCity: Text[60];
        TransferToPostCode: Code[20];
        TransferToPhoneNo: Text[30];
        TransferToEmail: Text[80];
        StateCode: Code[10];
        PlaceOfSupply: Code[10];
    begin
        Clear(JsonArrayData);
        if IsInvoice then
            Location.Get(TransferShipmentHeader."Transfer-to Code");

        if State.Get(Location."State Code") then
            PlaceOfSupply := State."State Code (GST Reg. No.)";

        TransferToName := Location.Name;
        TransferToName2 := Location."Name 2";
        TransferToAddress := Location.Address;
        TransferToAddress2 := Location."Address 2";
        TransferToCity := Location.City;
        TransferToPostCode := Location."Post Code";
        TransferToPhoneNo := Location."Phone No.";
        TransferToEmail := Location."E-Mail";
        StateCode := Location."State Code";
        TransferToGSTReg := Location."GST Registration No.";
        WriteDocumentTransferToDetails(TransferToName, TransferToName2, TransferToAddress, TransferToAddress2, TransferToCity, TransferToPostCode, StateCode, TransferToPhoneNo, TransferToEmail, TransferToGSTReg, PlaceOfSupply);
    end;

    local procedure WriteDocumentTransferToDetails(TransferToName: Text[100];
        TransferToName2: Text[50];
        TransferToAddress: Text[100];
        TransferToAddress2: Text[100];
        TransferToCity: Text[60];
        TransferToPostCode: Code[20];
        StateCode: Code[10];
        TransferToPhoneNo: Text[30];
        TransferToEmail: Text[80];
        TransToGSTReg: code[20];
        PlaceofSupply: Code[10])
    var
        BuyerDetails: JsonObject;
    begin
        BuyerDetails.Add('Gstin', TransToGSTReg);
        BuyerDetails.Add('LglNm', TransferToName);
        BuyerDetails.Add('Pos', PlaceofSupply);
        if TransferToName2 <> '' then
            BuyerDetails.Add('TradeName', TransferToName2);

        BuyerDetails.Add('Addr1', TransferToAddress);

        if TransferToAddress2 <> '' then
            BuyerDetails.Add('Addr2', TransferToAddress2);

        BuyerDetails.Add('Loc', TransferToCity);
        BuyerDetails.Add('Pin', TransferToPostCode);
        BuyerDetails.Add('Stcd', StateCode);
        BuyerDetails.Add('PhoneNo', TransferToPhoneNo);
        BuyerDetails.Add('E-mail', TransferToEmail);
        JObject.Add('BuyerDtls', BuyerDetails);
    end;

    local procedure ReadDocumentTransferFromDetails()
    var
        Location: Record "Location";
        TransferFromName: Text[100];
        TransferFromName2: Text[100];
        TransferFromAddress: Text[100];
        TransferFromAddress2: Text[100];
        TransferFromCity: Text[60];
        TransferFromPostCode: Code[20];
        TransferFromPhoneNo: Text[30];
        TransferFromEmail: Text[80];
        StateCode: Code[10];
        TransferFromContact: Text[100];
    begin
        Clear(JsonArrayData);
        if IsInvoice then
            Location.Get(TransferShipmentHeader."Transfer-from Code");

        TransferFromName := Location.Name;
        TransferFromName2 := Location."Name 2";
        TransferFromAddress := Location.Address;
        TransferFromAddress2 := Location."Address 2";
        TransferFromCity := Location.City;
        TransferFromPostCode := Location."Post Code";
        TransferFromContact := TransferShipmentHeader."Transfer-from Contact";
        TransferFromGSTINNo := Location."GST Registration No.";
        TransferFromPhoneNo := Location."Phone No.";
        TransferFromEmail := Location."E-Mail";
        StateCode := Location."State Code";
        WriteDocumentTransferFromDetails(TransferFromName, TransferFromName2, TransferFromAddress, TransferFromAddress2, TransferFromCity, TransferFromPostCode, TransferFromGSTINNo, StateCode, TransferFromPhoneNo, TransferFromEmail);
    end;

    local procedure WriteDocumentTransferFromDetails(
        TransferFromName: Text[100];
        TransferFromName2: Text[100];
        TransferFromAddress: Text[100];
        TransferFromAddress2: Text[100];
        TransferFromCity: Text[60];
        TransferFromPostCode: Code[20];
        GSTINNo: Code[20];
        StateCode: Code[10];
        TransferFromPhoneNo: Text[30];
        TransferFromEmail: Text[80])
    var
        SellerDetails: JsonObject;
    begin
        SellerDetails.Add('Gstin', GSTINNo);
        SellerDetails.Add('LglNm', TransferFromName);

        if TransferFromName2 <> '' then
            SellerDetails.Add('TradeName', TransferFromName2);

        SellerDetails.Add('Addr1', TransferFromAddress);

        if TransferFromAddress2 <> '' then
            SellerDetails.Add('Addr2', TransferFromAddress2);

        SellerDetails.Add('Loc', TransferFromCity);
        SellerDetails.Add('Pin', TransferFromPostCode);
        SellerDetails.Add('Stcd', StateCode);

        if TransferFromPhoneNo <> '' then
            SellerDetails.Add('PhoneNo', TransferFromPhoneNo);

        if TransferFromEmail <> '' then
            SellerDetails.Add('E-mail', TransferFromEmail);

        JObject.Add('SellerDtls', SellerDetails);
    end;

    local procedure ReadItemListDetail()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        GstRate: Decimal;
        CGSTRate: Decimal;
        SGSTRate: Decimal;
        IGSTRate: Decimal;
        CessRate: Decimal;
        CesNonAdval: Decimal;
        CGSTValue: Decimal;
        SGSTValue: Decimal;
        IGSTValue: Decimal;
        CessValue: Decimal;
        IsService: Text[1];
        HSNCode: Code[20];
        Count: Integer;
    begin
        Clear(JsonArrayData);
        Count := 1;
        if IsInvoice then begin
            TransferShipmentLine.LoadFields("Document No.", "Line No.", "Item No.", Description, "Description 2", Quantity, "Unit of Measure Code", "Unit Price", Amount, "GST Assessable Value");
            TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
            TransferShipmentLine.SetFilter("Item No.", '<>%1', '');
            if TransferShipmentLine.FindSet() then
                repeat
                    IsService := 'N';
                    GetGSTValueForLine(TransferShipmentLine."Line No.", CGSTValue, SGSTValue, IGSTValue, CGSTRate, SGSTRate, IGSTRate, CessRate, CessValue, CesNonAdval);
                    if IGSTRate <> 0 then
                        GstRate := IGSTRate
                    else
                        GstRate := CGSTRate + SGSTRate;
                    HSNCode := TransferShipmentLine."HSN/SAC Code";

                    WriteItem(Format(Count), TransferShipmentLine.Description + TransferShipmentLine."Description 2", IsService, HSNCode, GstRate, TransferShipmentLine.Quantity, CopyStr(TransferShipmentLine."Unit of Measure Code", 1, 3), TransferShipmentLine."Unit Price", TransferShipmentLine.Amount, TransferShipmentLine."GST Assessable Value", CGSTValue, SGSTValue, IGSTValue, CessRate, CessValue, CesNonAdval, (TransferShipmentLine.Amount + TransferShipmentLine."GST Assessable Value" + CGSTValue + SGSTValue + IGSTValue + CessValue));
                    Count += 1;
                until TransferShipmentLine.Next() = 0;
        end;
        JObject.Add('ItemList', JsonArrayData);
    end;

    local procedure GetGSTValueForLine(DocumentLineNo: Integer;
        var CGSTLineAmount: Decimal;
        var SGSTLineAmount: Decimal;
        var IGSTLineAmount: Decimal;
        var CGSTRate: Decimal;
        var SGSTRate: Decimal;
        var IGSTRate: Decimal;
        var CessRate: Decimal;
        var CessValue: Decimal;
        var CessNonAdvanceAmount: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTDocumentType: Enum "GST Document Type";
        DGLETransactionType: Enum "Detail Ledger Transaction Type";
    begin
        CGSTLineAmount := 0;
        SGSTLineAmount := 0;
        IGSTLineAmount := 0;

        DetailedGSTLedgerEntry.LoadFields("Transaction Type", "Document Type", "Document No.", "GST Component Code", "GST Amount");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DGLETransactionType::Sales);
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Document Line No.", DocumentLineNo);
        DetailedGSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
        if DetailedGSTLedgerEntry.FindSet() then begin
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            CGSTLineAmount := Abs(DetailedGSTLedgerEntry."GST Amount");
            CGSTRate := DetailedGSTLedgerEntry."GST %";
        end;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
        if DetailedGSTLedgerEntry.FindSet() then begin
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            SGSTLineAmount := Abs(DetailedGSTLedgerEntry."GST Amount");
            SGSTRate := DetailedGSTLedgerEntry."GST %";
        end;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
        if DetailedGSTLedgerEntry.FindSet() then begin
            IGSTRate := DetailedGSTLedgerEntry."GST %";
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            IGSTLineAmount := Abs(DetailedGSTLedgerEntry."GST Amount");
        end;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", CESSLbl);
        if DetailedGSTLedgerEntry.FindSet() then begin
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            CessValue := Abs(DetailedGSTLedgerEntry."GST Amount");
            CessRate := DetailedGSTLedgerEntry."GST %";
        end;
        CessNonAdvanceAmount := 0;
    end;

    local procedure WriteItem(
        SlNo: Text[1];
        ProductName: Text[200];
        IsService: Text[1];
        HSNCode: Code[20];
        GstRate: Decimal;
        Quantity: Decimal;
        Unit: code[10];
        UnitPrice: Decimal;
        TotAmount: Decimal;
        AssessableAmount: Decimal;
        CGSTRate: Decimal;
        SGSTRate: Decimal;
        IGSTRate: Decimal;
        CESSRate: Decimal;
        CESSValue: Decimal;
        CessNonAdvanceAmount: Decimal;
        TotalItemValue: Decimal)
    var
        JItem: JsonObject;
    begin
        JItem.Add('SlNo', SlNo);
        JItem.Add('PrdDesc', ProductName);
        JItem.Add('IsServc', IsService);
        JItem.Add('HsnCd', HSNCode);
        JItem.Add('Qty', Quantity);
        JItem.Add('Unit', Unit);
        JItem.Add('UnitPrice', UnitPrice);
        JItem.Add('TotAmt', TotAmount);
        JItem.Add('AssAmt', AssessableAmount);
        JItem.Add('GstRt', GstRate);
        JItem.Add('CgstAmt', CGSTRate);
        JItem.Add('SgstAmt', SGSTRate);
        JItem.Add('IgstAmt', IGSTRate);
        JItem.Add('CesRt', CESSRate);
        JItem.Add('CesAmt', CESSValue);
        JItem.Add('CesNonAdvlAmt', CessNonAdvanceAmount);
        JItem.Add('TotItemVal', TotalItemValue);

        JsonArrayData.Add(JItem);
    end;

    local procedure ReadDocumentValueDetails()
    var
        AssessableAmount: Decimal;
        CGSTAmount: Decimal;
        SGSTAmount: Decimal;
        IGSTAmount: Decimal;
        CessAmount: Decimal;
        CESSNonAvailmentAmount: Decimal;
        OtherCharges: Decimal;
        TotalInvoiceValue: Decimal;
    begin
        Clear(JsonArrayData);
        GetGSTValue(AssessableAmount, CGSTAmount, SGSTAmount, IGSTAmount, CessAmount, CESSNonAvailmentAmount, OtherCharges, TotalInvoiceValue);
        WriteDocumentTotalDetails(AssessableAmount, CGSTAmount, SGSTAmount, IGSTAmount, CessAmount, CESSNonAvailmentAmount, OtherCharges, ABS(TotalInvoiceValue));

    end;

    local procedure WriteDocumentTotalDetails(
        AssessableAmount: Decimal;
        CGSTAmount: Decimal;
        SGSTAmount: Decimal;
        IGSTAmount: Decimal;
        CessAmount: Decimal;
        CessNonAdvanceVal: Decimal;
        OtherCharges: Decimal;
        TotalInvoiceAmount: Decimal)
    var
        JDocTotalDetails: JsonObject;
    begin
        JDocTotalDetails.Add('AssVal', AssessableAmount);
        JDocTotalDetails.Add('CgstVal', CGSTAmount);
        JDocTotalDetails.Add('SgstVal', SGSTAmount);
        JDocTotalDetails.Add('IgstVal', IGSTAmount);
        JDocTotalDetails.Add('CesVal', CessAmount);
        JDocTotalDetails.Add('CesNonAdvlAmt', CessNonAdvanceVal);
        JDocTotalDetails.Add('OthChrg', OtherCharges);
        JDocTotalDetails.Add('TotInvVal', TotalInvoiceAmount);

        JObject.Add('ValDtls', JDocTotalDetails);
    end;


    local procedure GetGSTValue(
        var AssessableAmount: Decimal;
        var CGSTAmount: Decimal;
        var SGSTAmount: Decimal;
        var IGSTAmount: Decimal;
        var CessAmount: Decimal;
        var CessNonAdvanceAmount: Decimal;
        var OtherCharges: Decimal;
        var TotalInvoiceValue: Decimal)
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTDocumentType: Enum "GST Document Type";
        DGLETransactionType: Enum "Detail Ledger Transaction Type";
        TotGSTAmt: Decimal;
    begin
        TotalInvoiceValue := 0;
        DetailedGSTLedgerEntry.LoadFields("Transaction Type", "Document Type", "Document No.", "GST Component Code", "GST Amount");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DGLETransactionType::Sales);
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
        if not DetailedGSTLedgerEntry.IsEmpty() then begin
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            IGSTAmount := Abs(DetailedGSTLedgerEntry."GST Amount")
        end;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
        if not DetailedGSTLedgerEntry.IsEmpty() then begin
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            CGSTAmount := Abs(DetailedGSTLedgerEntry."GST Amount")
        end;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
        if not DetailedGSTLedgerEntry.IsEmpty() then begin
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            SGSTAmount := Abs(DetailedGSTLedgerEntry."GST Amount")
        end;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", CESSLbl);
        if DetailedGSTLedgerEntry.FindSet() then begin
            DetailedGSTLedgerEntry.CalcSums("GST Amount");
            if DetailedGSTLedgerEntry."GST %" > 0 then
                CessAmount := Abs(DetailedGSTLedgerEntry."GST Amount")
            else
                CessNonAdvanceAmount := Abs(DetailedGSTLedgerEntry."GST Amount");
        end;

        if IsInvoice then begin
            TransferShipmentLine.LoadFields("Document No.", "GST Assessable Value");
            TransferShipmentLine.SetRange("Document No.", DocumentNo);
            if not TransferShipmentLine.IsEmpty() then
                TransferShipmentLine.CalcSums("GST Assessable Value");

            AssessableAmount := TransferShipmentLine."GST Assessable Value";
            TotGSTAmt := CGSTAmount + SGSTAmount + IGSTAmount + CessAmount + CessNonAdvanceAmount;
        end;

        if IsInvoice then begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.LoadFields("Transaction Type", "Document Type", "Document No.", "GST Base Amount");
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DGLETransactionType::Sales);
            DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType::Invoice);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            if not DetailedGSTLedgerEntry.IsEmpty() then
                TotalInvoiceValue := Abs(DetailedGSTLedgerEntry."GST Base Amount") + TotGSTAmt;
        end;
        OtherCharges := 0;
    end;

    local procedure GetComponentCode(): Boolean
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        GSTLedgerSrcType: enum "GST Ledger Source Type";
        ComponentCode: Code[30];
    begin
        GSTLedgerEntry.LoadFields("Document No.", "GST Component Code");
        GSTLedgerEntry.SetRange("Source Type", GSTLedgerSrcType::Transfer);
        GSTLedgerEntry.SetRange("Document No.", DocumentNo);
        if GSTLedgerEntry.FindFirst() then
            ComponentCode := GSTLedgerEntry."GST Component Code";

        if ComponentCode = IGSTLbl then
            exit(true);
    end;

    procedure GetEInvoiceResponse(var RecRef: RecordRef)
    var
        JSONManagement: Codeunit "JSON Management";
        QRGenerator: Codeunit "QR Generator";
        TempBlob: Codeunit "Temp Blob";
        FieldRef: FieldRef;
        JsonString: Text;
        TempIRNTxt: Text;
        TempDateTime: DateTime;
        AcknowledgementDateTimeText: Text;
        AcknowledgementDate: Date;
        AcknowledgementTime: Time;
    begin
        JsonString := GetResponseText();
        if (JsonString = '') or (JsonString = '[]') then
            exit;

        JSONManagement.InitializeObject(JsonString);
        if JSONManagement.GetValue(IRNTxt) <> '' then begin
            FieldRef := RecRef.Field(TransferShipmentHeader.FieldNo("IRN Hash"));
            FieldRef.Value := JSONManagement.GetValue(IRNTxt);
            FieldRef := RecRef.Field(TransferShipmentHeader.FieldNo("Acknowledgement No."));
            FieldRef.Value := JSONManagement.GetValue(AcknowledgementNoTxt);

            AcknowledgementDateTimeText := JSONManagement.GetValue(AcknowledgementDateTxt);
            Evaluate(AcknowledgementDate, CopyStr(AcknowledgementDateTimeText, 1, 10));
            Evaluate(AcknowledgementTime, CopyStr(AcknowledgementDateTimeText, 11, 8));
            TempDateTime := CreateDateTime(AcknowledgementDate, AcknowledgementTime);
            FieldRef := RecRef.Field(TransferShipmentHeader.FieldNo("Acknowledgement Date"));

            FieldRef.Value := TempDateTime;
            FieldRef := RecRef.Field(TransferShipmentHeader.FieldNo(IsJSONImported));
            FieldRef.Value := true;
            QRGenerator.GenerateQRCodeImage(JSONManagement.GetValue(SignedQRCodeTxt), TempBlob);
            FieldRef := RecRef.Field(TransferShipmentHeader.FieldNo("QR Code"));
            TempBlob.ToRecordRef(RecRef, TransferShipmentHeader.FieldNo("QR Code"));
            RecRef.Modify();
        end else
            Error(IRNHashErr, TempIRNTxt);
    end;

    local procedure GetResponseText() ResponseText: Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileText: Text;
    begin
        TempBlob.CreateInStream(InStream);
        UploadIntoStream('', '', '', FileText, InStream);

        if FileText = '' then
            exit;

        InStream.ReadText(ResponseText);
    end;

    procedure GenerateIRN(input: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CryptographyManagement.GenerateHash(input, HashAlgorithmType::SHA256));
    end;
}