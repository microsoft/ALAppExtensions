// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Ledger;
using Microsoft.Projects.Resources.Ledger;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Utilities;

codeunit 5013 "Get Service Declaration Lines"
{
    TableNo = "Service Declaration Header";

    trigger OnRun()
    var
        ServiceDeclarationLine: Record "Service Declaration Line";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        ServiceDeclarationLine.SetRange("Service Declaration No.", Rec."No.");
        if not ServiceDeclarationLine.IsEmpty() then
            if not ConfirmManagement.GetResponseOrDefault(RecreateLinesQst, false) then
                exit;

        AddLines(Rec);
    end;

    var
        RecreateLinesQst: Label 'The service declaration lines have already been suggested. Do you want to remove the existing lines and suggest again?';

    local procedure AddLines(ServiceDeclarationHeader: Record "Service Declaration Header")
    var
        ValueEntry: Record "Value Entry";
        ServiceDeclarationLine: Record "Service Declaration Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ResLedgEntry: Record "Res. Ledger Entry";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        Customer: Record Customer;
        Vendor: Record Vendor;
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        IsHandled: Boolean;
    begin
        ServiceDeclarationLine.SetRange("Service Declaration No.", ServiceDeclarationHeader."No.");
        ServiceDeclarationLine.DeleteAll(true);

        ServiceDeclarationLine.Init();
        ServiceDeclarationLine."Service Declaration No." := ServiceDeclarationHeader."No.";

        IsHandled := false;
        OnBeforeAddLines(ServiceDeclarationHeader, IsHandled);
        if IsHandled then
            exit;

        ValueEntry.SetCurrentKey("Item Ledger Entry Type", "Posting Date", "Applicable For Serv. Decl.");
        ValueEntry.SetFilter(
          "Item Ledger Entry Type", '%1|%2', ValueEntry."Item Ledger Entry Type"::Sale, ValueEntry."Item Ledger Entry Type"::Purchase);
        ValueEntry.SetRange("Posting Date", ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date");
        ValueEntry.SetRange("Applicable For Serv. Decl.", true);
        if ValueEntry.FindSet() then
            repeat
                ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
                ServiceDeclarationLine."Line No." += 10000;
                ServiceDeclarationLine."Posting Date" := ItemLedgerEntry."Posting Date";
                ServiceDeclarationLine."Document Type" := ValueEntry."Document Type";
                ServiceDeclarationLine."Document No." := ValueEntry."Document No.";
                ServiceDeclarationLine."Item Charge No." := ValueEntry."Item Charge No.";
                ServiceDeclarationLine.Description := ItemLedgerEntry.Description;

                ServiceDeclarationLine."Service Transaction Code" := ValueEntry."Service Transaction Type Code";
                ServiceDeclarationLine."Country/Region Code" := ItemLedgerEntry."Country/Region Code";
                ServiceDeclarationLine."Sales Amount (LCY)" := ValueEntry."Sales Amount (Actual)";
                ServiceDeclarationLine."Purchase Amount (LCY)" := ValueEntry."Purchase Amount (Actual)";
                GetCurrencyInfoFromValueEntry(CurrencyCode, CurrencyFactor, ValueEntry);
                if CurrencyCode = '' then begin
                    GeneralLedgerSetup.Get();
                    ServiceDeclarationLine."Currency Code" := GeneralLedgerSetup."LCY Code";
                end else begin
                    Currency.Get(CurrencyCode);
                    ServiceDeclarationLine."Currency Code" := CurrencyCode;
                    ValueEntry."Sales Amount (Actual)" :=
                    Round(
                        CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                        ValueEntry."Posting Date", CurrencyCode, ValueEntry."Sales Amount (Actual)", CurrencyFactor),
                        Currency."Amount Rounding Precision");
                    ValueEntry."Purchase Amount (Actual)" :=
                    Round(
                        CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                        ValueEntry."Posting Date", CurrencyCode, ValueEntry."Purchase Amount (Actual)", CurrencyFactor),
                        Currency."Amount Rounding Precision");
                end;
                ServiceDeclarationLine."VAT Reg. No." := GetVATRegistrationNoFromItemLedgEntry(ItemLedgerEntry);
                ServiceDeclarationLine."Sales Amount" := ValueEntry."Sales Amount (Actual)";
                ServiceDeclarationLine."Purchase Amount" := ValueEntry."Purchase Amount (Actual)";
                ServiceDeclarationLine.Insert();
            until ValueEntry.Next() = 0;

        ResLedgEntry.SetCurrentKey("Entry Type", Chargeable, "Unit of Measure Code", "Resource No.", "Posting Date");
        ResLedgEntry.SetFilter(
          "Entry Type", '%1|%2', ResLedgEntry."Entry Type"::Sale, ResLedgEntry."Entry Type"::Purchase);
        ResLedgEntry.SetRange("Posting Date", ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date");
        ResLedgEntry.SetRange("Applicable For Serv. Decl.", true);
        if not ResLedgEntry.FindSet() then
            exit;

        repeat
            ServiceDeclarationLine.Init();
            ServiceDeclarationLine."Line No." += 10000;
            ServiceDeclarationLine."Posting Date" := ResLedgEntry."Posting Date";
            ServiceDeclarationLine."Document No." := ResLedgEntry."Document No.";
            ServiceDeclarationLine.Description := ResLedgEntry.Description;

            ServiceDeclarationLine."Service Transaction Code" := ResLedgEntry."Service Transaction Type Code";
            case ResLedgEntry."Entry Type" of
                ResLedgEntry."Entry Type"::Sale:
                    begin
                        if Customer.Get(ResLedgEntry."Source No.") then
                            ServiceDeclarationLine."Country/Region Code" := Customer."Country/Region Code";
                        ServiceDeclarationLine."Sales Amount (LCY)" := -ResLedgEntry."Total Price";
                    end;
                ResLedgEntry."Entry Type"::Purchase:
                    begin
                        if Vendor.Get(ResLedgEntry."Source No.") then
                            ServiceDeclarationLine."Country/Region Code" := Vendor."Country/Region Code";
                        ServiceDeclarationLine."Purchase Amount (LCY)" := ResLedgEntry."Total Cost";
                    end;
            end;
            GetCurrencyInfoFromResLedgEntry(CurrencyCode, CurrencyFactor, ResLedgEntry);
            if CurrencyCode = '' then begin
                GeneralLedgerSetup.Get();
                ServiceDeclarationLine."Currency Code" := GeneralLedgerSetup."LCY Code";
            end else begin
                Currency.Get(CurrencyCode);
                ServiceDeclarationLine."Currency Code" := CurrencyCode;
                ResLedgEntry."Total Price" :=
                Round(
                    CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    ValueEntry."Posting Date", CurrencyCode, ResLedgEntry."Total Price", CurrencyFactor),
                    Currency."Amount Rounding Precision");
                ResLedgEntry."Total Cost" :=
                Round(
                    CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    ValueEntry."Posting Date", CurrencyCode, ResLedgEntry."Total Cost", CurrencyFactor),
                    Currency."Amount Rounding Precision");
            end;
            ServiceDeclarationLine."VAT Reg. No." := GetVATRegistrationNoFromResLedgEntry(ResLedgEntry, ServiceDeclarationLine."Country/Region Code");
            if ResLedgEntry."Entry Type" = ResLedgEntry."Entry Type"::Sale then
                ServiceDeclarationLine."Sales Amount" := -ResLedgEntry."Total Price"
            else
                ServiceDeclarationLine."Purchase Amount" := ResLedgEntry."Total Cost";
            ServiceDeclarationLine.Insert();
        until ResLedgEntry.Next() = 0;
    end;

    local procedure GetCurrencyInfoFromValueEntry(var CurrencyCode: Code[10]; var CurrencyFactor: Decimal; ValueEntry: Record "Value Entry")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyCode := '';
        CurrencyFactor := 0;

        case ValueEntry."Item Ledger Entry Type" of
            ValueEntry."Item Ledger Entry Type"::Sale:
                begin
                    case ValueEntry."Document Type" of
                        ValueEntry."Document Type"::"Sales Invoice":
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                        ValueEntry."Document Type"::"Sales Credit Memo":
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                    end;
                    CustLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
                    CustLedgerEntry.SetRange("Posting Date", ValueEntry."Posting Date");
                    if CustLedgerEntry.FindFirst() then begin
                        CurrencyCode := CustLedgerEntry."Currency Code";
                        CurrencyFactor := CustLedgerEntry."Adjusted Currency Factor";
                        if CurrencyFactor = 0 then
                            CurrencyFactor := CustLedgerEntry."Original Currency Factor";
                        exit;
                    end;
                    if ValueEntry."Source Type" = ValueEntry."Source Type"::Customer then
                        if Customer.Get(ValueEntry."Source No.") then
                            CurrencyCode := Customer."Currency Code";
                    if CurrencyCode <> '' then
                        CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ValueEntry."Posting Date", CurrencyCode);
                end;
            ValueEntry."Item Ledger Entry Type"::Purchase:
                begin
                    case ValueEntry."Document Type" of
                        ValueEntry."Document Type"::"Purchase Invoice":
                            VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                        ValueEntry."Document Type"::"Purchase Credit Memo":
                            VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
                    end;
                    VendorLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
                    VendorLedgerEntry.SetRange("Posting Date", ValueEntry."Posting Date");
                    if VendorLedgerEntry.FindFirst() then begin
                        CurrencyCode := VendorLedgerEntry."Currency Code";
                        CurrencyFactor := VendorLedgerEntry."Adjusted Currency Factor";
                        if CurrencyFactor = 0 then
                            CurrencyFactor := VendorLedgerEntry."Original Currency Factor";
                        exit;
                    end;
                    if ValueEntry."Source Type" = ValueEntry."Source Type"::Vendor then
                        if Vendor.Get(ValueEntry."Source No.") then
                            CurrencyCode := Vendor."Currency Code";
                    if CurrencyCode <> '' then
                        CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ValueEntry."Posting Date", CurrencyCode);
                end;
        end;
    end;

    local procedure GetCurrencyInfoFromResLedgEntry(var CurrencyCode: Code[10]; var CurrencyFactor: Decimal; ResLedgEntry: Record "Res. Ledger Entry")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyCode := '';
        CurrencyFactor := 0;

        case ResLedgEntry."Entry Type" of
            ResLedgEntry."Entry Type"::Sale:
                begin
                    CustLedgerEntry.SetRange("Document No.", ResLedgEntry."Document No.");
                    CustLedgerEntry.SetRange("Posting Date", ResLedgEntry."Posting Date");
                    if CustLedgerEntry.FindFirst() then begin
                        CurrencyCode := CustLedgerEntry."Currency Code";
                        CurrencyFactor := CustLedgerEntry."Adjusted Currency Factor";
                        if CurrencyFactor = 0 then
                            CurrencyFactor := CustLedgerEntry."Original Currency Factor";
                        exit;
                    end;
                    if ResLedgEntry."Source Type" = ResLedgEntry."Source Type"::Customer then
                        if Customer.Get(ResLedgEntry."Source No.") then
                            CurrencyCode := Customer."Currency Code";
                    if CurrencyCode <> '' then
                        CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ResLedgEntry."Posting Date", CurrencyCode);
                end;
            ResLedgEntry."Entry Type"::Purchase:
                begin
                    VendorLedgerEntry.SetRange("Document No.", ResLedgEntry."Document No.");
                    VendorLedgerEntry.SetRange("Posting Date", ResLedgEntry."Posting Date");
                    if VendorLedgerEntry.FindFirst() then begin
                        CurrencyCode := VendorLedgerEntry."Currency Code";
                        CurrencyFactor := VendorLedgerEntry."Adjusted Currency Factor";
                        if CurrencyFactor = 0 then
                            CurrencyFactor := VendorLedgerEntry."Original Currency Factor";
                        exit;
                    end;
                    if ResLedgEntry."Source Type" = ResLedgEntry."Source Type"::Vendor then
                        if Vendor.Get(ResLedgEntry."Source No.") then
                            CurrencyCode := Vendor."Currency Code";
                    if CurrencyCode <> '' then
                        CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ResLedgEntry."Posting Date", CurrencyCode);
                end;
        end;
    end;

    local procedure GetVATRegistrationNoFromItemLedgEntry(ItemLedgEntry: Record "Item Ledger Entry"): Text[50]
    var
        ServDeclSetup: Record "Service Declaration Setup";
        VATEntry: Record "VAT Entry";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        ServDeclSetup.Get();
        if not ServDeclSetup."Enable VAT Registration No." then
            exit('');

        VATEntry.SetRange("Document Type", ItemLedgEntry."Document Type");
        VATEntry.SetRange("Document No.", ItemLedgEntry."Document No.");
        VATEntry.SetRange("Posting Date", ItemLedgEntry."Posting Date");
        if VATEntry.FindFirst() and (VATEntry."VAT Registration No." <> '') then
            exit(VATEntry."VAT Registration No.");

        case ItemLedgEntry."Source Type" of
            ItemLedgEntry."Source Type"::Customer:
                if Customer.Get(ItemLedgEntry."Source No.") then
                    exit(
                        GetFormattedVATRegNo(
                            Customer."VAT Registration No.", ItemLedgEntry."Country/Region Code", ServDeclSetup."Cust. VAT Reg. No. Type", Customer."Contact Type" = Customer."Contact Type"::Person));
            ItemLedgEntry."Source Type"::Vendor:
                if Vendor.Get(ItemLedgEntry."Source No.") then
                    exit(GetFormattedVATRegNo(Vendor."VAT Registration No.", ItemLedgEntry."Country/Region Code", ServDeclSetup."Vend. VAT Reg. No. Type", false));
        end;
    end;

    local procedure GetVATRegistrationNoFromResLedgEntry(ResLedgEntry: Record "Res. Ledger Entry"; CountryCode: Code[10]): Text[50]
    var
        ServDeclSetup: Record "Service Declaration Setup";
        VATEntry: Record "VAT Entry";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        ServDeclSetup.Get();
        if not ServDeclSetup."Enable VAT Registration No." then
            exit('');

        VATEntry.SetRange("Document No.", ResLedgEntry."Document No.");
        VATEntry.SetRange("Posting Date", ResLedgEntry."Posting Date");
        if VATEntry.FindFirst() and (VATEntry."VAT Registration No." <> '') then
            exit(VATEntry."VAT Registration No.");

        case ResLedgEntry."Source Type" of
            ResLedgEntry."Source Type"::Customer:
                if Customer.Get(ResLedgEntry."Source No.") then
                    exit(
                        GetFormattedVATRegNo(
                            Customer."VAT Registration No.", CountryCode, ServDeclSetup."Cust. VAT Reg. No. Type", Customer."Contact Type" = Customer."Contact Type"::Person));
            ResLedgEntry."Source Type"::Vendor:
                if Vendor.Get(ResLedgEntry."Source No.") then
                    exit(GetFormattedVATRegNo(Vendor."VAT Registration No.", CountryCode, ServDeclSetup."Vend. VAT Reg. No. Type", false));
        end;
    end;

    local procedure GetFormattedVATRegNo(VATRegNo: Text[20]; CountryCode: Code[10]; VATRegNoType: Enum "Serv. Decl. VAT Reg. No. Type"; IsPerson: Boolean): Text[50]
    var
        ServDeclSetup: Record "Service Declaration Setup";
        CountryRegion: Record "Country/Region";
    begin
        if VATRegNo = '' then begin
            ServDeclSetup.Get();
            if IsPerson then
                exit(ServDeclSetup."Def. Private Person VAT No.");
            exit(ServDeclSetup."Def. Customer/Vendor VAT No.");
        end;
        case VATRegNoType of
            VATRegNoType::"VAT Reg. No.":
                exit(VATRegNo);
            VATRegNoType::"Country Code + VAT Reg. No.":
                begin
                    CountryRegion.Get(CountryCode);
                    if CountryRegion."EU Country/Region Code" <> '' then
                        CountryCode := CountryRegion."EU Country/Region Code";
                    exit(CountryCode + VATRegNo);
                end;
            VATRegNoType::"VAT Reg. No. w/o Country Code":
                begin
                    CountryRegion.Get(CountryCode);
                    if CountryRegion."EU Country/Region Code" <> '' then
                        CountryCode := CountryRegion."EU Country/Region Code";
                    if CopyStr(VATRegNo, 1, StrLen(DelChr(CountryCode, '<>'))) =
                       DelChr(CountryCode, '<>')
                    then
                        exit(CopyStr(VATRegNo, StrLen(DelChr(CountryCode, '<>')) + 1, 30));
                    exit(VATRegNo);
                end;
        end;
    end;



    [IntegrationEvent(true, false)]
    local procedure OnBeforeAddLines(ServiceDeclarationHeader: Record "Service Declaration Header"; var IsHandled: Boolean);
    begin
    end;
}
