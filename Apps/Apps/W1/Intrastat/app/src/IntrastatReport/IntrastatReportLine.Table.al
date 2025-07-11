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
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
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
            ToolTip = 'Specifies whether the item was received or shipped by the company.';
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            ToolTip = 'Specifies the date the item entry was posted.';
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
            ToolTip = 'Specifies the item''s tariff number.';
            trigger OnValidate()
            begin
                GetTariffDescription();
            end;
        }
        field(6; "Tariff Description"; Text[250])
        {
            Caption = 'Tariff No. Description';
            ToolTip = 'Specifies the name of the tariff no. that is associated with the item.';
        }
        field(7; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            ToolTip = 'Specifies the country/region of the address.';
        }
        field(8; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
            ToolTip = 'Specifies the type of transaction that the document represents, for the purpose of reporting to Intrastat.';
        }
        field(9; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
            ToolTip = 'Specifies the transport method, for the purpose of reporting to Intrastat.';
        }
        field(10; "Source Type"; Enum "Intrastat Report Source Type")
        {
            BlankZero = true;
            Caption = 'Source Type';
            ToolTip = 'Specifies the entry type.';
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
            ToolTip = 'Specifies the number that the item entry had in the table it came from.';
        }
        field(12; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the net weight of one unit of the item.';
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
            ToolTip = 'Specifies the total amount of the entry, excluding VAT.';
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
            ToolTip = 'Specifies the number of units of the item in the entry.';
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
            ToolTip = 'Specifies any indirect costs, as a percentage.';
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
            ToolTip = 'Specifies an amount that represents the costs for freight and insurance.';
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
            ToolTip = 'Specifies the entry''s statistical value, which must be reported to the statistics authorities.';
        }
        field(18; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            ToolTip = 'Specifies the document number on the entry.';
        }
        field(19; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = if ("Source Type" = const("Item Entry")) Item else
            if ("Source Type" = const("Job Entry")) Item else
            if ("Source Type" = const("FA Entry")) "Fixed Asset";
            ToolTip = 'Specifies the number of the item.';
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
            ToolTip = 'Specifies the name of the item.';
        }
        field(21; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
            ToolTip = 'Specifies the total weight for the items in the item entry.';
        }
        field(22; "Supplementary Units"; Boolean)
        {
            Caption = 'Supplementary Units';
            Editable = false;
            ToolTip = 'Specifies if you must report information about quantity and units of measure for this item.';
        }
        field(23; "Internal Ref. No."; Text[10])
        {
            Caption = 'Internal Ref. No.';
            Editable = false;
            ToolTip = 'Specifies a reference number used by the customs and tax authorities.';
        }
        field(24; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            ToolTip = 'Specifies a code for the country/region where the item was produced or processed.';
        }
        field(25; "Entry/Exit Point"; Code[10])
        {
            Caption = 'Entry/Exit Point';
            TableRelation = "Entry/Exit Point";
            ToolTip = 'Specifies the code of either the port of entry where the items passed into your country/region or the port of exit.';
        }
        field(26; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
            ToolTip = 'Specifies the area of the customer or vendor, for the purpose of reporting to Intrastat.';
        }
        field(27; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
            ToolTip = 'Specifies a specification of the document''s transaction, for the purpose of reporting to Intrastat.';
        }
        field(28; "Shpt. Method Code"; Code[10])
        {
            Caption = 'Shpt. Method Code';
            TableRelation = "Shipment Method";
            ToolTip = 'Specifies the item''s shipment method.';
        }
        field(29; "Partner VAT ID"; Text[50])
        {
            Caption = 'VAT Reg. No.';
            ToolTip = 'Specifies the counter party''s VAT number.';
        }
        field(30; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            ToolTip = 'Specifies the code for the location that the entry is linked to.';
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
            ToolTip = 'Specifies the conversion factor of the item on this Intrastat report line.';
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
            ToolTip = 'Specifies the unit of measure code for the tariff number on this line.';
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
            ToolTip = 'Specifies the quantity of supplementary units on the Intrastat line.';
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
                IntrastatReportHeaderWithFiltersSet: Record "Intrastat Report Header";
            begin
                SetIntrastatReportHeaderFilters(IntrastatReportHeaderWithFiltersSet);
                IntrastatReportHeaderWithFiltersSet."No." := "Corrected Intrastat Report No.";
                if Page.RunModal(0, IntrastatReportHeaderWithFiltersSet, IntrastatReportHeaderWithFiltersSet."No.") = Action::LookupOK then
                    Validate("Corrected Intrastat Report No.", IntrastatReportHeaderWithFiltersSet."No.");
            end;

            trigger OnValidate()
            var
                IntrastatReportHeaderWithFiltersSet: Record "Intrastat Report Header";
            begin
                if "Corrected Intrastat Report No." <> '' then begin
                    IntrastatReportHeader.CheckEUServAndCorrection("Intrastat No.", false, true);
                    SetIntrastatReportHeaderFilters(IntrastatReportHeaderWithFiltersSet);
                    IntrastatReportHeaderWithFiltersSet.SetRange("No.", "Corrected Intrastat Report No.");
                    if not IntrastatReportHeaderWithFiltersSet.FindFirst() then
                        FieldError("Corrected Intrastat Report No.")
                    else
                        Validate("Reference Period", IntrastatReportHeaderWithFiltersSet."Statistics Period");
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
        key(Key2; "Source Type", "Source Entry No.") { }
        key(Key3; "Document No.") { }
        key(Key4; "Intrastat No.", Type, "Internal Ref. No.") { }
        key(Key5; "Intrastat No.", Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method", "Country/Region of Origin Code", "Partner VAT ID") { }
        key(Key6; "Intrastat No.", Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method", "Area", "Transaction Specification", "Country/Region of Origin Code", "Partner VAT ID") { }
        key(Key7; "Intrastat No.", Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method", "Transaction Specification", "Area", "Country/Region of Origin Code", "Partner VAT ID") { }
        key(Key8; Type, "Country/Region Code", "Partner VAT ID", "Transaction Type", "Tariff No.", "Group Code", "Transport Method", "Transaction Specification", "Country/Region of Origin Code", "Area", "Corrective entry") { }
        key(Key9; "Intrastat No.", Type) { }
        key(Key10; "Partner VAT ID", "Transaction Type", "Tariff No.", "Group Code", "Transport Method", "Transaction Specification", "Country/Region of Origin Code", "Area", "Corrective entry") { }
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
        TableNumbers: List of [Integer];
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
        TransferHeader: Record "Transfer Header";
        Customer: Record Customer;
        Vendor: Record Vendor;
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        DocRecRef: RecordRef;
        EU3rdPartyTrade: Boolean;
        IsHandled: Boolean;
        PartnerID: Text[50];
        PartnerNo: Code[20];
        TableNo: Integer;
    begin
        IsHandled := false;
        OnBeforeGetPartnerIDFromItemEntry(Rec, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        if not ItemLedgerEntry.Get("Source Entry No.") then
            exit('');

        IntrastatReportSetup.GetSetup();

        InitTableNumbers();
        if TableNumbers.Get(ItemLedgerEntry."Document Type".AsInteger(), TableNo) then begin
            DocRecRef.Open(TableNo);
            case ItemLedgerEntry."Document Type" of
                ItemLedgerEntry."Document Type"::"Transfer Receipt", ItemLedgerEntry."Document Type"::"Transfer Shipment":
                    begin
                        DocRecRef.Field(TransferHeader.FieldNo("No.")).SetRange(ItemLedgerEntry."Document No.");
                        DocRecRef.SetLoadFields(TransferHeader.FieldNo("Partner VAT ID"));
                        if DocRecRef.FindFirst() then
                            exit(GetPartnerIDForCountry(ItemLedgerEntry."Country/Region Code", DocRecRef.Field(TransferHeader.FieldNo("Partner VAT ID")).Value(), false, false));
                    end;
                ItemLedgerEntry."Document Type"::"Sales Shipment", ItemLedgerEntry."Document Type"::"Sales Invoice",
                ItemLedgerEntry."Document Type"::"Sales Return Receipt", ItemLedgerEntry."Document Type"::"Sales Credit Memo",
                ItemLedgerEntry."Document Type"::"Service Shipment", ItemLedgerEntry."Document Type"::"Service Invoice",
                ItemLedgerEntry."Document Type"::"Service Credit Memo":
                    PartnerID := GetVATNoOrSource("Intrastat Report Type"::Sales, ItemLedgerEntry."Document No.", DocRecRef, PartnerNo, EU3rdPartyTrade);
                ItemLedgerEntry."Document Type"::"Purchase Receipt", ItemLedgerEntry."Document Type"::"Purchase Invoice",
                ItemLedgerEntry."Document Type"::"Purchase Return Shipment", ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                    PartnerID := GetVATNoOrSource("Intrastat Report Type"::Purchases, ItemLedgerEntry."Document No.", DocRecRef, PartnerNo, EU3rdPartyTrade);
            end;
        end;

        if PartnerID <> '' then
            exit(PartnerID);

        if PartnerNo = '' then
            PartnerNo := ItemLedgerEntry."Source No.";

        case ItemLedgerEntry."Source Type" of
            ItemLedgerEntry."Source Type"::Customer:
                begin
                    if not Customer.Get(PartnerNo) then
                        exit('');

                    IsHandled := false;
                    OnBeforeGetCustomerPartnerIDFromItemEntry(Customer, EU3rdPartyTrade, PartnerID, IsHandled);
                    if IsHandled then
                        exit(PartnerID);

                    exit(GetPartnerIDForCountry(Customer."Country/Region Code", IntrastatReportMgt.GetVATRegNo(Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
                        IntrastatReportMgt.IsCustomerPrivatePerson(Customer), EU3rdPartyTrade));
                end;
            ItemLedgerEntry."Source Type"::Vendor:
                begin
                    if not Vendor.Get(PartnerNo) then
                        exit('');

                    IsHandled := false;
                    OnBeforeGetVendorPartnerIDFromItemEntry(Vendor, PartnerID, IsHandled);
                    if IsHandled then
                        exit(PartnerID);

                    exit(GetPartnerIDForCountry(Vendor."Country/Region Code", IntrastatReportMgt.GetVATRegNo(Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
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

        IntrastatReportSetup.GetSetup();
        case IntrastatReportSetup."Project VAT No. Based On" of
            IntrastatReportSetup."Project VAT No. Based On"::"Sell-to Customer":
                if not Customer.Get(Job."Sell-to Customer No.") then
                    exit('');
            IntrastatReportSetup."Project VAT No. Based On"::"Bill-to Customer":
                if not Customer.Get(Job."Bill-to Customer No.") then
                    exit('');
        end;

        IsHandled := false;
        OnBeforeGetCustomerPartnerIDFromJobEntry(Customer, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        exit(GetPartnerIDForCountry(Customer."Country/Region Code", IntrastatReportMgt.GetVATRegNo(Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
            IntrastatReportMgt.IsCustomerPrivatePerson(Customer), false));
    end;

    local procedure GetPartnerIDFromFAEntry(): Text[50]
    var
        FALedgerEntry: Record "FA Ledger Entry";
        Vendor: Record Vendor;
        Customer: Record Customer;
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        DocRecRef: RecordRef;
        IsHandled, EU3rdPartyTrade : Boolean;
        PartnerID: Text[50];
        PartnerNo: Code[20];
    begin
        IsHandled := false;
        OnBeforeGetPartnerIDFromFAEntry(Rec, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        if not FALedgerEntry.Get("Source Entry No.") then
            exit('');

        IntrastatReportSetup.GetSetup();

        case true of
            (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Acquisition Cost") and (FALedgerEntry."Document Type" = FALedgerEntry."Document Type"::Invoice):
                DocRecRef.Open(Database::"Purch. Inv. Header");
            (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Acquisition Cost") and (FALedgerEntry."Document Type" = FALedgerEntry."Document Type"::"Credit Memo"):
                DocRecRef.Open(Database::"Purch. Cr. Memo Hdr.");
            (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Proceeds on Disposal") and (FALedgerEntry."Document Type" = FALedgerEntry."Document Type"::Invoice):
                DocRecRef.Open(Database::"Sales Invoice Header");
            (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Proceeds on Disposal") and (FALedgerEntry."Document Type" = FALedgerEntry."Document Type"::"Credit Memo"):
                DocRecRef.Open(Database::"Sales Cr.Memo Header");
            else
                exit('');
        end;

        case DocRecRef.Number of
            Database::"Purch. Inv. Header", Database::"Purch. Cr. Memo Hdr.":
                begin
                    PartnerID := GetVATNoOrSource("Intrastat Report Type"::Purchases, FALedgerEntry."Document No.", DocRecRef, PartnerNo, EU3rdPartyTrade);
                    if PartnerID <> '' then
                        exit(PartnerID);

                    if not Vendor.Get(PartnerNo) then
                        exit('');

                    IsHandled := false;
                    OnBeforeGetVendorPartnerIDFromFAEntry(Vendor, PartnerID, IsHandled);
                    if IsHandled then
                        exit(PartnerID);

                    exit(GetPartnerIDForCountry(Vendor."Country/Region Code", IntrastatReportMgt.GetVATRegNo(Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
                        IntrastatReportMgt.IsVendorPrivatePerson(Vendor), false));
                end;
            Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header":
                begin
                    PartnerID := GetVATNoOrSource("Intrastat Report Type"::Sales, FALedgerEntry."Document No.", DocRecRef, PartnerNo, EU3rdPartyTrade);
                    if PartnerID <> '' then
                        exit(PartnerID);

                    if not Customer.Get(PartnerNo) then
                        exit('');

                    IsHandled := false;
                    OnBeforeGetCustomerPartnerIDFromFAEntry(Customer, PartnerID, IsHandled);
                    if IsHandled then
                        exit(PartnerID);

                    exit(GetPartnerIDForCountry(Customer."Country/Region Code", IntrastatReportMgt.GetVATRegNo(Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
                        IntrastatReportMgt.IsCustomerPrivatePerson(Customer), EU3rdPartyTrade));
                end;
        end;
    end;

    local procedure GetVATNoOrSource(DocumentType: Enum "Intrastat Report Type"; DocumentNo: Code[20]; var DocRecRef: RecordRef; var PartnerNo: Code[20]; var EU3rdPartyTrade: Boolean): Text[50]
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
    begin
        case DocumentType of
            DocumentType::Purchases:
                begin
                    DocRecRef.Field(PurchaseHeader.FieldNo("No.")).SetRange(DocumentNo);
                    DocRecRef.SetLoadFields(PurchaseHeader.FieldNo("Buy-from Vendor No."), PurchaseHeader.FieldNo("Pay-to Vendor No."), PurchaseHeader.FieldNo("VAT Registration No."), PurchaseHeader.FieldNo("VAT Country/Region Code"));
                    if DocRecRef.FindFirst() then
                        case IntrastatReportSetup."Purchase VAT No. Based On" of
                            IntrastatReportSetup."Purchase VAT No. Based On"::Document:
                                exit(IntrastatReportMgt.GetVATRegNo(DocRecRef.Field(PurchaseHeader.FieldNo("VAT Country/Region Code")).Value(), DocRecRef.Field(PurchaseHeader.FieldNo("VAT Registration No.")).Value(), IntrastatReportSetup."Vend. VAT No. on File"));
                            IntrastatReportSetup."Purchase VAT No. Based On"::"Buy-from VAT":
                                PartnerNo := DocRecRef.Field(PurchaseHeader.FieldNo("Buy-from Vendor No.")).Value();
                            IntrastatReportSetup."Purchase VAT No. Based On"::"Pay-to VAT":
                                PartnerNo := DocRecRef.Field(PurchaseHeader.FieldNo("Pay-to Vendor No.")).Value();
                        end;
                end;
            DocumentType::Sales:
                begin
                    DocRecRef.Field(SalesHeader.FieldNo("No.")).SetRange(DocumentNo);
                    DocRecRef.SetLoadFields(SalesHeader.FieldNo("Sell-to Customer No."), SalesHeader.FieldNo("Bill-to Customer No."), SalesHeader.FieldNo("VAT Registration No."), SalesHeader.FieldNo("EU 3-Party Trade"), SalesHeader.FieldNo("VAT Country/Region Code"));
                    if DocRecRef.FindFirst() then begin
                        case IntrastatReportSetup."Sales VAT No. Based On" of
                            IntrastatReportSetup."Sales VAT No. Based On"::Document:
                                exit(IntrastatReportMgt.GetVATRegNo(DocRecRef.Field(SalesHeader.FieldNo("VAT Country/Region Code")).Value(), DocRecRef.Field(SalesHeader.FieldNo("VAT Registration No.")).Value(), IntrastatReportSetup."Cust. VAT No. on File"));
                            IntrastatReportSetup."Sales VAT No. Based On"::"Sell-to VAT":
                                PartnerNo := DocRecRef.Field(SalesHeader.FieldNo("Sell-to Customer No.")).Value();
                            IntrastatReportSetup."Sales VAT No. Based On"::"Bill-to VAT":
                                PartnerNo := DocRecRef.Field(SalesHeader.FieldNo("Bill-to Customer No.")).Value();
                        end;
                        EU3rdPartyTrade := DocRecRef.Field(SalesHeader.FieldNo("EU 3-Party Trade")).Value();
                    end;
                end;
        end;
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

    procedure SetIntrastatReportHeaderFilters(var IntrastatReportHeaderWithFiltersSet: Record "Intrastat Report Header")
    var
        IntrastatReportHeaderForLine: Record "Intrastat Report Header";
    begin
        IntrastatReportHeaderForLine.SetLoadFields("EU Service", Periodicity, Type);
        IntrastatReportHeaderForLine.Get("Intrastat No.");
        IntrastatReportHeaderWithFiltersSet.SetRange("Corrective Entry", false);
        IntrastatReportHeaderWithFiltersSet.SetRange(Reported, true);
        IntrastatReportHeaderWithFiltersSet.SetRange("EU Service", IntrastatReportHeaderForLine."EU Service");
        IntrastatReportHeaderWithFiltersSet.SetRange(Periodicity, IntrastatReportHeaderForLine.Periodicity);
        IntrastatReportHeaderWithFiltersSet.SetRange(Type, IntrastatReportHeaderForLine.Type);

        OnAfterSetIntrastatReportHeaderFilters(IntrastatReportHeaderWithFiltersSet, IntrastatReportHeaderForLine);
    end;

    local procedure InitTableNumbers()
    begin
        if TableNumbers.Count() = 0 then
            TableNumbers.AddRange(Database::"Sales Shipment Header", Database::"Sales Invoice Header",
                Database::"Return Receipt Header", Database::"Sales Cr.Memo Header",
                Database::"Purch. Rcpt. Header", Database::"Purch. Inv. Header",
                Database::"Return Shipment Header", Database::"Purch. Cr. Memo Hdr.",
                Database::"Transfer Shipment Header", Database::"Transfer Receipt Header",
                Database::"Service Shipment Header", Database::"Service Invoice Header",
                Database::"Service Cr.Memo Header");
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
    local procedure OnBeforeGetCustomerPartnerIDFromFAEntry(var Customer: Record Customer; var PartnerID: Text[50]; var IsHandled: Boolean)
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

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetIntrastatReportHeaderFilters(var IntrastatReportHeaderWithFiltersSet: Record "Intrastat Report Header"; IntrastatReportHeaderForLine: Record "Intrastat Report Header")
    begin
    end;
}