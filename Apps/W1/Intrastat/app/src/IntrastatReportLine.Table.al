// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Service.History;
using System.Utilities;

table 4812 "Intrastat Report Line"
{
    DataClassification = CustomerContent;
    Caption = 'Intrastat Report Line';

    fields
    {
        field(1; "Intrastat No."; Code[20])
        {
            Caption = 'Intrastat No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "Intrastat Report Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Enum "Intrastat Report Line Type")
        {
            Caption = 'Type';
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            trigger OnValidate()
            var
                StartDate: Date;
                EndDate: Date;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeCheckDateInRange(Rec, IsHandled);
                if IsHandled then
                    exit;

                IntrastatReportHeader.Get("Intrastat No.");
                StartDate := IntrastatReportHeader.GetStatisticsStartDate();
                EndDate := CalcDate('<+1M-1D>', StartDate);
                if (Rec.Date < StartDate) or (Rec.Date > EndDate) then
                    Error(DateNotInRageErr, Rec.Date);
            end;
        }
        field(5; "Tariff No."; Code[20])
        {
            Caption = 'Tariff No.';
            NotBlank = true;
            TableRelation = "Tariff Number";

            trigger OnValidate()
            begin
                GetTariffDescription();
            end;
        }
        field(6; "Tariff Description"; Text[250])
        {
            Caption = 'Tariff Description';
        }
        field(7; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(8; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(9; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(10; "Source Type"; Enum "Intrastat Report Source Type")
        {
            BlankZero = true;
            Caption = 'Source Type';

            trigger OnValidate()
            begin
                IntrastatReportSetup.GetSetup();
                if ((Type = Type::Shipment) and (IntrastatReportSetup."Get Partner VAT For" <> IntrastatReportSetup."Get Partner VAT For"::Receipt)) or
                   ((Type = Type::Receipt) and (IntrastatReportSetup."Get Partner VAT For" <> IntrastatReportSetup."Get Partner VAT For"::Shipment))
                then
                    "Partner VAT ID" := GetPartnerID();
                "Country/Region of Origin Code" := GetCountryOfOriginCode();
            end;
        }
        field(11; "Source Entry No."; Integer)
        {
            Caption = 'Source Entry No.';
            TableRelation = if ("Source Type" = const("Item Entry")) "Item Ledger Entry" else
            if ("Source Type" = const("Job Entry")) "Job Ledger Entry" else
            if ("Source Type" = const("FA Entry")) "FA Ledger Entry";
        }
        field(12; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if Quantity <> 0 then
                    "Total Weight" := Round("Net Weight" * Quantity, 0.00001)
                else
                    "Total Weight" := 0;
            end;
        }
        field(13; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if "Cost Regulation %" <> 0 then
                    Validate("Cost Regulation %")
                else
                    "Statistical Value" := Amount + "Indirect Cost";
            end;
        }
        field(14; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if (Quantity <> 0) then
                    if ("Source Type" = "Source Type"::"FA Entry") and FixedAsset.Get("Item No.") then
                        Validate("Net Weight", FixedAsset."Net Weight")
                    else
                        if ("Source Type" in ["Source Type"::"Item Entry", "Source Type"::"Job Entry"]) and
                            Item.Get("Item No.")
                        then
                            Validate("Net Weight", Item."Net Weight")
                        else
                            Validate("Net Weight", 0);
                Validate("Suppl. Conversion Factor");
            end;
        }
        field(15; "Cost Regulation %"; Decimal)
        {
            Caption = 'Cost Regulation %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Indirect Cost" := Amount * "Cost Regulation %" / 100;
                "Statistical Value" := Amount + "Indirect Cost";
            end;
        }
        field(16; "Indirect Cost"; Decimal)
        {
            Caption = 'Indirect Cost';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Cost Regulation %" := 0;
                "Statistical Value" := Amount + "Indirect Cost";
            end;
        }
        field(17; "Statistical Value"; Decimal)
        {
            Caption = 'Statistical Value';
            DecimalPlaces = 0 : 5;
        }
        field(18; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(19; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = if ("Source Type" = const("Item Entry")) Item else
            if ("Source Type" = const("Job Entry")) Item else
            if ("Source Type" = const("FA Entry")) "Fixed Asset";

            trigger OnValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                if ("Source Type" = "Source Type"::"FA Entry") then begin
                    if "Item No." = '' then
                        Clear(FixedAsset)
                    else
                        FixedAsset.Get("Item No.");
                    "Item Name" := FixedAsset.Description;
                    "Tariff No." := FixedAsset."Tariff No.";
                    "Country/Region of Origin Code" := FixedAsset."Country/Region of Origin Code";
                    "Suppl. Unit of Measure" := FixedAsset."Supplementary Unit of Measure";
                    if "Suppl. Unit of Measure" <> '' then
                        "Suppl. Conversion Factor" := 1
                    else
                        "Suppl. Conversion Factor" := 0;
                end else begin
                    if "Item No." = '' then
                        Clear(Item)
                    else
                        Item.Get("Item No.");
                    "Item Name" := Item.Description;
                    "Tariff No." := Item."Tariff No.";
                    "Country/Region of Origin Code" := GetCountryOfOriginCode();
                    "Suppl. Unit of Measure" := Item."Supplementary Unit of Measure";
                    if ItemUOM.Get(Item."No.", Item."Supplementary Unit of Measure") and
                        (ItemUOM."Qty. per Unit of Measure" <> 0)
                    then
                        "Suppl. Conversion Factor" := 1 / ItemUOM."Qty. per Unit of Measure";
                end;
                GetTariffDescription();
                Validate("Suppl. Conversion Factor");
            end;
        }
        field(20; "Item Name"; Text[100])
        {
            Caption = 'Item Name';
        }
        field(21; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Supplementary Units"; Boolean)
        {
            Caption = 'Supplementary Units';
            Editable = false;
        }
        field(23; "Internal Ref. No."; Text[10])
        {
            Caption = 'Internal Ref. No.';
            Editable = false;
        }
        field(24; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
        }
        field(25; "Entry/Exit Point"; Code[10])
        {
            Caption = 'Entry/Exit Point';
            TableRelation = "Entry/Exit Point";
        }
        field(26; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(27; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(28; "Shpt. Method Code"; Code[10])
        {
            Caption = 'Shpt. Method Code';
            TableRelation = "Shipment Method";
        }
        field(29; "Partner VAT ID"; Text[50])
        {
            Caption = 'VAT Reg. No.';
        }
        field(30; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(31; Counterparty; Boolean)
        {
            Caption = 'Counterparty';
        }
        field(32; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(33; "Suppl. Conversion Factor"; Decimal)
        {
            Caption = 'Supplementary Unit Conversion Factor';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                "Supplementary Quantity" := Round(Quantity * "Suppl. Conversion Factor", UOMMgt.QtyRndPrecision());
                "Supplementary Units" := "Suppl. Unit of Measure" <> '';
            end;
        }
        field(34; "Suppl. Unit of Measure"; Text[10])
        {
            Caption = 'Supplementary Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                if "Suppl. Unit of Measure" <> '' then begin
                    ItemUOM.Get("Item No.", "Suppl. Unit of Measure");
                    Validate("Suppl. Conversion Factor", 1 / ItemUOM."Qty. per Unit of Measure");
                end else
                    Validate("Suppl. Conversion Factor", 0);
            end;
        }
        field(35; "Supplementary Quantity"; Decimal)
        {
            Caption = 'Supplementary Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(36; "Statistical System"; Enum "Intrastat Report Stat. System")
        {
            Caption = 'Statistical System';
        }
        field(37; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(38; "Source Currency Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            Caption = 'Source Currency Amount';
            DecimalPlaces = 0 : 5;
        }
        field(39; "Corrective entry"; Boolean)
        {
            Caption = 'Corrective entry';
        }
        field(40; "Group Code"; Code[10])
        {
            Caption = 'Group Code';
            Editable = false;
        }
        field(41; "Statistics Period"; Code[10])
        {
            Caption = 'Statistics Period';
            Editable = true;
        }
        field(42; "Reference Period"; Code[10])
        {
            Caption = 'Reference Period';
            Numeric = true;
        }
        field(43; "Payment Method"; Code[10])
        {
            Caption = 'Payment Method';
            TableRelation = "Payment Method";

            trigger OnValidate()
            begin
                if "Payment Method" <> '' then
                    IntrastatReportHeader.CheckEUServAndCorrection("Intrastat No.", true, false);
            end;
        }

        field(44; "Corrected Intrastat Report No."; Code[20])
        {
            Caption = 'Corrected Intrastat Report No.';

            trigger OnLookup()
            var
                IntrastatReportHeader2: Record "Intrastat Report Header";
            begin
                SetIntrastatReportHeaderFilters(IntrastatReportHeader2);
                IntrastatReportHeader2."No." := "Corrected Intrastat Report No.";
                if Page.RunModal(0, IntrastatReportHeader2, IntrastatReportHeader2."No.") = Action::LookupOK then
                    Validate("Corrected Intrastat Report No.", IntrastatReportHeader2."No.");
            end;

            trigger OnValidate()
            var
                IntrastatReportHeader2: Record "Intrastat Report Header";
            begin
                if "Corrected Intrastat Report No." <> '' then begin
                    IntrastatReportHeader.CheckEUServAndCorrection("Intrastat No.", false, true);
                    SetIntrastatReportHeaderFilters(IntrastatReportHeader2);
                    IntrastatReportHeader2.SetRange("No.", "Corrected Intrastat Report No.");
                    if not IntrastatReportHeader2.FindFirst() then
                        FieldError("Corrected Intrastat Report No.")
                    else
                        Validate("Reference Period", IntrastatReportHeader2."Statistics Period");
                end;
            end;
        }

        field(45; "Country/Region of Payment Code"; Code[10])
        {
            Caption = 'Country/Region of Payment Code';
            TableRelation = "Country/Region";
        }
        field(46; "Progressive No."; Code[5])
        {
            Caption = 'Progressive No.';
        }
        field(47; "Obligation Level"; Code[20])
        {
            Caption = 'Obligation Level';
        }
        field(48; "Corrected Document No."; Code[20])
        {
            Caption = 'Corrected Document No.';

            trigger OnLookup()
            var
                IntrastatReportLine: Record "Intrastat Report Line";
                IntrastatReportLines: Page "Intrastat Report Lines";
            begin
                IntrastatReportLines.LookupMode := true;
                IntrastatReportLine.SetRange("Intrastat No.", "Corrected Intrastat Report No.");
                IntrastatReportLines.SetTableView(IntrastatReportLine);
                IntrastatReportLines.SetRecord(IntrastatReportLine);
                if IntrastatReportLines.RunModal() = Action::LookupOK then begin
                    IntrastatReportLines.GetRecord(IntrastatReportLine);
                    Validate("Corrected Document No.", IntrastatReportLine."Document No.");
                end;
            end;

            trigger OnValidate()
            var
                IntrastatReportLine: Record "Intrastat Report Line";
            begin
                if "Corrected Document No." <> '' then begin
                    IntrastatReportHeader.CheckEUServAndCorrection("Intrastat No.", false, true);
                    IntrastatReportLine.SetRange("Intrastat No.", "Corrected Intrastat Report No.");
                    IntrastatReportLine.SetRange("Document No.", "Corrected Document No.");
                    if IntrastatReportLine.IsEmpty() then
                        Error(
                          NoDocumentNumberWithinTheFilterErr, FieldCaption("Document No."), "Document No.", IntrastatReportLine.GetFilters);
                end;
            end;
        }
        field(100; "Record ID Filter"; Text[250])
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Intrastat No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Source Type", "Source Entry No.")
        {
        }
        key(Key3; "Document No.")
        {
        }
        key(Key4; "Intrastat No.", Type, "Internal Ref. No.")
        {
        }
        key(Key5; "Intrastat No.", Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method", "Country/Region of Origin Code", "Partner VAT ID")
        {
        }
        key(Key6; "Intrastat No.", Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method", "Area", "Transaction Specification", "Country/Region of Origin Code", "Partner VAT ID")
        {
        }
        key(Key7; "Intrastat No.", Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method", "Transaction Specification", "Area", "Country/Region of Origin Code", "Partner VAT ID")
        {
        }
        key(Key8; Type, "Country/Region Code", "Partner VAT ID", "Transaction Type", "Tariff No.", "Group Code", "Transport Method", "Transaction Specification", "Country/Region of Origin Code", "Area", "Corrective entry")
        {
        }
        key(Key9; "Intrastat No.", Type)
        {
        }
        key(Key10; "Partner VAT ID", "Transaction Type", "Tariff No.", "Group Code", "Transport Method", "Transaction Specification", "Country/Region of Origin Code", "Area", "Corrective entry")
        {
        }
    }

    trigger OnDelete()
    var
        ErrorMessage: Record "Error Message";
    begin
        CheckHeaderStatusOpen();
        ErrorMessage.SetContext(IntrastatReportHeader);
        ErrorMessage.ClearLogRec(Rec);
    end;

    trigger OnInsert()
    begin
        CheckHeaderStatusOpen();
    end;

    trigger OnModify()
    begin
        CheckHeaderStatusOpen();
        Correction := true;
    end;

    trigger OnRename()
    begin
        xRec.CheckHeaderStatusOpen();
    end;

    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Item: Record Item;
        FixedAsset: Record "Fixed Asset";
        TariffNumber: Record "Tariff Number";
        DateNotInRageErr: Label 'Date %1 is not within the reporting period.', Comment = '%1 - Date';
        NoDocumentNumberWithinTheFilterErr: Label 'There is no %1 %2 with in the filter.\\Filters: %3', Comment = '%1 - Document No. caption, %2 - Document No., %3 - Filters';

    local procedure GetTariffDescription()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetItemDescription(IsHandled, Rec);
        if IsHandled then
            exit;

        if "Tariff No." <> '' then begin
            TariffNumber.Get("Tariff No.");
            "Tariff Description" := TariffNumber.Description;
        end else
            "Tariff Description" := '';
    end;

    procedure CheckHeaderStatusOpen()
    begin
        IntrastatReportHeader.Get(Rec."Intrastat No.");
        IntrastatReportHeader.CheckStatusOpen();
    end;

    procedure GetCountryOfOriginCode() CountryOfOriginCode: Code[10]
    var
        CompanyInformation: Record "Company Information";
        ItemLedgEntry: Record "Item Ledger Entry";
        JobLedgerEntry: Record "Job Ledger Entry";
        PackageNoInformation: Record "Package No. Information";
        SerialNoInformation: Record "Serial No. Information";
        LotNoInformation: Record "Lot No. Information";
        SerialNo, LotNo, PackageNo : Code[50];
        ItemNo: Code[20];
        VariantCode: Code[10];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetCountryOfOriginCode(Rec, CountryOfOriginCode, IsHandled);

        if IsHandled then
            exit(CountryOfOriginCode);

        if "Source Type" = "Source Type"::"FA Entry" then begin
            if FixedAsset.Get("Item No.") then
                CountryOfOriginCode := FixedAsset."Country/Region of Origin Code"
        end else begin
            ItemNo := "Item No.";
            if "Source Type" = "Source Type"::"Item Entry" then begin
                ItemLedgEntry.SetLoadFields("Item No.", "Variant Code", "Serial No.", "Lot No.", "Package No.");
                if ItemLedgEntry.Get("Source Entry No.") then begin
                    ItemNo := ItemLedgEntry."Item No.";
                    VariantCode := ItemLedgEntry."Variant Code";
                    SerialNo := ItemLedgEntry."Serial No.";
                    LotNo := ItemLedgEntry."Lot No.";
                    PackageNo := ItemLedgEntry."Package No.";
                end;
            end;
            if "Source Type" = "Source Type"::"Job Entry" then begin
                JobLedgerEntry.SetLoadFields("No.", "Variant Code", "Serial No.", "Lot No.", "Package No.");
                if JobLedgerEntry.Get("Source Entry No.") then begin
                    ItemNo := JobLedgerEntry."No.";
                    VariantCode := JobLedgerEntry."Variant Code";
                    SerialNo := JobLedgerEntry."Serial No.";
                    LotNo := JobLedgerEntry."Lot No.";
                    PackageNo := JobLedgerEntry."Package No.";
                end;
            end;
            if SerialNo <> '' then
                if SerialNoInformation.Get(ItemNo, VariantCode, SerialNo) then
                    CountryOfOriginCode := SerialNoInformation."Country/Region Code";
            if (CountryOfOriginCode = '') and (LotNo <> '') then
                if LotNoInformation.Get(ItemNo, VariantCode, LotNo) then
                    CountryOfOriginCode := LotNoInformation."Country/Region Code";
            if (CountryOfOriginCode = '') and (PackageNo <> '') then
                if PackageNoInformation.Get(ItemNo, VariantCode, PackageNo) then
                    CountryOfOriginCode := PackageNoInformation."Country/Region Code";
            if CountryOfOriginCode = '' then
                if Item.Get(ItemNo) then
                    CountryOfOriginCode := Item."Country/Region of Origin Code";
        end;

        if CountryOfOriginCode = '' then begin
            CompanyInformation.Get();
            if CompanyInformation."Country/Region Code" <> '' then
                CountryOfOriginCode := CompanyInformation."Country/Region Code"
        end;

        OnAfterGetCountryOfOriginCode(Rec, CountryOfOriginCode);
    end;

    procedure GetPartnerID() PartnerID: Text[50]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetPartnerID(Rec, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        case "Source Type" of
            "Source Type"::"Job Entry":
                exit(GetPartnerIDFromJobEntry());
            "Source Type"::"Item Entry":
                exit(GetPartnerIDFromItemEntry());
            "Source Type"::"FA Entry":
                exit(GetPartnerIDFromFAEntry());
        end;
    end;

    local procedure GetPartnerIDFromItemEntry(): Text[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
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
        Customer: Record Customer;
        Vendor: Record Vendor;
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        EU3rdPartyTrade: Boolean;
        IsHandled: Boolean;
        PartnerID: Text[50];
    begin
        IsHandled := false;
        OnBeforeGetPartnerIDFromItemEntry(Rec, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        if not ItemLedgerEntry.Get("Source Entry No.") then
            exit('');

        IntrastatReportSetup.GetSetup();

        case ItemLedgerEntry."Document Type" of
            ItemLedgerEntry."Document Type"::"Sales Invoice":
                if SalesInvoiceHeader.Get(ItemLedgerEntry."Document No.") then begin
                    if not Customer.Get(IntrastatReportSetup.GetPartnerNo(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Bill-to Customer No.")) then
                        exit('');
                    EU3rdPartyTrade := SalesInvoiceHeader."EU 3-Party Trade";
                end;
            ItemLedgerEntry."Document Type"::"Sales Credit Memo":
                if SalesCrMemoHeader.Get(ItemLedgerEntry."Document No.") then begin
                    if not Customer.Get(IntrastatReportSetup.GetPartnerNo(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Bill-to Customer No.")) then
                        exit('');
                    EU3rdPartyTrade := SalesCrMemoHeader."EU 3-Party Trade";
                end;
            ItemLedgerEntry."Document Type"::"Sales Shipment":
                if SalesShipmentHeader.Get(ItemLedgerEntry."Document No.") then begin
                    if not Customer.Get(IntrastatReportSetup.GetPartnerNo(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Bill-to Customer No.")) then
                        exit('');
                    EU3rdPartyTrade := SalesShipmentHeader."EU 3-Party Trade";
                end;
            ItemLedgerEntry."Document Type"::"Sales Return Receipt":
                if ReturnReceiptHeader.Get(ItemLedgerEntry."Document No.") then begin
                    if not Customer.Get(IntrastatReportSetup.GetPartnerNo(ReturnReceiptHeader."Sell-to Customer No.", ReturnReceiptHeader."Bill-to Customer No.")) then
                        exit('');
                    EU3rdPartyTrade := ReturnReceiptHeader."EU 3-Party Trade";
                end;
            ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoHdr.Get(ItemLedgerEntry."Document No.") then
                    if not Vendor.Get(IntrastatReportSetup.GetPartnerNo(PurchCrMemoHdr."Buy-from Vendor No.", PurchCrMemoHdr."Pay-to Vendor No.")) then
                        exit('');
            ItemLedgerEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    if not Vendor.Get(IntrastatReportSetup.GetPartnerNo(ReturnShipmentHeader."Buy-from Vendor No.", ReturnShipmentHeader."Pay-to Vendor No.")) then
                        exit('');
            ItemLedgerEntry."Document Type"::"Purchase Invoice":
                if PurchInvHeader.Get(ItemLedgerEntry."Document No.") then
                    if not Vendor.Get(IntrastatReportSetup.GetPartnerNo(PurchInvHeader."Buy-from Vendor No.", PurchInvHeader."Pay-to Vendor No.")) then
                        exit('');
            ItemLedgerEntry."Document Type"::"Purchase Receipt":
                if PurchRcptHeader.Get(ItemLedgerEntry."Document No.") then
                    if not Vendor.Get(IntrastatReportSetup.GetPartnerNo(PurchRcptHeader."Buy-from Vendor No.", PurchRcptHeader."Pay-to Vendor No.")) then
                        exit('');
            ItemLedgerEntry."Document Type"::"Service Shipment":
                if ServiceShipmentHeader.Get(ItemLedgerEntry."Document No.") then begin
                    if not Customer.Get(IntrastatReportSetup.GetPartnerNo(ServiceShipmentHeader."Customer No.", ServiceShipmentHeader."Bill-to Customer No.")) then
                        exit('');
                    EU3rdPartyTrade := ServiceShipmentHeader."EU 3-Party Trade";
                end;
            ItemLedgerEntry."Document Type"::"Service Invoice":
                if ServiceInvoiceHeader.Get(ItemLedgerEntry."Document No.") then begin
                    if not Customer.Get(IntrastatReportSetup.GetPartnerNo(ServiceInvoiceHeader."Customer No.", ServiceInvoiceHeader."Bill-to Customer No.")) then
                        exit('');
                    EU3rdPartyTrade := ServiceInvoiceHeader."EU 3-Party Trade";
                end;
            ItemLedgerEntry."Document Type"::"Service Credit Memo":
                if ServiceCrMemoHeader.Get(ItemLedgerEntry."Document No.") then begin
                    if not Customer.Get(IntrastatReportSetup.GetPartnerNo(ServiceCrMemoHeader."Customer No.", ServiceCrMemoHeader."Bill-to Customer No.")) then
                        exit('');
                    EU3rdPartyTrade := ServiceCrMemoHeader."EU 3-Party Trade";
                end;
            ItemLedgerEntry."Document Type"::"Transfer Receipt":
                if TransferReceiptHeader.Get(ItemLedgerEntry."Document No.") then
                    exit(GetPartnerIDForCountry(ItemLedgerEntry."Country/Region Code", TransferReceiptHeader."Partner VAT ID", false, false));
            ItemLedgerEntry."Document Type"::"Transfer Shipment":
                if TransferShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    exit(GetPartnerIDForCountry(ItemLedgerEntry."Country/Region Code", TransferShipmentHeader."Partner VAT ID", false, false));
        end;

        case ItemLedgerEntry."Source Type" of
            ItemLedgerEntry."Source Type"::Customer:
                begin
                    if Customer."No." = '' then
                        if not Customer.Get(ItemLedgerEntry."Source No.") then
                            exit('');

                    IsHandled := false;
                    OnBeforeGetCustomerPartnerIDFromItemEntry(Customer, EU3rdPartyTrade, PartnerID, IsHandled);
                    if IsHandled then
                        exit(PartnerID);

                    exit(
                      GetPartnerIDForCountry(
                        Customer."Country/Region Code",
                        IntrastatReportMgt.GetVATRegNo(
                            Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
                            IntrastatReportMgt.IsCustomerPrivatePerson(Customer), EU3rdPartyTrade));
                end;
            ItemLedgerEntry."Source Type"::Vendor:
                begin
                    if Vendor."No." = '' then
                        if not Vendor.Get(ItemLedgerEntry."Source No.") then
                            exit('');

                    IsHandled := false;
                    OnBeforeGetVendorPartnerIDFromItemEntry(Vendor, PartnerID, IsHandled);
                    if IsHandled then
                        exit(PartnerID);

                    exit(
                      GetPartnerIDForCountry(
                        Vendor."Country/Region Code",
                        IntrastatReportMgt.GetVATRegNo(
                            Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
                            IntrastatReportMgt.IsVendorPrivatePerson(Vendor), false));
                end;
        end;
    end;

    local procedure GetPartnerIDFromJobEntry(): Text[50]
    var
        Job: Record Job;
        JobLedgerEntry: Record "Job Ledger Entry";
        Customer: Record Customer;
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        IsHandled: Boolean;
        PartnerID: Text[50];
    begin
        IsHandled := false;
        OnBeforeGetPartnerIDFromJobEntry(Rec, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        if not JobLedgerEntry.Get("Source Entry No.") then
            exit('');
        if not Job.Get(JobLedgerEntry."Job No.") then
            exit('');
        if not Customer.Get(IntrastatReportSetup.GetPartnerNo(Job."Sell-to Customer No.", Job."Bill-to Customer No.")) then
            exit('');

        IntrastatReportSetup.GetSetup();

        IsHandled := false;
        OnBeforeGetCustomerPartnerIDFromJobEntry(Customer, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        exit(
          GetPartnerIDForCountry(
            Customer."Country/Region Code",
            IntrastatReportMgt.GetVATRegNo(
                Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
                IntrastatReportMgt.IsCustomerPrivatePerson(Customer), false));
    end;

    local procedure GetPartnerIDFromFAEntry(): Text[50]
    var
        FALedgerEntry: Record "FA Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        Vendor: Record Vendor;
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        IsHandled: Boolean;
        PartnerID: Text[50];
    begin
        IsHandled := false;
        OnBeforeGetPartnerIDFromFAEntry(Rec, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        if not FALedgerEntry.Get("Source Entry No.") then
            exit('');

        case FALedgerEntry."Document Type" of
            FALedgerEntry."Document Type"::Invoice:
                if PurchInvHeader.Get(FALedgerEntry."Document No.") then
                    if not Vendor.Get(IntrastatReportSetup.GetPartnerNo(PurchInvHeader."Buy-from Vendor No.", PurchInvHeader."Pay-to Vendor No.")) then
                        exit('');
            FALedgerEntry."Document Type"::"Credit Memo":
                if PurchCrMemoHdr.Get(FALedgerEntry."Document No.") then
                    if not Vendor.Get(IntrastatReportSetup.GetPartnerNo(PurchCrMemoHdr."Buy-from Vendor No.", PurchCrMemoHdr."Pay-to Vendor No.")) then
                        exit('');
        end;

        IntrastatReportSetup.GetSetup();

        IsHandled := false;
        OnBeforeGetVendorPartnerIDFromFAEntry(Vendor, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        exit(
          GetPartnerIDForCountry(
            Vendor."Country/Region Code",
            IntrastatReportMgt.GetVATRegNo(
                Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
                IntrastatReportMgt.IsVendorPrivatePerson(Vendor), false));
    end;

    local procedure GetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean): Text[50]
    var
        CountryRegion: Record "Country/Region";
        PartnerID: Text[50];
        IsHandled: Boolean;
    begin
        OnBeforeGetPartnerIDForCountry(CountryRegionCode, VATRegistrationNo, IsPrivatePerson, IsThirdPartyTrade, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        IntrastatReportSetup.GetSetup();
        if IsPrivatePerson then
            exit(IntrastatReportSetup."Def. Private Person VAT No.");

        if IsThirdPartyTrade then
            exit(IntrastatReportSetup."Def. 3-Party Trade VAT No.");

        if (CountryRegionCode <> '') and CountryRegion.Get(CountryRegionCode) then
            if CountryRegion.IsEUCountry(CountryRegionCode) then
                if VATRegistrationNo <> '' then
                    exit(VATRegistrationNo);

        exit(IntrastatReportSetup."Def. VAT for Unknown State");
    end;

    procedure SetIntrastatReportHeaderFilters(var IntrastatReportHeader2: Record "Intrastat Report Header")
    var
        IntrastatReportHeader3: Record "Intrastat Report Header";
    begin
        IntrastatReportHeader3.Get("Intrastat No.");
        IntrastatReportHeader2.SetRange("Corrective Entry", false);
        IntrastatReportHeader2.SetRange(Reported, true);
        IntrastatReportHeader2.SetRange("EU Service", IntrastatReportHeader3."EU Service");
        IntrastatReportHeader2.SetRange(Periodicity, IntrastatReportHeader3.Periodicity);
        IntrastatReportHeader2.SetRange(Type, IntrastatReportHeader3.Type);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCountryOfOriginCode(var IntrastatReportLine: Record "Intrastat Report Line"; var CountryOfOriginCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCountryOfOriginCode(var IntrastatReportLine: Record "Intrastat Report Line"; var CountryOfOriginCode: Code[10])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetItemDescription(var IsHandled: Boolean; var IntrastatReportLine: Record "Intrastat Report Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerID(var IntrastatReportLine: Record "Intrastat Report Line"; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDFromItemEntry(var IntrastatReportLine: Record "Intrastat Report Line"; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustomerPartnerIDFromItemEntry(var Customer: Record Customer; EU3rdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetVendorPartnerIDFromItemEntry(var Vendor: Record Vendor; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDFromJobEntry(var IntrastatReportLine: Record "Intrastat Report Line"; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustomerPartnerIDFromJobEntry(var Customer: Record Customer; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDFromFAEntry(var IntrastatReportLine: Record "Intrastat Report Line"; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetVendorPartnerIDFromFAEntry(var Vendor: Record Vendor; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDateInRange(var IntrastatReportLine: Record "Intrastat Report Line"; var IsHandled: Boolean);
    begin
    end;
}