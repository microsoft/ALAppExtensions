// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPurchase;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;

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
            AllowedSections.SetLoadFields("Vendor No", "Default Section", "TDS Section", "Nature of Remittance", "Act Applicable");
            AllowedSections.SetRange("Vendor No", Rec."Pay-to Vendor No.");
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
        PurchaseLine.SetLoadFields("Document Type", "Document No.", "TDS Section Code");
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
        PurchaseLine.SetLoadFields("Document Type", "Document No.", "TDS Section Code");
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
        PurchaseLine.SetLoadFields("Document Type", "Document No.");
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
        if PurchaseHeader."Applies-to Doc. No." <> '' then
            ValidatePurchLineAppliesToDocNo(PurchaseHeader, PurchaseLine);

        if PurchaseHeader."Applies-to ID" <> '' then
            ValidatePurchLineAppliesToID(PurchaseHeader, PurchaseLine);
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

    local procedure UpdateTDSCertificateUsageGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        TDSConcessionalCode: Record "TDS Concessional Code";
        TDSEntry: Record "TDS Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TotalPostedAmount: Decimal;
        TotalLineAmount: Decimal;
        CurrentUsed: Decimal;
        AppliedAmount: Decimal;
    begin
        if GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Vendor then
            exit;

        if GenJournalLine."Account No." = '' then
            exit;

        TDSConcessionalCode.Reset();
        TDSConcessionalCode.SetRange("Vendor No.", GenJournalLine."Account No.");
        TDSConcessionalCode.SetRange(Section, GenJournalLine."TDS Section Code");
        TDSConcessionalCode.SetFilter("Certificate Value", '<>%1', 0);
        if not TDSConcessionalCode.FindFirst() then
            exit;

        TDSEntry.Reset();
        TDSEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
        TDSEntry.SetRange(Section, GenJournalLine."TDS Section Code");
        TDSEntry.CalcSums("TDS Base Amount");
        TotalPostedAmount := TDSEntry."TDS Base Amount";

        TotalLineAmount := GenJournalLine.Amount;

        CurrentUsed := TotalPostedAmount + TotalLineAmount;

        if GenJournalLine."Applies-to ID" <> '' then begin
            VendorLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            VendorLedgerEntry.CalcSums("Amount to Apply");
            AppliedAmount := VendorLedgerEntry."Amount to Apply";
        end;

        if (AppliedAmount = 0) and (CurrentUsed = 0) then begin
            TDSConcessionalCode."Used Certificate Value" := 0;
            TDSConcessionalCode."Remaining Certificate Value" := TDSConcessionalCode."Certificate Value";
            TDSConcessionalCode.Modify();
            exit;
        end;

        if AppliedAmount >= CurrentUsed then
            exit;

        TDSConcessionalCode."Used Certificate Value" := CurrentUsed - AppliedAmount;
        TDSConcessionalCode."Remaining Certificate Value" := TDSConcessionalCode."Certificate Value" - TDSConcessionalCode."Used Certificate Value";

        if TDSConcessionalCode."Remaining Certificate Value" < 0 then
            TDSConcessionalCode."Remaining Certificate Value" := 0;

        TDSConcessionalCode.Modify();
    end;

    local procedure ValidatePurchLineAppliesToDocNo(PurchaseHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidatePurchLine(PurchaseHeader, PurchLine, IsHandled);
        if IsHandled then
            exit;

        if PurchLine."TDS Section Code" = '' then
            exit;

        if PurchaseHeader."Applies-to Doc. No." = '' then
            exit;

        VendorLedgerEntry.SetLoadFields("Document Type", "Document No.", "TDS Section Code");
        VendorLedgerEntry.SetRange("Document Type", PurchaseHeader."Applies-to Doc. Type");

        if PurchaseHeader."Applies-to Doc. No." <> '' then
            VendorLedgerEntry.SetRange("Document No.", PurchaseHeader."Applies-to Doc. No.");

        if VendorLedgerEntry.FindFirst() then
            VendorLedgerEntry.TestField("TDS Section Code", PurchLine."TDS Section Code");
    end;

    local procedure ValidatePurchLineAppliesToID(PurchaseHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidatePurchLineAppliesToID(PurchaseHeader, PurchLine, IsHandled);
        if IsHandled then
            exit;

        if PurchLine."TDS Section Code" = '' then
            exit;

        if PurchaseHeader."Applies-to ID" = '' then
            exit;

        VendorLedgerEntry.SetLoadFields("Document Type", "Vendor No.", "Applies-to ID", "Open", "TDS Section Code");
        VendorLedgerEntry.SetRange("Document Type", PurchaseHeader."Applies-to Doc. Type");
        VendorLedgerEntry.SetRange("Vendor No.", PurchaseHeader."Buy-from Vendor No.");

        if PurchaseHeader."Applies-to ID" <> '' then
            VendorLedgerEntry.SetRange("Applies-to ID", PurchaseHeader."Applies-to ID");
        VendorLedgerEntry.SetRange(Open, true);

        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.TestField("TDS Section Code", PurchLine."TDS Section Code");
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure UpdateTDSCertificateUsage(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine2: Record "Purchase Line";
        TDSConcessionalCode: Record "TDS Concessional Code";
        TDSEntry: Record "TDS Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TotalPostedAmount: Decimal;
        TotalLineAmount: Decimal;
        CurrentUsed: Decimal;
        AppliedAmount: Decimal;
    begin
        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            exit;

        TDSConcessionalCode.Reset();
        TDSConcessionalCode.SetRange("Vendor No.", PurchaseLine."Pay-to Vendor No.");
        TDSConcessionalCode.SetRange(Section, PurchaseLine."TDS Section Code");
        TDSConcessionalCode.SetFilter("Certificate Value", '<>%1', 0);
        if not TDSConcessionalCode.FindFirst() then
            exit;

        TDSEntry.Reset();
        TDSEntry.SetRange("Vendor No.", PurchaseLine."Pay-to Vendor No.");
        TDSEntry.SetRange(Section, PurchaseLine."TDS Section Code");
        TDSEntry.CalcSums("TDS Base Amount");
        TotalPostedAmount := TDSEntry."TDS Base Amount";

        PurchaseLine2.Reset();
        PurchaseLine2.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseLine2.SetRange("Document No.", PurchaseLine."Document No.");
        PurchaseLine2.SetRange("TDS Section Code", PurchaseLine."TDS Section Code");
        PurchaseLine2.CalcSums(Amount);
        TotalLineAmount := PurchaseLine2.Amount;
        CurrentUsed := TotalPostedAmount + TotalLineAmount;

        if PurchaseHeader."Applies-to Doc. No." <> '' then begin
            VendorLedgerEntry.SetRange("Document Type", PurchaseHeader."Applies-to Doc. Type");
            VendorLedgerEntry.SetRange("Document No.", PurchaseHeader."Applies-to Doc. No.");
            if VendorLedgerEntry.FindFirst() then
                AppliedAmount := VendorLedgerEntry."Amount to Apply";
        end;

        if (AppliedAmount = 0) and (CurrentUsed = 0) then begin
            TDSConcessionalCode."Used Certificate Value" := 0;
            TDSConcessionalCode."Remaining Certificate Value" := TDSConcessionalCode."Certificate Value";
            PurchaseHeader."Remaining TDS Cert. Value" := TDSConcessionalCode."Remaining Certificate Value";
            PurchaseHeader.Modify();
            TDSConcessionalCode.Modify();
            exit;
        end;

        if AppliedAmount >= CurrentUsed then
            exit;

        TDSConcessionalCode."Used Certificate Value" := CurrentUsed - AppliedAmount;
        TDSConcessionalCode."Remaining Certificate Value" := TDSConcessionalCode."Certificate Value" - TDSConcessionalCode."Used Certificate Value";

        if TDSConcessionalCode."Remaining Certificate Value" < 0 then
            TDSConcessionalCode."Remaining Certificate Value" := 0;

        PurchaseHeader."Remaining TDS Cert. Value" := TDSConcessionalCode."Remaining Certificate Value";
        PurchaseHeader.Modify();
        TDSConcessionalCode.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Direct Unit Cost', false, false)]
    local procedure OnAfterValidateAmount(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        UpdateTDSCertificateUsage(Rec);
        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnAfterValidateQuantity(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        UpdateTDSCertificateUsage(Rec);
        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Applies-to Doc. No.', false, false)]
    local procedure OnAfterValidateAppliesToDocNo(var Rec: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseLine.SetCurrentKey("Document Type", "Document No.", "TDS Section Code");
        PurchaseLine.SetRange("Document Type", Rec."Document Type");
        PurchaseLine.SetRange("Document No.", Rec."No.");
        PurchaseLine.SetFilter("TDS Section Code", '<>%1', '');
        if PurchaseLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeletePurchaseLine(var Rec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        if not PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if PurchaseHeader.Status <> PurchaseHeader.Status::Open then
            exit;

        if Rec.Amount <> 0 then
            Rec.Amount := 0;

        UpdateTDSCertificateUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure OnAfterValidateGenJnlAmount(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        UpdateTDSCertificateUsageGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'TDS Section Code', false, false)]
    local procedure OnAfterValidateGenJnlTDSSection(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        UpdateTDSCertificateUsageGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        if Rec.Amount <> 0 then
            Rec.Amount := 0;

        UpdateTDSCertificateUsageGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocPurchLineOnAfterCopyPurchLine', '', false, false)]
    local procedure CallTaxEngineOnCopyPurchDocPurchLineOnAfterCopyPurchLine(var ToPurchLine: Record "Purchase Line"; RecalculateLines: Boolean)
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if not RecalculateLines then
            CalculateTax.CallTaxEngineOnPurchaseLine(ToPurchLine, ToPurchLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePurchLine(PurchaseHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePurchLineAppliesToID(PurchaseHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;
}
