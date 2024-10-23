// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.Ledger;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.History;
using System.Environment;

codeunit 5280 "SAF-T Data Mgt."
{
    Access = Public;

    var
        ZipFileNameSAFTTxt: label 'SAF-T Financial_%1.zip', Locked = true;
        XMLFileNameSAFTTxt: label 'SAF-T Financial_%1_%2_%3_%4.xml', Comment = '%1 - VAT Reg No., %2 - date + time, %3 - number of file, %4 - total number of files', Locked = true;
        ProductTxt: label 'Goods', Locked = true;
        ServiceTxt: label 'Service', Locked = true;

    /// <summary>
    /// Returns the VAT Reporting Code that is used in cases when the VAT Reporting Code is not set in VAT Posting Setup.
    /// </summary>
    procedure GetNotApplicableVATCode(): Code[9]
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        AuditFileExportSetup.Get();
        exit(AuditFileExportSetup."Not Applicable VAT Code");
    end;

    /// <summary>
    /// Returns the ISO 4217 currency code for the specified currency.
    /// </summary>
    procedure GetISOCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.SetLoadFields("LCY Code");
            GeneralLedgerSetup.Get();
            exit(GeneralLedgerSetup."LCY Code");
        end;
        Currency.SetLoadFields("ISO Code");
        Currency.Get(CurrencyCode);
        exit(Currency."ISO Code");
    end;

    /// <summary>
    /// Returns the country code in ISO 3166-1 alpha-2 format.
    /// </summary>
    procedure GetISOCountryCode(CountryRegionCode: Text): Code[2]
    var
        CountryRegion: Record "Country/Region";
    begin
        if CountryRegionCode = '' then
            exit('');
        CountryRegion.SetLoadFields("ISO Code");
        CountryRegion.Get(CountryRegionCode);
        exit(CountryRegion."ISO Code");
    end;

    /// <summary>
    /// Rounds the decimal to 2 decimal places and converts it to the XML format.
    /// </summary>
    procedure GetSAFTMonetaryDecimal(InputDecimal: Decimal): Text
    begin
        InputDecimal := Round(InputDecimal, 0.01);
        exit(FormatAmount(InputDecimal));
    end;

    /// <summary>
    /// Rounds the decimal to 8 decimal places and converts it to the XML format.
    /// </summary>
    procedure GetSAFTExchangeRateDecimal(InputDecimal: Decimal): Text
    begin
        InputDecimal := Round(InputDecimal, 0.00000001);
        exit(FormatAmount(InputDecimal));
    end;

    /// <summary>
    /// Returns the text of length 9.
    /// </summary>
    procedure GetSAFTCodeText(InputText: Text): Text
    var
        XmlEscapeCharsAdditionalLength: Integer;
        OutputStringLength: Integer;
    begin
        XmlEscapeCharsAdditionalLength := GetXmlEscapeCharsAdditionalLength(InputText);
        OutputStringLength := 9 - XmlEscapeCharsAdditionalLength;
        if OutputStringLength < 0 then
            OutputStringLength := 0;
        exit(CopyStr(InputText, 1, OutputStringLength));
    end;

    /// <summary>
    /// Returns the text of length 18.
    /// </summary>
    procedure GetSAFTShortText(InputText: Text): Text
    var
        XmlEscapeCharsAdditionalLength: Integer;
        OutputStringLength: Integer;
    begin
        XmlEscapeCharsAdditionalLength := GetXmlEscapeCharsAdditionalLength(InputText);
        OutputStringLength := 18 - XmlEscapeCharsAdditionalLength;
        if OutputStringLength < 0 then
            OutputStringLength := 0;
        exit(CopyStr(InputText, 1, OutputStringLength));
    end;

    /// <summary>
    /// Returns the text of length 35.
    /// </summary>
    procedure GetSAFTMiddle1Text(InputText: Text): Text
    var
        XmlEscapeCharsAdditionalLength: Integer;
        OutputStringLength: Integer;
    begin
        XmlEscapeCharsAdditionalLength := GetXmlEscapeCharsAdditionalLength(InputText);
        OutputStringLength := 35 - XmlEscapeCharsAdditionalLength;
        if OutputStringLength < 0 then
            OutputStringLength := 0;
        exit(CopyStr(InputText, 1, OutputStringLength));
    end;

    /// <summary>
    /// Returns the text of length 70.
    /// </summary>
    procedure GetSAFTMiddle2Text(InputText: Text): Text
    var
        XmlEscapeCharsAdditionalLength: Integer;
        OutputStringLength: Integer;
    begin
        XmlEscapeCharsAdditionalLength := GetXmlEscapeCharsAdditionalLength(InputText);
        OutputStringLength := 70 - XmlEscapeCharsAdditionalLength;
        if OutputStringLength < 0 then
            OutputStringLength := 0;
        exit(CopyStr(InputText, 1, OutputStringLength));
    end;

    /// <summary>
    /// Converts the decimal to its text representation allowed in the XML.
    /// </summary>
    procedure FormatAmount(AmountToFormat: Decimal): Text
    begin
        exit(Format(AmountToFormat, 0, 9))
    end;

    /// <summary>
    /// Combines two strings with a space between them.
    /// </summary>
    procedure CombineWithSpace(FirstString: Text; SecondString: Text) Result: Text
    begin
        Result := FirstString;
        if (Result <> '') and (SecondString <> '') then
            Result += ' ';
        exit(Result + SecondString);
    end;

    /// <summary>
    /// Returns the name of the zip archive to which the SAF-T files are added.
    /// </summary>
    procedure GetZipFileName(): Text[1024]
    begin
        exit(ZipFileNameSAFTTxt);
    end;

    internal procedure GetXmlFileName(CreatedDateTime: DateTime; NumberOfFile: Integer; TotalNumberOfFiles: Integer): Text[1024]
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        exit(StrSubstNo(XMLFileNameSAFTTxt, CompanyInformation."VAT Registration No.", GetDateTimeForFileName(CreatedDateTime), NumberOfFile, TotalNumberOfFiles));
    end;

    internal procedure GetEnvironmentCountryCode(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        exit(EnvironmentInformation.GetApplicationFamily());
    end;

    internal procedure GetDateTimeForFileName(CreatedDateTime: DateTime): Text
    begin
        exit(Format(CreatedDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>'));
    end;

    internal procedure GetFirstAndLastNameFromContactName(var FirstName: Text; var LastName: Text; ContactName: Text)
    var
        SpacePos: Integer;
    begin
        SpacePos := StrPos(ContactName, ' ');
        if SpacePos = 0 then begin
            FirstName := ContactName;
            LastName := '-';
        end else begin
            FirstName := CopyStr(ContactName, 1, SpacePos - 1);
            LastName := CopyStr(ContactName, SpacePos + 1, StrLen(ContactName) - SpacePos);
        end;
    end;

    internal procedure GetAppliedSalesDocuments(CustLedgerEntryNo: Integer; AppliedDocumentType: Enum "Gen. Journal Document Type") AppliedDocumentNos: List of [Code[20]]
    var
        TempAppliedCustLedgerEntry: Record "Cust. Ledger Entry" temporary;
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        PrevDocNo: Code[20];
    begin
        PrevDocNo := '';
        CustEntryApplyPostedEntries.GetAppliedCustLedgerEntries(TempAppliedCustLedgerEntry, CustLedgerEntryNo);
        TempAppliedCustLedgerEntry.SetCurrentKey("Document No.");
        TempAppliedCustLedgerEntry.SetRange("Document Type", AppliedDocumentType);
        if TempAppliedCustLedgerEntry.FindSet() then
            repeat
                if TempAppliedCustLedgerEntry."Document No." <> PrevDocNo then
                    AppliedDocumentNos.Add(TempAppliedCustLedgerEntry."Document No.");
                PrevDocNo := TempAppliedCustLedgerEntry."Document No.";
            until TempAppliedCustLedgerEntry.Next() = 0;
    end;

    internal procedure GetAppliedPurchaseCreditMemos(VendorLedgerEntryNo: Integer; AppliedDocumentType: Enum "Gen. Journal Document Type") AppliedDocumentNos: List of [Code[20]]
    var
        TempAppliedVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        PrevDocNo: Code[20];
    begin
        PrevDocNo := '';
        VendEntryApplyPostedEntries.GetAppliedVendLedgerEntries(TempAppliedVendorLedgerEntry, VendorLedgerEntryNo);
        TempAppliedVendorLedgerEntry.SetCurrentKey("Document No.");
        TempAppliedVendorLedgerEntry.SetRange("Document Type", AppliedDocumentType);
        if TempAppliedVendorLedgerEntry.FindSet() then
            repeat
                if TempAppliedVendorLedgerEntry."Document No." <> PrevDocNo then
                    AppliedDocumentNos.Add(TempAppliedVendorLedgerEntry."Document No.");
                PrevDocNo := TempAppliedVendorLedgerEntry."Document No.";
            until TempAppliedVendorLedgerEntry.Next() = 0;
    end;

    internal procedure GetTotalAmountCustomerDocuments(StartingDate: Date; EndingDate: Date; DocumentType: Enum "Gen. Journal Document Type"): Decimal
    var
        DetailedCustLedgerEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgerEntry.SetLoadFields("Document Type", "Posting Date", "Ledger Entry Amount", "Amount (LCY)");
        DetailedCustLedgerEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedCustLedgerEntry.SetRange("Ledger Entry Amount", true);
        DetailedCustLedgerEntry.SetRange("Document Type", DocumentType);
        DetailedCustLedgerEntry.CalcSums("Amount (LCY)");
        exit(DetailedCustLedgerEntry."Amount (LCY)");
    end;

    internal procedure GetTotalAmountVendorDocuments(StartingDate: Date; EndingDate: Date; DocumentType: Enum "Gen. Journal Document Type"): Decimal
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        DetailedVendorLedgEntry.SetLoadFields("Document Type", "Posting Date", "Ledger Entry Amount", "Amount (LCY)");
        DetailedVendorLedgEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedVendorLedgEntry.SetRange("Ledger Entry Amount", true);
        DetailedVendorLedgEntry.SetRange("Document Type", DocumentType);
        DetailedVendorLedgEntry.CalcSums("Amount (LCY)");
        exit(DetailedVendorLedgEntry."Amount (LCY)");
    end;

    internal procedure GetFCYData(var CurrencyCode: Code[10]; var ExchangeRate: Decimal; var GLEntry: Record "G/L Entry"; ExportCurrencyInfo: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
    begin
        if not ExportCurrencyInfo then
            exit;

        CurrencyCode := '';
        ExchangeRate := 0;

        if GLEntry."Source Type" in [GLEntry."Source Type"::Customer, GLEntry."Source Type"::" "] then begin
            CustLedgerEntry.SetCurrentKey("Transaction No.");
            CustLedgerEntry.SetLoadFields("Transaction No.", "Currency Code");
            CustLedgerEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            if not CustLedgerEntry.FindFirst() then
                exit;
            if CustLedgerEntry."Currency Code" = '' then
                exit;
            CustLedgerEntry.CalcFields(Amount, "Amount (LCY)");
            if CustLedgerEntry.Amount = 0 then
                exit;
            CurrencyCode := CustLedgerEntry."Currency Code";
            ExchangeRate := CustLedgerEntry."Amount (LCY)" / CustLedgerEntry.Amount;
            exit;
        end;
        if GLEntry."Source Type" in [GLEntry."Source Type"::Vendor, GLEntry."Source Type"::" "] then begin
            VendorLedgEntry.SetCurrentKey("Transaction No.");
            VendorLedgEntry.SetLoadFields("Transaction No.", "Currency Code");
            VendorLedgEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            if not VendorLedgEntry.FindFirst() then
                exit;
            if VendorLedgEntry."Currency Code" = '' then
                exit;
            VendorLedgEntry.CalcFields(Amount, "Amount (LCY)");
            if VendorLedgEntry.Amount = 0 then
                exit;
            CurrencyCode := VendorLedgEntry."Currency Code";
            ExchangeRate := VendorLedgEntry."Amount (LCY)" / VendorLedgEntry.Amount;
            exit;
        end;
        if GLEntry."Source Type" in [GLEntry."Source Type"::"Bank Account", GLEntry."Source Type"::" "] then begin
            BankAccLedgEntry.SetCurrentKey("Transaction No.");
            BankAccLedgEntry.SetLoadFields("Transaction No.", "Currency Code", Amount, "Amount (LCY)");
            BankAccLedgEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            if not BankAccLedgEntry.FindFirst() then
                exit;
            if BankAccLedgEntry."Currency Code" = '' then
                exit;
            if BankAccLedgEntry.Amount = 0 then
                exit;
            CurrencyCode := BankAccLedgEntry."Currency Code";
            ExchangeRate := BankAccLedgEntry."Amount (LCY)" / BankAccLedgEntry.Amount;
            exit;
        end;
    end;

    internal procedure GetShipToAddressFromItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; var ShipToAddress: Record "Ship-to Address")
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        ShipToAddress.Init();

        SalesInvoiceHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        SalesCrMemoHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        SalesShipmentHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        ReturnReceiptHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        PurchCrMemoHdr.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        PurchInvHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        PurchRcptHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        ReturnShipmentHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        ServiceShipmentHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        ServiceInvoiceHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        ServiceCrMemoHeader.SetLoadFields("Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code");
        TransferReceiptHeader.SetLoadFields("Transfer-to Address", "Transfer-to Address 2", "Transfer-to City", "Transfer-to Post Code", "Trsf.-to Country/Region Code");
        TransferShipmentHeader.SetLoadFields("Transfer-to Address", "Transfer-to Address 2", "Transfer-to City", "Transfer-to Post Code", "Trsf.-to Country/Region Code");

        case ItemLedgerEntry."Document Type" of
            ItemLedgerEntry."Document Type"::"Sales Invoice":
                if SalesInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, SalesInvoiceHeader."Ship-to Address", SalesInvoiceHeader."Ship-to Address 2", SalesInvoiceHeader."Ship-to City",
                        SalesInvoiceHeader."Ship-to Post Code", SalesInvoiceHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Sales Credit Memo":
                if SalesCrMemoHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, SalesCrMemoHeader."Ship-to Address", SalesCrMemoHeader."Ship-to Address 2", SalesCrMemoHeader."Ship-to City",
                        SalesCrMemoHeader."Ship-to Post Code", SalesCrMemoHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Sales Shipment":
                if SalesShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, SalesShipmentHeader."Ship-to Address", SalesShipmentHeader."Ship-to Address 2", SalesShipmentHeader."Ship-to City",
                        SalesShipmentHeader."Ship-to Post Code", SalesShipmentHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Sales Return Receipt":
                if ReturnReceiptHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, ReturnReceiptHeader."Ship-to Address", ReturnReceiptHeader."Ship-to Address 2", ReturnReceiptHeader."Ship-to City",
                        ReturnReceiptHeader."Ship-to Post Code", ReturnReceiptHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoHdr.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, PurchCrMemoHdr."Ship-to Address", PurchCrMemoHdr."Ship-to Address 2", PurchCrMemoHdr."Ship-to City",
                        PurchCrMemoHdr."Ship-to Post Code", PurchCrMemoHdr."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, ReturnShipmentHeader."Ship-to Address", ReturnShipmentHeader."Ship-to Address 2", ReturnShipmentHeader."Ship-to City",
                        ReturnShipmentHeader."Ship-to Post Code", ReturnShipmentHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Purchase Invoice":
                if PurchInvHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, PurchInvHeader."Ship-to Address", PurchInvHeader."Ship-to Address 2", PurchInvHeader."Ship-to City",
                        PurchInvHeader."Ship-to Post Code", PurchInvHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Purchase Receipt":
                if PurchRcptHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, PurchRcptHeader."Ship-to Address", PurchRcptHeader."Ship-to Address 2", PurchRcptHeader."Ship-to City",
                        PurchRcptHeader."Ship-to Post Code", PurchRcptHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Service Shipment":
                if ServiceShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, ServiceShipmentHeader."Ship-to Address", ServiceShipmentHeader."Ship-to Address 2", ServiceShipmentHeader."Ship-to City",
                        ServiceShipmentHeader."Ship-to Post Code", ServiceShipmentHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Service Invoice":
                if ServiceInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, ServiceInvoiceHeader."Ship-to Address", ServiceInvoiceHeader."Ship-to Address 2", ServiceInvoiceHeader."Ship-to City",
                        ServiceInvoiceHeader."Ship-to Post Code", ServiceInvoiceHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Service Credit Memo":
                if ServiceCrMemoHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, ServiceCrMemoHeader."Ship-to Address", ServiceCrMemoHeader."Ship-to Address 2", ServiceCrMemoHeader."Ship-to City",
                        ServiceCrMemoHeader."Ship-to Post Code", ServiceCrMemoHeader."Ship-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Transfer Receipt":
                if TransferReceiptHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, TransferReceiptHeader."Transfer-to Address", TransferReceiptHeader."Transfer-to Address 2", TransferReceiptHeader."Transfer-to City",
                        TransferReceiptHeader."Transfer-to Post Code", TransferReceiptHeader."Trsf.-to Country/Region Code");
            ItemLedgerEntry."Document Type"::"Transfer Shipment":
                if TransferShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    InitShipToAddress(
                        ShipToAddress, TransferShipmentHeader."Transfer-to Address", TransferShipmentHeader."Transfer-to Address 2", TransferShipmentHeader."Transfer-to City",
                        TransferShipmentHeader."Transfer-to Post Code", TransferShipmentHeader."Trsf.-to Country/Region Code");
        end;
    end;

    internal procedure GetShipFromAddressFromItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; var ShipFromAddress: Record "Ship-to Address"; var PackageTrackingNo: Text)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        Location: Record Location;
        LocationCode: Code[10];
    begin
        PackageTrackingNo := '';
        ShipFromAddress.Init();

        case ItemLedgerEntry."Document Type" of
            ItemLedgerEntry."Document Type"::"Sales Invoice":
                if SalesInvoiceHeader.Get(ItemLedgerEntry."Document No.") then begin
                    LocationCode := SalesInvoiceHeader."Location Code";
                    PackageTrackingNo := SalesInvoiceHeader."Package Tracking No.";
                end;
            ItemLedgerEntry."Document Type"::"Sales Shipment":
                if SalesShipmentHeader.Get(ItemLedgerEntry."Document No.") then begin
                    LocationCode := SalesShipmentHeader."Location Code";
                    PackageTrackingNo := SalesShipmentHeader."Package Tracking No.";
                end;
            ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoHdr.Get(ItemLedgerEntry."Document No.") then
                    LocationCode := PurchCrMemoHdr."Location Code";
            ItemLedgerEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    LocationCode := ReturnShipmentHeader."Location Code";
            ItemLedgerEntry."Document Type"::"Service Shipment":
                if ServiceShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    LocationCode := ServiceShipmentHeader."Location Code";
            ItemLedgerEntry."Document Type"::"Service Invoice":
                if ServiceInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
                    LocationCode := ServiceInvoiceHeader."Location Code";
            ItemLedgerEntry."Document Type"::"Transfer Receipt":
                if TransferReceiptHeader.Get(ItemLedgerEntry."Document No.") then
                    LocationCode := TransferReceiptHeader."Transfer-from Code";
            ItemLedgerEntry."Document Type"::"Transfer Shipment":
                if TransferShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    LocationCode := TransferShipmentHeader."Transfer-from Code";
        end;

        if Location.Get(LocationCode) then
            InitShipToAddress(ShipFromAddress, Location.Address, Location."Address 2", Location.City, Location."Post Code", Location."Country/Region Code");
    end;

    internal procedure GetFixedAssetAcquisitionLedgerEntry(var AcquisitionFALedgerEntry: Record "FA Ledger Entry"; FixedAssetNo: Code[20])
    begin
        AcquisitionFALedgerEntry.SetLoadFields("FA No.", "FA Posting Type", "Document No.", "Posting Date", "Document Date", "Depreciation Starting Date");
        AcquisitionFALedgerEntry.SetRange("FA No.", FixedAssetNo);
        AcquisitionFALedgerEntry.SetRange("FA Posting Type", "FA Ledger Entry FA Posting Type"::"Acquisition Cost");
        if AcquisitionFALedgerEntry.FindFirst() then;
    end;

    internal procedure GetFixedAssetAcquisitionVendorNo(var AcquisitionFALedgerEntry: Record "FA Ledger Entry"): Code[20]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if (AcquisitionFALedgerEntry."Document No." = '') or (AcquisitionFALedgerEntry."Posting Date" = 0D) then
            exit('');

        VendorLedgerEntry.SetLoadFields("Vendor No.", "Document No.", "Posting Date");
        VendorLedgerEntry.SetRange("Document No.", AcquisitionFALedgerEntry."Document No.");
        VendorLedgerEntry.SetRange("Posting Date", AcquisitionFALedgerEntry."Posting Date");
        if VendorLedgerEntry.FindFirst() then
            exit(VendorLedgerEntry."Vendor No.");

        exit('');
    end;

    internal procedure GetFixedAssetBookValueOnTransactionDate(var TransactionFALedgerEntry: Record "FA Ledger Entry") BookValue: Decimal
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.SetLoadFields("FA No.", "FA Posting Type", "Posting Date", "Amount (LCY)");
        FALedgerEntry.SetRange("FA No.", TransactionFALedgerEntry."FA No.");
        FALedgerEntry.SetFilter("FA Posting Type", '<>%1&<>%2', "FA Ledger Entry FA Posting Type"::"Proceeds on Disposal", "FA Ledger Entry FA Posting Type"::"Gain/Loss");
        FALedgerEntry.SetFilter("Posting Date", '<=%1', TransactionFALedgerEntry."Posting Date");
        FALedgerEntry.CalcSums("Amount (LCY)");
        BookValue := FALedgerEntry."Amount (LCY)";
    end;

    internal procedure GetGoodsServicesID(IsService: Boolean) GoodsServicesID: Text
    begin
        if IsService then
            GoodsServicesID := ServiceTxt     // Service
        else
            GoodsServicesID := ProductTxt;    // Goods
        GoodsServicesID := GetSAFTCodeText(GoodsServicesID);
    end;

    internal procedure GetDebitCreditIndicator(Amount: Decimal) DebitCreditIndicator: Text
    begin
        if Amount = 0 then begin
            DebitCreditIndicator := '';
            exit;
        end;

        if Amount > 0 then
            DebitCreditIndicator := 'D'
        else
            DebitCreditIndicator := 'C';
    end;

    internal procedure GetMovementEntryType(EntryType: Enum "Item Ledger Entry Type") MovementEntryTypeText: Text
    begin
        case EntryType of
            EntryType::" ", EntryType::Sale, EntryType::Purchase, EntryType::Transfer, EntryType::Output:
                MovementEntryTypeText := Format(EntryType);
            EntryType::"Positive Adjmt.":
                MovementEntryTypeText := 'PstvAdjmt';
            EntryType::"Negative Adjmt.":
                MovementEntryTypeText := 'NgtvAdjmt';
            EntryType::Consumption:
                MovementEntryTypeText := 'Consumpt.';
            EntryType::"Assembly Consumption":
                MovementEntryTypeText := 'AsmblCons';
            EntryType::"Assembly Output":
                MovementEntryTypeText := 'AsmblOutp';
            else
                MovementEntryTypeText := Format(EntryType);
        end;

        exit(GetSAFTCodeText(MovementEntryTypeText));
    end;

    internal procedure GetMovementDocType(DocumentType: Enum "Item Ledger Document Type") MovementDocTypeText: Text
    begin
        case DocumentType of
            DocumentType::" ", DocumentType::"Sales Shipment", DocumentType::"Sales Invoice", DocumentType::"Sales Credit Memo",
            DocumentType::"Purchase Receipt", DocumentType::"Purchase Invoice", DocumentType::"Transfer Shipment", DocumentType::"Transfer Receipt",
            DocumentType::"Service Shipment", DocumentType::"Service Invoice", DocumentType::"Posted Assembly", DocumentType::"Inventory Receipt",
            DocumentType::"Inventory Shipment", DocumentType::"Direct Transfer":
                MovementDocTypeText := Format(DocumentType);
            DocumentType::"Sales Return Receipt":
                MovementDocTypeText := 'Sales Return Rcpt';
            DocumentType::"Purchase Return Shipment":
                MovementDocTypeText := 'Purch. Return Shpt';
            DocumentType::"Purchase Credit Memo":
                MovementDocTypeText := 'Purch. Credit Memo';
            DocumentType::"Service Credit Memo":
                MovementDocTypeText := 'Serv. Credit Memo';
            else
                MovementDocTypeText := Format(DocumentType);
        end;

        exit(GetSAFTShortText(MovementDocTypeText));
    end;

    internal procedure GetAssetTransactionType(FAPostingType: Enum "FA Ledger Entry FA Posting Type") AssetTransactionTypeText: Text
    begin
        case FAPostingType of
            "FA Ledger Entry FA Posting Type"::"Acquisition Cost":
                AssetTransactionTypeText := 'AcquiCost';
            "FA Ledger Entry FA Posting Type"::Depreciation:
                AssetTransactionTypeText := 'Depreciat';
            "FA Ledger Entry FA Posting Type"::"Write-Down":
                AssetTransactionTypeText := 'WriteDown';
            "FA Ledger Entry FA Posting Type"::Appreciation:
                AssetTransactionTypeText := 'Appreciat';
            "FA Ledger Entry FA Posting Type"::"Proceeds on Disposal":
                AssetTransactionTypeText := 'ProcDisps';
            "FA Ledger Entry FA Posting Type"::"Salvage Value":
                AssetTransactionTypeText := 'SalvValue';
            "FA Ledger Entry FA Posting Type"::"Book Value on Disposal":
                AssetTransactionTypeText := 'BkValDsps';
            "FA Ledger Entry FA Posting Type"::"Custom 1", "FA Ledger Entry FA Posting Type"::"Custom 2",
            "FA Ledger Entry FA Posting Type"::"Gain/Loss":
                AssetTransactionTypeText := Format(FAPostingType);
            else
                AssetTransactionTypeText := Format(FAPostingType);
        end;

        exit(GetSAFTCodeText(AssetTransactionTypeText));
    end;

    internal procedure GetAmountInfoFromGLEntry(var AmountXMLNode: Text; var Amount: Decimal; GLEntry: Record "G/L Entry")
    begin
        if GLEntry."Debit Amount" = 0 then begin
            AmountXMLNode := 'CreditAmount';
            Amount := GLEntry."Credit Amount";
        end else begin
            AmountXMLNode := 'DebitAmount';
            Amount := GLEntry."Debit Amount";
        end;
    end;

    internal procedure IsSalesLineService(SourceType: Enum "Sales Line Type"; SourceNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if SourceType = "Sales Line Type"::Item then begin
            Item.SetLoadFields(Type);
            Item.Get(SourceNo);
            if Item.Type = "Item Type"::Inventory then
                exit(false);
        end;

        if SourceType = "Sales Line Type"::"Fixed Asset" then
            exit(false);

        exit(true);
    end;

    internal procedure IsPurchaseLineService(SourceType: Enum "Purchase Line Type"; SourceNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if SourceType = "Purchase Line Type"::Item then begin
            Item.SetLoadFields(Type);
            Item.Get(SourceNo);
            if Item.Type = "Item Type"::Inventory then
                exit(false);
        end;

        if SourceType = "Purchase Line Type"::"Fixed Asset" then
            exit(false);

        exit(true);
    end;

    internal procedure IsGLAccInCurrencyGainLossAcc(GLAccNo: Code[20]; CurrencyCode: Code[10]): Boolean
    var
        Currency: Record Currency;
    begin
        Currency.SetLoadFields("Unrealized Gains Acc.", "Unrealized Losses Acc.", "Realized Gains Acc.", "Realized Losses Acc.");
        Currency.Get(CurrencyCode);
        exit(GLAccNo in [Currency."Unrealized Gains Acc.", Currency."Unrealized Losses Acc.", Currency."Realized Gains Acc.", Currency."Realized Losses Acc."]);
    end;

    local procedure InitShipToAddress(var ShipToAddress: Record "Ship-to Address"; Address: Text[100]; Address2: Text[50]; City: Text[30]; PostCode: Code[20]; CountryCode: Code[10])
    begin
        ShipToAddress.Init();
        ShipToAddress.Address := Address;
        ShipToAddress."Address 2" := Address2;
        ShipToAddress.City := City;
        ShipToAddress."Post Code" := PostCode;
        ShipToAddress."Country/Region Code" := CountryCode;
    end;

    local procedure GetXmlEscapeCharsAdditionalLength(NodeText: Text) AdditionalLength: Integer
    var
        currChar: Char;
        i: Integer;
    begin
        // xml escape chars < > & are replaced with &lt; &gt; &amp; which are 3 or 4 chars longer
        AdditionalLength := 0;
        for i := 1 to StrLen(NodeText) do begin
            currChar := NodeText[i];
            case currChar of
                '<', '>':
                    AdditionalLength += 3;
                '&':
                    AdditionalLength += 4;
            end;
        end;
    end;
}
