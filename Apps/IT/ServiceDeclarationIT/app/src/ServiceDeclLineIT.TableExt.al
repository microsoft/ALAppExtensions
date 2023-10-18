// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.History;
using Microsoft.Inventory.Intrastat;

tableextension 12216 "Service Decl. Line IT" extends "Service Declaration Line"
{
    LookupPageId = "Serv. Decl. Lines IT";
    DrillDownPageId = "Serv. Decl. Lines IT";

    fields
    {
        field(12214; "Company/Representative VAT No."; Text[20])
        {
            Caption = 'Company/Representative VAT No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12215; "File Disk No."; Code[20])
        {
            Caption = 'File Disk No.';
            Editable = false;
            Numeric = true;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Declaration Header"."File Disk No." where("No." = field("Service Declaration No.")));
        }
        field(12216; "Export Line No."; Code[5])
        {
            Caption = 'Export Line No.';
        }
        field(12217; "Document Date"; Date)
        {
            Caption = 'Document Date';

            trigger OnValidate()
            begin
                if "Document Date" <> 0D then
                    "Document Date Code" := Format("Document Date", 0, '<Day,2><Month,2><Year,2>')
                else
                    "Document Date Code" := '';
            end;
        }
        field(12218; "Document Date Code"; Code[8])
        {
            Caption = 'Document Date Code';
            Editable = false;
        }
        field(12219; "Source Entry No."; Integer)
        {
            Caption = 'Source Entry No.';
            TableRelation = "VAT Entry";

            trigger OnLookup()
            begin
                LookUpSourceEntryNo();
            end;

            trigger OnValidate()
            var
                VATEntry: Record "VAT Entry";
            begin
                SetVATEntryFilters(VATEntry);
                VATEntry.SetRange("Entry No.", "Source Entry No.");
                if not VATEntry.FindFirst() then
                    Error(NoEntryWithinFilterErr, VATEntry.FieldCaption("Entry No."), VATEntry.GetFilters)
                else
                    ValidateSourceEntryNo("Source Entry No.");
            end;
        }
        field(12220; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(12221; "Source Currency Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Source Currency Amount';
        }
        field(12222; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(12223; "Statistics Period"; Code[10])
        {
            Caption = 'Statistics Period';
        }
        field(12224; "Service Tariff No."; Code[10])
        {
            Caption = 'Service Tariff No.';
            TableRelation = "Service Tariff Number";
        }
        field(12225; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(12226; "Payment Method"; Code[10])
        {
            Caption = 'Payment Method';
        }
        field(12227; "Country/Region of Payment Code"; Code[10])
        {
            Caption = 'Country/Region of Payment Code';
            TableRelation = "Country/Region";
        }
        field(12228; "Corrective Entry"; Boolean)
        {
            Caption = 'Corrective Entry';
        }
        field(12229; "Custom Office No."; Code[6])
        {
            Caption = 'Custom Office No.';
            TableRelation = "Customs Office";

            trigger OnValidate()
            begin
                if "Custom Office No." <> '' then begin
                    ServiceDeclarationHeader.Get("Service Declaration No.");
                    ServiceDeclarationHeader.TestField("Corrective Entry", true);
                end;
            end;
        }
        field(12230; "Corrected Service Declaration No."; Code[20])
        {
            Caption = 'Corrected Service Declaration No.';

            trigger OnLookup()
            var
                ServiceDeclarationHeader2: Record "Service Declaration Header";
            begin
                SetServiceDeclarationHeaderFilters(ServiceDeclarationHeader2);
                ServiceDeclarationHeader2."No." := "Corrected Service Declaration No.";
                if Page.RunModal(0, ServiceDeclarationHeader2, ServiceDeclarationHeader2."No.") = Action::LookupOK then
                    Validate("Corrected Service Declaration No.", ServiceDeclarationHeader2."No.");
            end;

            trigger OnValidate()
            var
                ServiceDeclarationHeader2: Record "Service Declaration Header";
            begin
                if "Corrected Service Declaration No." <> '' then begin
                    SetServiceDeclarationHeaderFilters(ServiceDeclarationHeader2);
                    ServiceDeclarationHeader2.SetRange("No.", "Corrected Service Declaration No.");
                    if not ServiceDeclarationHeader2.FindFirst() then
                        FieldError("Corrected Service Declaration No.")
                    else
                        Validate("Reference Period", ServiceDeclarationHeader2."Statistics Period");
                end;
            end;
        }
        field(12231; "Corrected Document No."; Code[20])
        {
            Caption = 'Corrected Document No.';

            trigger OnLookup()
            var
                ServiceDeclarationLine: Record "Service Declaration Line";
                ServDeclLines: Page "Serv. Decl. Lines IT";
            begin
                ServDeclLines.LookupMode := true;
                ServiceDeclarationLine.SetRange("Service Declaration No.", "Corrected Service Declaration No.");
                ServDeclLines.SetTableView(ServiceDeclarationLine);
                ServDeclLines.SetRecord(ServiceDeclarationLine);
                if ServDeclLines.RunModal() = Action::LookupOK then begin
                    ServDeclLines.GetRecord(ServiceDeclarationLine);
                    Validate("Corrected Document No.", ServiceDeclarationLine."Document No.");
                end;
            end;

            trigger OnValidate()
            var
                ServiceDeclarationLine: Record "Service Declaration Line";
            begin
                if "Corrected Document No." <> '' then begin
                    ServiceDeclarationLine.SetRange("Service Declaration No.", "Corrected Service Declaration No.");
                    ServiceDeclarationLine.SetRange("Document No.", "Corrected Document No.");
                    if not ServiceDeclarationLine.FindFirst() then
                        Error(NoEntryWithinFilterErr, FieldCaption("Document No."), ServiceDeclarationLine.GetFilters);
                end;
            end;
        }
        field(12232; "Reference Period"; Code[10])
        {
            Caption = 'Reference Period';
            Numeric = true;
        }
        field(12233; "Ref. File Disk No."; Code[20])
        {
            Caption = 'Reference File Disk No.';
            Editable = false;
            Numeric = true;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Declaration Header"."File Disk No." where("No." = field("Corrected Service Declaration No.")));
        }
        field(12234; "Progressive No."; Code[5])
        {
            Caption = 'Progressive No.';
        }
    }

    keys
    {
        key(KeyIT1; "VAT Reg. No.")
        {
        }
    }

    var
        ServiceDeclarationHeader: Record "Service Declaration Header";
        NoEntryWithinFilterErr: Label 'There is no %1 with in the filter.\\Filters: %2', Comment = '%1 - Entry No., %2 - Filters applied';

    local procedure LookUpSourceEntryNo()
    var
        VATEntry: Record "VAT Entry";
        VATEntries: Page "VAT Entries";
    begin
        VATEntries.LookupMode := true;
        SetVATEntryFilters(VATEntry);
        VATEntries.SetTableView(VATEntry);
        VATEntries.SetRecord(VATEntry);
        if VATEntries.RunModal() = Action::LookupOK then begin
            VATEntries.GetRecord(VATEntry);
            Validate("Source Entry No.", VATEntry."Entry No.");
        end;
    end;

    internal procedure ValidateSourceEntryNo(SourceEntryNo: Integer)
    var
        Customer: Record Customer;
        ServDeclSetup: Record "Service Declaration Setup";
        GLSetup: Record "General Ledger Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        ServCrMemoHeader: Record "Service Cr.Memo Header";
        VATEntry: Record "VAT Entry";
        VATEntry2: Record "VAT Entry";
        LocalServiceDeclarationMgt: Codeunit "Service Declaration Mgt. IT";
    begin
        GLSetup.Get();
        ServDeclSetup.Get();

        ServiceDeclarationHeader.Get(Rec."Service Declaration No.");
        if VATEntry.Get(SourceEntryNo) then begin
            "Company/Representative VAT No." := LocalServiceDeclarationMgt.GetCompanyRepresentativeVATNo();
            Validate("Document Date", VATEntry."Document Date");
            "Country/Region Code" := GetIntrastatCountryCode(VATEntry."Country/Region Code");
            "VAT Reg. No." := LocalServiceDeclarationMgt.RemoveLeadingCountryCode(VATEntry."VAT Registration No.", VATEntry."Country/Region Code");
            Amount := GetLineAmount(VATEntry);
            "Document No." := VATEntry."Document No.";
            "External Document No." := VATEntry."External Document No.";
            "Statistics Period" := ServiceDeclarationHeader."Statistics Period";
            "Service Tariff No." := VATEntry."Service Tariff No.";
            "Transport Method" := VATEntry."Transport Method";
            "Payment Method" := VATEntry."Payment Method";
            if VATEntry.Type = VATEntry.Type::Sale then begin
                if "VAT Reg. No." = '' then
                    if Customer.Get(VATEntry."Bill-to/Pay-to No.") and (Customer."Contact Type" = Customer."Contact Type"::Person) then
                        "VAT Reg. No." := ServDeclSetup."Def. Private Person VAT No."
                    else
                        "VAT Reg. No." := ServDeclSetup."Def. Customer/Vendor VAT No.";

                Amount := Round(Amount, GLSetup."Amount Rounding Precision");
                "Country/Region of Payment Code" := GetIntrastatCountryCode('');
                if VATEntry."Document Type" = VATEntry."Document Type"::"Credit Memo" then
                    if SalesCrMemoHeader.Get(VATEntry."Document No.") then begin
                        "Corrected Document No." := SalesCrMemoHeader."Applies-to Doc. No.";
                        VATEntry2.Reset();
                        VATEntry2.SetRange("Document No.", SalesCrMemoHeader."Applies-to Doc. No.");
                        if VATEntry2.FindFirst() then
                            "Reference Period" := Format(Date2DMY(VATEntry2."Operation Occurred Date", 3));
                    end else
                        if ServCrMemoHeader.Get(VATEntry."Document No.") then begin
                            "Corrected Document No." := ServCrMemoHeader."Applies-to Doc. No.";
                            VATEntry2.Reset();
                            VATEntry2.SetRange("Document No.", ServCrMemoHeader."Applies-to Doc. No.");
                            if VATEntry2.FindFirst() then
                                "Reference Period" := Format(Date2DMY(VATEntry2."Operation Occurred Date", 3));
                        end;
            end else
                if VATEntry.Type = VATEntry.Type::Purchase then begin
                    if "VAT Reg. No." = '' then
                        "VAT Reg. No." := ServDeclSetup."Def. Customer/Vendor VAT No.";

                    Amount := Round(Amount, GLSetup."Amount Rounding Precision");
                    "Country/Region of Payment Code" := GetIntrastatCountryCode(VATEntry."Country/Region Code");
                    if VATEntry."Document Type" = VATEntry."Document Type"::"Credit Memo" then
                        if PurchCrMemoHeader.Get(VATEntry."Document No.") then begin
                            "Corrected Document No." := PurchCrMemoHeader."Applies-to Doc. No.";
                            VATEntry2.Reset();
                            VATEntry2.SetRange("Document No.", PurchCrMemoHeader."Applies-to Doc. No.");
                            if VATEntry2.FindFirst() then
                                "Reference Period" := Format(Date2DMY(VATEntry2."Operation Occurred Date", 3));
                        end;
                    FindSourceCurrency(VATEntry."Bill-to/Pay-to No.", VATEntry."Document Date", VATEntry."Posting Date");
                end;
        end;
    end;

    local procedure SetVATEntryFilters(var VATEntry: Record "VAT Entry")
    var
        DateFilter: Text[30];
    begin
        ServiceDeclarationHeader.Get("Service Declaration No.");
        DateFilter := Format(ServiceDeclarationHeader."Starting Date") + '..' + Format(ServiceDeclarationHeader."Ending Date");

        VATEntry.SetFilter("Operation Occurred Date", DateFilter);
        VATEntry.SetRange("EU Service", true);

        if ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Purchases then
            VATEntry.SetRange(Type, VATEntry.Type::Purchase)
        else
            VATEntry.SetRange(Type, VATEntry.Type::Sale);

        if ServiceDeclarationHeader."Corrective Entry" then
            VATEntry.SetRange("Document Type", VATEntry."Document Type"::"Credit Memo")
        else
            VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
    end;

    local procedure GetLineAmount(VATEntry: Record "VAT Entry"): Decimal
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        ClosedEntry: Boolean;
        IsCorrective: Boolean;
        TotalAppliedAmount: Decimal;
    begin
        ServiceDeclarationHeader.Get("Service Declaration No.");
        IsCorrective := ServiceDeclarationHeader."Corrective Entry";

        case VATEntry.Type of
            VATEntry.Type::Purchase:
                begin
                    VendLedgEntry.SetCurrentKey("Transaction No.");
                    VendLedgEntry.SetRange("Transaction No.", VATEntry."Transaction No.");
                    VendLedgEntry.SetRange("Document No.", VATEntry."Document No.");
                    VendLedgEntry.SetFilter("Posting Date", '..%1', ServiceDeclarationHeader."Ending Date");
                    if VendLedgEntry.FindFirst() then begin
                        TotalAppliedAmount :=
                            GetTotalBaseAmount(VendLedgEntry."Transaction No.", VendLedgEntry."Document No.", VATEntry.Type::Purchase, ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date", IsCorrective);
                        ClosedEntry := VendLedgEntry."Closed by Entry No." <> 0;
                        exit(CalcApplnDtldVendLedgEntry(VendLedgEntry, ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date", ClosedEntry, IsCorrective, TotalAppliedAmount));
                    end;
                end;
            VATEntry.Type::Sale:
                begin
                    CustLedgEntry.SetCurrentKey("Transaction No.");
                    CustLedgEntry.SetRange("Transaction No.", VATEntry."Transaction No.");
                    CustLedgEntry.SetRange("Document No.", VATEntry."Document No.");
                    CustLedgEntry.SetFilter("Posting Date", '..%1', ServiceDeclarationHeader."Ending Date");
                    if CustLedgEntry.FindFirst() then begin
                        TotalAppliedAmount :=
                            GetTotalBaseAmount(CustLedgEntry."Transaction No.", CustLedgEntry."Document No.", VATEntry.Type::Sale, ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date", IsCorrective);
                        ClosedEntry := CustLedgEntry."Closed by Entry No." <> 0;
                        exit(CalcApplnDtldCustLedgEntry(CustLedgEntry, ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date", ClosedEntry, IsCorrective, TotalAppliedAmount));
                    end;
                end;
        end;
    end;

    internal procedure GetIntrastatCountryCode(CountryRegionCode: Code[10]): Code[10]
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then
            if CompanyInformation.Get() then
                CountryRegionCode := CompanyInformation."Country/Region Code";

        if CountryRegion.Get(CountryRegionCode) then
            if CountryRegion."Intrastat Code" <> '' then
                CountryRegionCode := CountryRegion."Intrastat Code";

        exit(CountryRegionCode);
    end;

    internal procedure SetServiceDeclarationHeaderFilters(var ServiceDeclarationHeader2: Record "Service Declaration Header")
    var
        ServiceDeclarationHeader3: Record "Service Declaration Header";
    begin
        ServiceDeclarationHeader3.Get("Service Declaration No.");
        ServiceDeclarationHeader2.SetRange("Corrective Entry", false);
        ServiceDeclarationHeader2.SetRange(Reported, true);
        ServiceDeclarationHeader2.SetRange(Periodicity, ServiceDeclarationHeader3.Periodicity);
        ServiceDeclarationHeader2.SetRange(Type, ServiceDeclarationHeader3.Type);
    end;

    internal procedure FindSourceCurrency(VendorNo: Code[20]; DocumentDate: Date; PostingDate: Date)
    var
        Country: Record "Country/Region";
        Vendor: Record Vendor;
        CurrencyExchRate: Record "Currency Exchange Rate";
        CurrencyDate: Date;
        Factor: Decimal;
    begin
        if DocumentDate <> 0D then
            CurrencyDate := DocumentDate
        else
            CurrencyDate := PostingDate;
        if Vendor.Get(VendorNo) then begin
            if Country.Get(Vendor."Country/Region Code") then
                "Currency Code" := Country."Currency Code";
            if "Currency Code" <> '' then begin
                Factor := CurrencyExchRate.ExchangeRate(CurrencyDate, "Currency Code");
                "Source Currency Amount" := CurrencyExchRate.ExchangeAmtLCYToFCY(CurrencyDate, "Currency Code", Amount, Factor);
            end;
        end;
    end;

    local procedure GetTotalBaseAmount(TransactionNo: Integer; DocumentNo: Code[20]; TypeFilter: Enum "General Posting Type"; StartDate: Date; EndDate: Date; IsCorrective: Boolean) Result: Decimal
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange(Type, TypeFilter);
        VATEntry.SetRange("Transaction No.", TransactionNo);
        VATEntry.SetRange("Document No.", DocumentNo);
        if IsCorrective then
            VATEntry.SetFilter("Posting Date", '..%1', EndDate)
        else
            VATEntry.SetRange("Posting Date", StartDate, EndDate);

        if VATEntry.FindSet() then
            repeat
                Result += VATEntry.Base + VATEntry."Nondeductible Base";
            until VATEntry.Next() = 0;
    end;

    local procedure CalcApplnDtldVendLedgEntry(VendLedgEntry: Record "Vendor Ledger Entry"; StartDate: Date; EndDate: Date; ClosedEntry: Boolean; IsCorrective: Boolean; TotalAppliedAmount: Decimal): Decimal
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DtldVendLedgEntry2: Record "Detailed Vendor Ledg. Entry";
    begin
        DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.");
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntry."Entry No.");
        DtldVendLedgEntry.SetRange(Unapplied, false);
        if DtldVendLedgEntry.FindSet() then
            repeat
                if DtldVendLedgEntry."Vendor Ledger Entry No." = DtldVendLedgEntry."Applied Vend. Ledger Entry No." then begin
                    DtldVendLedgEntry2.SetCurrentKey("Applied Vend. Ledger Entry No.", "Entry Type");
                    DtldVendLedgEntry2.SetRange("Applied Vend. Ledger Entry No.", DtldVendLedgEntry."Applied Vend. Ledger Entry No.");
                    DtldVendLedgEntry2.SetRange("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
                    DtldVendLedgEntry2.SetRange(Unapplied, false);
                    if DtldVendLedgEntry2.FindSet() then
                        repeat
                            if DtldVendLedgEntry2."Vendor Ledger Entry No." <> DtldVendLedgEntry2."Applied Vend. Ledger Entry No." then
                                FindAppliedVendLedgEntryAmtLCY(DtldVendLedgEntry2."Vendor Ledger Entry No.", StartDate, EndDate, ClosedEntry, IsCorrective, TotalAppliedAmount);
                        until DtldVendLedgEntry2.Next() = 0;
                end else
                    FindAppliedVendLedgEntryAmtLCY(DtldVendLedgEntry."Applied Vend. Ledger Entry No.", StartDate, EndDate, ClosedEntry, IsCorrective, TotalAppliedAmount);
            until DtldVendLedgEntry.Next() = 0;
        exit(TotalAppliedAmount);
    end;

    local procedure CalcApplnDtldCustLedgEntry(CustLedgerEntry: Record "Cust. Ledger Entry"; StartDate: Date; EndDate: Date; ClosedEntry: Boolean; IsCorrective: Boolean; TotalAppliedAmount: Decimal): Decimal
    var
        DtldCustLedgerEntry: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgerEntry.SetCurrentKey("Cust. Ledger Entry No.");
        DtldCustLedgerEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DtldCustLedgerEntry.SetRange(Unapplied, false);
        if DtldCustLedgerEntry.FindSet() then
            repeat
                if DtldCustLedgerEntry."Cust. Ledger Entry No." = DtldCustLedgerEntry."Applied Cust. Ledger Entry No." then begin
                    DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", DtldCustLedgerEntry."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SetRange(Unapplied, false);
                    if DtldCustLedgEntry2.FindSet() then
                        repeat
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <> DtldCustLedgEntry2."Applied Cust. Ledger Entry No." then
                                FindAppliedCustLedgEntryAmtLCY(DtldCustLedgEntry2."Cust. Ledger Entry No.", StartDate, EndDate, ClosedEntry, IsCorrective, TotalAppliedAmount);
                        until DtldCustLedgEntry2.Next() = 0;
                end else
                    FindAppliedCustLedgEntryAmtLCY(DtldCustLedgerEntry."Applied Cust. Ledger Entry No.", StartDate, EndDate, ClosedEntry, IsCorrective, TotalAppliedAmount);
            until DtldCustLedgerEntry.Next() = 0;
        exit(TotalAppliedAmount);
    end;

    local procedure FindAppliedVendLedgEntryAmtLCY(EntryNo: Integer; StartDate: Date; EndDate: Date; ClosedEntry: Boolean; IsCorrective: Boolean; var TotalAppliedAmount: Decimal)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        VATEntry: Record "VAT Entry";
    begin
        VendLedgEntry.SetRange("Entry No.", EntryNo);
        VendLedgEntry.SetFilter("Document Type", '%1|%2', VendLedgEntry."Document Type"::Invoice, VendLedgEntry."Document Type"::"Credit Memo");
        if IsCorrective then
            VendLedgEntry.SetFilter("Posting Date", '..%1', EndDate)
        else
            VendLedgEntry.SetRange("Posting Date", StartDate, EndDate);

        if VendLedgEntry.FindFirst() then begin
            if IsCorrective then
                ClosedEntry := ClosedEntry and (VendLedgEntry."Closed by Entry No." <> 0);
            if ClosedEntry then
                TotalAppliedAmount := 0
            else
                TotalAppliedAmount +=
                  GetTotalBaseAmount(VendLedgEntry."Transaction No.", VendLedgEntry."Document No.", VATEntry.Type::Purchase, StartDate, EndDate, IsCorrective);
        end;
    end;

    local procedure FindAppliedCustLedgEntryAmtLCY(EntryNo: Integer; StartDate: Date; EndDate: Date; ClosedEntry: Boolean; IsCorrective: Boolean; var TotalAppliedAmount: Decimal): Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        VATEntry: Record "VAT Entry";
    begin
        CustLedgEntry.SetRange("Entry No.", EntryNo);
        CustLedgEntry.SetFilter("Document Type", '%1|%2', CustLedgEntry."Document Type"::Invoice, CustLedgEntry."Document Type"::"Credit Memo");
        if IsCorrective then
            CustLedgEntry.SetFilter("Posting Date", '..%1', EndDate)
        else
            CustLedgEntry.SetRange("Posting Date", StartDate, EndDate);

        if CustLedgEntry.FindFirst() then begin
            if IsCorrective then
                ClosedEntry := ClosedEntry and (CustLedgEntry."Closed by Entry No." <> 0);
            if ClosedEntry then
                TotalAppliedAmount := 0
            else
                TotalAppliedAmount +=
                  GetTotalBaseAmount(CustLedgEntry."Transaction No.", CustLedgEntry."Document No.", VATEntry.Type::Sale, StartDate, EndDate, IsCorrective);
        end;
    end;
}
