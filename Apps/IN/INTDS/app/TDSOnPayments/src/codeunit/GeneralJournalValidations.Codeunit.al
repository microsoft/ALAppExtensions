// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.TDS.TDSForCustomer;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Company;
using Microsoft.Finance.TaxBase;

codeunit 18766 "General Journal Validations"
{
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'TDS Section Code', false, false)]
    local procedure OnAfterValidateTDSSectionCode(var Rec: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
        AllowedSections: Record "Allowed Sections";
        TDSSection: Record "TDS Section";
        CustomerAllowedSections: Record "Customer Allowed Sections";
    begin
        if (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Payment]) then begin
            if Rec."TDS Section Code" = '' then
                exit;

            if Rec."T.A.N. No." = '' then
                UpdateTANNoOnGenJnlLine(Rec);

            if Vendor.Get(Rec."Account No.") then begin
                AllowedSections.SetRange("Vendor No", Vendor."No.");
                AllowedSections.SetRange("TDS Section", Rec."TDS Section Code");
                AllowedSections.SetRange("Non Resident Payments", true);
                AllowedSections.SetFilter("Nature of Remittance", '<>%1', '');
                AllowedSections.SetFilter("Act Applicable", '<>%1', '');
                if not AllowedSections.IsEmpty then
                    Vendor.TestField("Country/Region Code");
                Rec."Country/Region Code" := Vendor."Country/Region Code";
            end;
        end;

        if not TDSSection.Get(Rec."TDS Section Code") then
            TDSSection.TestField(Code);

        if Rec."Account Type" = Rec."Account Type"::Vendor then
            if not AllowedSections.Get(Rec."Account No.", Rec."TDS Section Code") then
                AllowedSections.TestField("TDS Section");

        if Rec."Account Type" = Rec."Account Type"::Customer then begin
            Rec.TestField("TDS Certificate Receivable");

            if not CustomerAllowedSections.Get(Rec."Account No.", Rec."TDS Section Code") then
                CustomerAllowedSections.TestField("TDS Section");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure OnAfterValidateLocationCode(var Rec: Record "Gen. Journal Line")
    begin
        if (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Payment]) and
            (Rec."Account Type" = Rec."Account Type"::Vendor) then
            UpdateTANNoOnGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Handler", 'OnBeforeGenJnlLinePostFromTaxEngine', '', false, false)]
    local procedure OnBeforeGenJnlLinePostFromTaxEngine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."TDS Section Code" = '' then
            exit;

        GenJnlLine."TDS Posting to G/L" := true;
        GenJnlLine."TDS Invoice Amount" := GenJnlLine.Amount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Handler", 'OnAfterGenJnlLinePostFromTaxEngine', '', false, false)]
    local procedure OnAfterGenJnlLinePostFromTaxEngine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."TDS Section Code" = '' then
            exit;

        GenJnlLine."TDS Posting to G/L" := false;
    end;

    local procedure UpdateTANNoOnGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        Location: Record Location;
    begin
        if GenJournalLine."Location Code" <> '' then begin
            Location.Get(GenJournalLine."Location Code");
            if Location."T.A.N. No." <> '' then
                GenJournalLine."T.A.N. No." := Location."T.A.N. No."
            else
                GenJournalLine."T.A.N. No." := GetCompanyTANNo();
        end else
            GenJournalLine."T.A.N. No." := GetCompanyTANNo();
    end;

    local procedure GetCompanyTANNo(): Code[10]
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        exit(CompanyInformation."T.A.N. No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure OnAfterValidateDocumentType(var Rec: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        Rec."Include GST in TDS Base" := false;
        if Rec."TDS Section Code" = '' then
            exit;

        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, Rec);
    end;
}
