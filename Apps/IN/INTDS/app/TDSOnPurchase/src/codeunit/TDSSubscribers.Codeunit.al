// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPurchase;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using Microsoft.Utilities;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 18716 "TDS Subscribers"
{
    var
        VedPANNoErr: Label 'Vendor P.A.N. is invalid.';
        CustPANNoErr: Label 'Customer P.A.N. is invalid.';

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure AssignTDSSectionCodePurchaseLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        AllowedSections: Record "Allowed Sections";
    begin
        if Rec."Document Type" in [Rec."Document Type"::Order, Rec."Document Type"::Invoice] then begin
            AllowedSections.Reset();
            AllowedSections.SetRange("Vendor No", Rec."Buy-from Vendor No.");
            AllowedSections.SetRange("Default Section", true);
            if AllowedSections.FindFirst() then begin
                Rec.Validate("TDS Section Code", AllowedSections."TDS Section");
                Rec.Validate("Nature of Remittance", AllowedSections."Nature of Remittance");
                Rec.Validate("Act Applicable", AllowedSections."Act Applicable");
            end else begin
                Rec."TDS Section Code" := '';
                Rec."Nature of Remittance" := '';
                Rec."Act Applicable" := '';
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure InsertTDSSectionCodeGenJnlLineOnPostLedgerEntryOnBeforeGenJnlPostLine(
        var GenJnlLine: Record "Gen. Journal Line";
        var PurchHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        Location: Record Location;
        CompanyInformation: Record "Company Information";
    begin
        PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchHeader."No.");
        if PurchaseLine.FindFirst() then
            GenJnlLine."TDS Section Code" := PurchaseLine."TDS Section Code";

        if GenJnlLine."Location Code" <> '' then begin
            Location.Get(GenJnlLine."Location Code");
            if Location."T.A.N. No." <> '' then
                GenJnlLine."T.A.N. No." := Location."T.A.N. No."
        end else begin
            CompanyInformation.Get();
            GenJnlLine."T.A.N. No." := CompanyInformation."T.A.N. No.";
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure CheckTANNo(var PurchaseHeader: Record "Purchase Header")
    var
        CompanyInformation: Record "Company Information";
        Location: Record Location;
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetFilter("TDS Section Code", '<>%1', '');
        if PurchaseLine.IsEmpty then
            exit;

        CompanyInformation.Get();
        CompanyInformation.TestField("T.A.N. No.");

        if PurchaseHeader."Location Code" <> '' then begin
            Location.Get(PurchaseHeader."Location Code");
            if Location."T.A.N. No." = '' then
                Location.TestField("T.A.N. No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure InsertTDSSectionCodeinVendLedgerEntry(
        GenJournalLine: Record "Gen. Journal Line";
        var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry."TDS Section Code" := GenJournalLine."TDS Section Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Calc.Discount", 'OnAfterCalcPurchaseDiscount', '', false, false)]
    local procedure OnAfterCalcPurchaseDiscount(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseLine.LoadFields("Document Type", "Document No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'TDS Section Code', false, false)]
    local procedure CheckPANDetails(var Rec: Record "Purchase Line")
    var
        Vendor: Record Vendor;
        PANNoErr: Label 'Vendor P.A.N. is invalid.';
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        if not Vendor.Get(Rec."Pay-to Vendor No.") then
            exit;

        if (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. No." <> '') then
            if StrLen(Vendor."P.A.N. No.") <> 10 then
                Error(PANNoErr);

        if (Vendor."P.A.N. No." = '') and (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") then
            Error(PANNoErr);

        if (Vendor."P.A.N. Status" <> Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. Reference No." = '') then
            Error(PANNoErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'TDS Section Code', false, false)]
    local procedure CheckPANDetailsOnGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        case Rec."Account Type" of
            Rec."Account Type"::Vendor:
                CheckVendorPANDetails(Rec);
            Rec."Account Type"::Customer:
                CheckCustomerPANDetails(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnBeforeCallingTaxEngineFromPurchLine', '', false, false)]
    local procedure OnBeforeCallingTaxEngineFromPurchLine(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line")
    begin
        ValidatePurchLine(PurchaseHeader, PurchaseLine);
    end;

    local procedure CheckVendorPANDetails(GenJournalLine: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
    begin
        if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Vendor) or (GenJournalLine."Account No." = '') then
            exit;

        Vendor.Get(GenJournalLine."Account No.");
        if (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. No." <> '') then
            if StrLen(Vendor."P.A.N. No.") <> 10 then
                Error(VedPANNoErr);

        if (Vendor."P.A.N. No." = '') and (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") then
            Error(VedPANNoErr);

        if (Vendor."P.A.N. Status" <> Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. Reference No." = '') then
            Error(VedPANNoErr);
    end;

    local procedure CheckCustomerPANDetails(GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
    begin
        if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Customer) or (GenJournalLine."Account No." = '') then
            exit;

        Customer.Get(GenJournalLine."Account No.");
        if (Customer."P.A.N. Status" = Customer."P.A.N. Status"::" ") and (Customer."P.A.N. No." <> '') then
            if StrLen(Customer."P.A.N. No.") <> 10 then
                Error(CustPANNoErr);

        if (Customer."P.A.N. No." = '') and (Customer."P.A.N. Status" = Customer."P.A.N. Status"::" ") then
            Error(CustPANNoErr);

        if (Customer."P.A.N. Status" <> Customer."P.A.N. Status"::" ") and (Customer."P.A.N. Reference No." = '') then
            Error(CustPANNoErr);
    end;

    local procedure ValidatePurchLine(PurchaseHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if PurchLine."TDS Section Code" = '' then
            exit;

        if PurchaseHeader."Applies-to Doc. No." = '' then
            exit;

        VendorLedgerEntry.SetRange("Document Type", PurchaseHeader."Applies-to Doc. Type");
        VendorLedgerEntry.SetRange("Document No.", PurchaseHeader."Applies-to Doc. No.");
        if VendorLedgerEntry.FindFirst() then
            VendorLedgerEntry.TestField("TDS Section Code", PurchLine."TDS Section Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocPurchLineOnAfterCopyPurchLine', '', false, false)]
    local procedure CallTaxEngineOnCopyPurchDocPurchLineOnAfterCopyPurchLine(var ToPurchLine: Record "Purchase Line"; RecalculateLines: Boolean)
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if not RecalculateLines then
            CalculateTax.CallTaxEngineOnPurchaseLine(ToPurchLine, ToPurchLine);
    end;
}
