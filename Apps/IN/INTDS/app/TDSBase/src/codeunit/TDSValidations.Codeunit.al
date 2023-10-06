// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Company;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 18688 "TDS Validations"
{
    var
        TANNoErr: Label 'T.A.N. No must have a value in TDS Entry';
        PANNOErr: Label 'The deductee P.A.N. No. is invalid.';
        PANReferenceNoErr: Label 'The P.A.N. Reference No. field must be filled for the Vendor No. %1', Comment = '%1 = Vendor No.';
        PANReferenceCustomerErr: Label 'The P.A.N. Reference No. field must be filled for the Customer No. %1', Comment = '%1 = Customer No.';
        AccountingPeriodErr: Label 'The Posting Date doesn''t lie in Tax Accounting Period';
        TDSReverseErr: Label 'You cannot reverse the transaction, because it has already been reversed.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure CheckPANNoValidations(var GenJournalLine: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Location: Record Location;
        CompanyInformation: Record "Company Information";
    begin
        if GenJournalLine."TDS Section Code" <> '' then begin
            if GenJournalLine."T.A.N. No." = '' then
                Error(TANNoErr);

            CompanyInformation.Get();
            CompanyInformation.TestField("T.A.N. No.");
            if GenJournalLine."Location Code" <> '' then begin
                Location.Get(GenJournalLine."Location Code");
                if Location."T.A.N. No." = '' then
                    Location.TestField("T.A.N. No.");
            end;

            if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
                Vendor.Get(GenJournalLine."Account No.");
                if (Vendor."P.A.N. No." = '') and (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. Reference No." = '') then
                    Error(PANNOErr);
                if (Vendor."P.A.N. No." = '') or (Vendor."P.A.N. Status" <> Vendor."P.A.N. Status"::" ") then
                    if (Vendor."P.A.N. Status" <> Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. Reference No." = '') then
                        Error(PANReferenceNoErr, Vendor."No.");
            end
            else
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then begin
                    Customer.Get(GenJournalLine."Account No.");
                    if (Customer."P.A.N. No." = '') and (Customer."P.A.N. Status" = Customer."P.A.N. Status"::" ") and (Customer."P.A.N. Reference No." = '') then
                        Error(PANNOErr);
                    if (Customer."P.A.N. No." = '') or (Customer."P.A.N. Status" <> Customer."P.A.N. Status"::" ") then
                        if (Customer."P.A.N. Status" <> Customer."P.A.N. Status"::" ") and (Customer."P.A.N. Reference No." = '') then
                            Error(PANReferenceCustomerErr, Customer."No.");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure CheckCompanyInforDetails(var GenJournalLine: Record "Gen. Journal Line")
    var
        CompanyInformation: Record "Company Information";
        DeductorCategory: Record "Deductor Category";
    begin
        if GenJournalLine."TDS Section Code" = '' then
            exit;

        CompanyInformation.Get();
        CompanyInformation.TestField("Deductor Category");
        DeductorCategory.Get(CompanyInformation."Deductor Category");
        if DeductorCategory."DDO Code Mandatory" then begin
            CompanyInformation.TestField("DDO Code");
            CompanyInformation.TestField("DDO Registration No.");
        end;

        if DeductorCategory."PAO Code Mandatory" then begin
            CompanyInformation.TestField("PAO Code");
            CompanyInformation.TestField("PAO Registration No.");
        end;

        if DeductorCategory."Ministry Details Mandatory" then begin
            CompanyInformation.TestField("Ministry Type");
            CompanyInformation.TestField("Ministry Code");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure CheckTaxAccountingPeriod(var GenJournalLine: Record "Gen. Journal Line")
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        TDSSetup: Record "TDS Setup";
        TaxType: Record "Tax Type";
        AccountingStartDate: Date;
        AccountingEndDate: Date;
    begin
        if GenJournalLine."TDS Section Code" = '' then
            exit;

        if not TDSSetup.Get() then
            exit;

        TDSSetup.TestField("Tax Type");

        TaxType.Get(TDSSetup."Tax Type");

        TaxAccountingPeriod.SetCurrentKey("Starting Date");
        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetRange(Closed, false);
        if TaxAccountingPeriod.FindFirst() then
            AccountingStartDate := TaxAccountingPeriod."Starting Date";

        if TaxAccountingPeriod.FindLast() then
            AccountingEndDate := TaxAccountingPeriod."Ending Date";

        if (GenJournalLine."Posting Date" < AccountingStartDate) or (GenJournalLine."Posting Date" > AccountingEndDate) then
            Error(AccountingPeriodErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"TDS Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure GSTAmountInTDSEntry(var Rec: Record "TDS Entry"; RunTrigger: Boolean)
    var
        TDSEntry: Record "TDS Entry";
        TaxBaseSubscribers: Codeunit "Tax Base Subscribers";
        TDSEntryUpdateMgt: Codeunit "TDS Entry Update Mgt.";
        TDSPreviewHandler: Codeunit "TDS Preview Handler";
        InitialInvoiceAmount: Decimal;
        GSTAmount: Decimal;
    begin
        if not TDSEntry.Get(Rec."Entry No.") then
            exit;

        if TDSEntry.Reversed or TDSEntry.Adjusted or (not TDSEntry."Include GST in TDS Base") then
            exit;

        if not TDSEntryUpdateMgt.IsTDSEntryUpdateStarted(TDSEntry."Entry No.") then
            TDSEntryUpdateMgt.SetTDSEntryForUpdate(TDSEntry);

        GSTAmount := 0;
        TaxBaseSubscribers.GetGSTAmountFromTransNo(Rec."Transaction No.", TDSEntry."Document No.", GSTAmount);
        InitialInvoiceAmount := TDSEntryUpdateMgt.GetTDSEntryToUpdateInitialInvoiceAmount(TDSEntry."Entry No.");
        TDSEntry."Invoice Amount" := InitialInvoiceAmount + Abs(GSTAmount);
        TDSEntry.Modify();
        TDSPreviewHandler.UpdateInvoiceAmountOnTempTDSEntry(TDSEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Library", 'OnAfterGetTotalTDSIncludingSheCess', '', false, false)]
    local procedure OnAfterGetTotalTDSIncludingSheCess(DocumentNo: Code[20]; var AccountNo: Code[20]; var EntryNo: Integer; var TotalTDSEncludingSheCess: Decimal)
    var
        TDSEntry: Record "TDS Entry";
    begin
        TDSEntry.Reset();
        TDSEntry.SetCurrentKey("Document No.", "TDS Paid");
        TDSEntry.SetRange("Document No.", DocumentNo);
        TDSEntry.SetRange("TDS Paid", false);
        if TDSEntry.FindFirst() then begin
            AccountNo := TDSEntry."Account No.";
            EntryNo := TDSEntry."Entry No.";
            TotalTDSEncludingSheCess := TDSEntry."Total TDS Including SHE CESS";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Library", 'OnGetTDSAmount', '', false, false)]
    local procedure GetTDSAmount(GenJournalLine: Record "Gen. Journal Line"; var Amount: Decimal)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TDSSetup: Record "TDS Setup";
    begin
        if not TDSSetup.Get() then
            exit;

        TaxTransactionValue.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", GenJournalLine.RecordId);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if TaxTransactionValue.FindSet() then
            repeat
                Amount += Abs(TaxTransactionValue.Amount);
            until TaxTransactionValue.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Library", 'OnAfterReverseTDSEntry', '', false, false)]
    local procedure ReverseTDSEntry(EntryNo: Integer; TransactionNo: Integer)
    var
        TDSEntry: Record "TDS Entry";
        NewTDSEntry: Record "TDS Entry";
    begin
        if not TDSEntry.Get(EntryNo) then
            exit;

        if TDSEntry."Reversed by Entry No." <> 0 then
            Error(TDSReverseErr);

        NewTDSEntry := TDSEntry;
        NewTDSEntry."Entry No." := 0;
        NewTDSEntry."TDS Base Amount" := -NewTDSEntry."TDS Base Amount";
        NewTDSEntry."TDS Amount" := -NewTDSEntry."TDS Amount";
        NewTDSEntry."Surcharge Base Amount" := -NewTDSEntry."Surcharge Base Amount";
        NewTDSEntry."Surcharge Amount" := -NewTDSEntry."Surcharge Amount";
        NewTDSEntry."TDS Amount Including Surcharge" := -NewTDSEntry."TDS Amount Including Surcharge";
        NewTDSEntry."eCESS Amount" := -NewTDSEntry."eCESS Amount";
        NewTDSEntry."SHE Cess Amount" := -NewTDSEntry."SHE Cess Amount";
        NewTDSEntry."Total TDS Including SHE CESS" := -NewTDSEntry."Total TDS Including SHE CESS";
        NewTDSEntry."Bal. TDS Including SHE CESS" := -NewTDSEntry."Bal. TDS Including SHE CESS";
        NewTDSEntry."Invoice Amount" := -NewTDSEntry."Invoice Amount";
        NewTDSEntry."Remaining TDS Amount" := -NewTDSEntry."Remaining TDS Amount";
        NewTDSEntry."Remaining Surcharge Amount" := -NewTDSEntry."Remaining Surcharge Amount";
        NewTDSEntry."Reversed Entry No." := TDSEntry."Entry No.";
        NewTDSEntry.Reversed := true;
        NewTDSEntry."Transaction No." := TransactionNo;
        if TDSEntry."Reversed Entry No." <> 0 then begin
            TDSEntry."Reversed Entry No." := NewTDSEntry."Entry No.";
            NewTDSEntry."Reversed by Entry No." := TDSEntry."Entry No.";
        end;
        TDSEntry."Reversed by Entry No." := NewTDSEntry."Entry No.";
        TDSEntry.Reversed := true;
        TDSEntry.Modify();
        NewTDSEntry.Insert();
    end;
}
