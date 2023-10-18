// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.TDS.TDSForCustomer;
using System.Utilities;

tableextension 18766 "GenJournalLineExt" extends "Gen. Journal Line"
{
    fields
    {
        field(18766; "Nature of Remittance"; Code[10])
        {
            Caption = 'Nature of Remittance';
            TableRelation = "TDS Nature of Remittance";
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "Account Type" = "Account Type"::Vendor then
                    CheckNonResidentsPaymentSelection()
                else
                    TestField("Account Type", "Account Type"::Vendor);
            end;
        }
        field(18767; "Act Applicable"; Code[10])
        {
            Caption = 'Act Applicable';
            TableRelation = "Act Applicable";
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "Account Type" = "Account Type"::Vendor then
                    CheckNonResidentsPaymentSelection()
                else
                    TestField("Account Type", "Account Type"::Vendor);
            end;
        }
        field(18768; "Pay TDS"; Boolean)
        {
            Caption = 'Pay TDS';
            DataClassification = CustomerContent;
        }
        field(18770; "TDS Posting to G/L"; Boolean)
        {
            Caption = 'TDS Posting';
            DataClassification = CustomerContent;
        }
        field(18771; "TDS Invoice Amount"; Decimal)
        {
            Caption = 'TDS Invoice Amount';
            DataClassification = CustomerContent;
        }
        field(18772; "TDS Adjustment"; Boolean)
        {
            Caption = 'TDS Adjustment';
            DataClassification = CustomerContent;
        }
        field(18773; "Include GST in TDS Base"; Boolean)
        {
            Caption = 'Include GST in TDS Base';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestField("Document Type", "Document Type"::Invoice);
                if "TDS Section Code" <> '' then
                    Error(GSTTDSIncErr);
            end;
        }
        modify("Provisional Entry")
        {
            trigger OnAfterValidate()
            var
            begin
                TestField("Document Type", "Document Type"::Invoice);
                TestField("Account Type", "Account Type"::"G/L Account");
                TestField("Account No.");
                TestField("Bal. Account Type", "Bal. Account Type"::"G/L Account");
                TestField("Bal. Account No.");
                TestField("Party Code");
                TestField("Party Type", "Party Type"::Vendor);
                TestField("TDS Section Code");
                TestField("Work Tax Nature Of Deduction", '');
                if Amount >= 0 then
                    Error(AmtNegativeErr);

                if GetTotalDocLines() > 1 then
                    Error(MultiLineErr);
            end;
        }
        modify("Work Tax Nature Of Deduction")
        {
            trigger OnAfterValidate()
            begin
                TestField("Provisional Entry", false);
            end;
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            var
                GenJnlLine: Record "Gen. Journal Line";
                CalculateTax: Codeunit "Calculate Tax";
                TDSEntryUpdateMgt: Codeunit "TDS Entry Update Mgt.";
                VendorPayment: Boolean;
            begin
                TDSEntryUpdateMgt.GetSuggetVendorPayment(VendorPayment);

                if VendorPayment then
                    exit;

                if ("TDS Section Code" <> '') and ("System-Created Entry" = false) then begin
                    if GenJnlLine.Get("Journal Template Name", "Journal Batch Name", "Line No.") then
                        GenJnlLine.Modify();

                    if IsNullGuid(Rec."Tax ID") then begin
                        GenJnlLine.Reset();
                        GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "TDS Section Code", "Line No.");
                        GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                        GenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
                        GenJnlLine.SetRange("TDS Section Code", "TDS Section Code");
                        GenJnlLine.SetFilter("Line No.", '<>%1', "Line No.");
                        if GenJnlLine.FindSet() then
                            repeat
                                CalculateTax.CallTaxEngineOnGenJnlLine(GenJnlLine, GenJnlLine);
                            until GenJnlLine.Next() = 0;
                    end;
                end;
            end;
        }
    }
    procedure TDSSectionCodeLookupGenLine(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; SetTDSSection: boolean)
    var
        Section: Record "TDS Section";
        AllowedSections: Record "Allowed Sections";
        CustomerAllowedSections: Record "Customer Allowed Sections";
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
            AllowedSections.Reset();
            AllowedSections.SetRange("Vendor No", VendorNo);
            if AllowedSections.FindSet() then
                repeat
                    section.setrange(code, AllowedSections."TDS Section");
                    if Section.FindFirst() then
                        Section.Mark(true);
                until AllowedSections.Next() = 0;
            Section.setrange(code);
            section.MarkedOnly(true);
            if page.RunModal(Page::"TDS Sections", Section) = Action::LookupOK then
                checkDefaultandAssignTDSSection(GenJournalLine, Section.Code, SetTDSSection);
        end else
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and GenJournalLine."TDS Certificate Receivable" then begin
                CustomerAllowedSections.Reset();
                CustomerAllowedSections.SetRange("Customer No", GenJournalLine."Account No.");
                if CustomerAllowedSections.FindSet() then
                    repeat
                        section.setrange(code, CustomerAllowedSections."TDS Section");
                        if Section.FindFirst() then
                            Section.Mark(true);
                    until CustomerAllowedSections.Next() = 0;
                Section.setrange(code);
                section.MarkedOnly(true);
                if page.RunModal(Page::"TDS Sections", Section) = Action::LookupOK then
                    checkDefaultandAssignTDSSection(GenJournalLine, Section.Code, SetTDSSection);
            end else
                if (GenJournalLine."Party Type" = GenJournalLine."Party Type"::Vendor) and
                 (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account") then begin
                    AllowedSections.Reset();
                    AllowedSections.SetRange("Vendor No", GenJournalLine."Party Code");
                    if AllowedSections.FindSet() then
                        repeat
                            section.setrange(code, AllowedSections."TDS Section");
                            if Section.FindFirst() then
                                Section.Mark(true);
                        until AllowedSections.Next() = 0;
                    Section.setrange(code);
                    section.MarkedOnly(true);
                    if page.RunModal(Page::"TDS Sections", Section) = Action::LookupOK then
                        checkDefaultandAssignTDSSection(GenJournalLine, Section.Code, SetTDSSection);
                end;
    end;

    local procedure CheckDefaultAndAssignTDSSection(var GenJournalLine: Record "Gen. Journal Line"; TDSSectionCode: Code[10]; SetTDSSection: boolean)
    var
        AllowedSections: Record "Allowed Sections";
        CustomerAllowedSections: Record "Customer Allowed Sections";
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
            AllowedSections.Reset();
            AllowedSections.SetRange("Vendor No", GenJournalLine."Account No.");
            AllowedSections.SetRange("TDS Section", TDSSectionCode);
            if AllowedSections.findfirst() then
                if SetTDSSection then
                    GenJournalLine.Validate("TDS Section Code", AllowedSections."TDS Section")
                else
                    GenJournalLine.Validate("Work Tax Nature Of Deduction", AllowedSections."TDS Section")
            else
                ConfirmAssignTDSSection(GenJournalLine, TDSSectionCode, SetTDSSection);
        end else
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and GenJournalLine."TDS Certificate Receivable" then begin
                CustomerAllowedSections.Reset();
                CustomerAllowedSections.SetRange("Customer No", GenJournalLine."Account No.");
                CustomerAllowedSections.SetRange("TDS Section", TDSSectionCode);
                if CustomerAllowedSections.findfirst() then begin
                    if SetTDSSection then
                        GenJournalLine.Validate("TDS Section Code", CustomerAllowedSections."TDS Section")
                end else
                    ConfirmAssignTDSSection(GenJournalLine, TDSSectionCode, SetTDSSection);
            end else
                if (GenJournalLine."Party Type" = GenJournalLine."Party Type"::Vendor) and
                    (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account") then begin
                    AllowedSections.Reset();
                    AllowedSections.SetRange("Vendor No", GenJournalLine."Party Code");
                    AllowedSections.SetRange("TDS Section", TDSSectionCode);
                    if AllowedSections.findfirst() then
                        if SetTDSSection then
                            GenJournalLine.Validate("TDS Section Code", AllowedSections."TDS Section")
                        else
                            GenJournalLine.Validate("Work Tax Nature Of Deduction", AllowedSections."TDS Section")
                    else
                        ConfirmAssignTDSSection(GenJournalLine, TDSSectionCode, SetTDSSection);
                end;
    end;

    local procedure ConfirmAssignTDSSection(var GenJournalLine: Record "Gen. Journal Line"; TDSSectionCode: code[10]; SetTDSSection: boolean)
    var
        AllowedSections: Record "Allowed Sections";
        CustomerAllowedSections: Record "Customer Allowed Sections";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
            if ConfirmManagement.GetResponseOrDefault(strSubstNo(ConfirmMessageMsg, TDSSectionCode, GenJournalLine."Account No."), true) then begin
                AllowedSections.init();
                AllowedSections."TDS Section" := TDSSectionCode;
                AllowedSections."Vendor No" := GenJournalLine."Account No.";
                AllowedSections.insert();
                if SetTDSSection then
                    GenJournalLine.Validate("TDS Section Code", AllowedSections."TDS Section")
                else
                    GenJournalLine.Validate("Work Tax Nature Of Deduction", AllowedSections."TDS Section");
            end;
        end else
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and GenJournalLine."TDS Certificate Receivable" then
                if ConfirmManagement.GetResponseOrDefault(strSubstNo(ConfirmMessageMsg, TDSSectionCode, GenJournalLine."Account No."), true) then begin
                    CustomerAllowedSections.init();
                    CustomerAllowedSections."TDS Section" := TDSSectionCode;
                    CustomerAllowedSections."Customer No" := GenJournalLine."Account No.";
                    CustomerAllowedSections.insert();
                    if SetTDSSection then
                        GenJournalLine.Validate("TDS Section Code", CustomerAllowedSections."TDS Section")
                end else
                    if (GenJournalLine."Party Type" = GenJournalLine."Party Type"::Vendor) and
                        (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account") then begin
                        AllowedSections.init();
                        AllowedSections."TDS Section" := TDSSectionCode;
                        AllowedSections."Vendor No" := GenJournalLine."Party Code";
                        AllowedSections.insert();
                        if SetTDSSection then
                            GenJournalLine.Validate("TDS Section Code", AllowedSections."TDS Section")
                    end;
    end;

    procedure CheckNonResidentsPaymentSelection()
    var
        AllowedSections: Record "Allowed Sections";
    begin
        AllowedSections.Reset();
        AllowedSections.SetRange("Vendor No", "Account No.");
        AllowedSections.SetRange("TDS Section", "TDS Section Code");
        AllowedSections.SetRange("Non Resident Payments", true);
        if AllowedSections.IsEmpty() then
            Error(NonResidentPaymentsSelectionErr, Rec."Account No.");
    end;

    local procedure GetTotalDocLines(): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.", "Line No.");
        GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if GenJournalLine."Document No." = GenJournalLine."Old Document No." then
            GenJournalLine.SetRange("Document No.", "Document No.")
        else
            GenJournalLine.SetRange("Document No.", "Old Document No.");
        exit(GenJournalLine.Count);
    end;

    var
        NonResidentPaymentsSelectionErr: Label 'Non Resident Payments is not selected for Vendor No. %1', Comment = '%1 is Vendor No.';
        ConfirmMessageMsg: label 'TDS Section Code %1 is not attached with Vendor No. %2, Do you want to assign to vendor & Continue ?', Comment = '%1 = TDS Section Code, %2= Vendor No.';
        AmtNegativeErr: Label 'Amount must be negative.';
        MultiLineErr: Label 'Multi Line transactions are not allowed for Provisional Entries.';
        GSTTDSIncErr: Label 'Please make TDS Section Code blank before selecting Include GST in TDS Base.';
}
