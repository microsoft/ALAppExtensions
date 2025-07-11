// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Posting;

using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Project.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Setup;

codeunit 6263 "Sust. Job Post Subscriber"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Post Line", 'OnAfterJobLedgEntryInsert', '', false, false)]
    local procedure OnAfterJobLedgEntryInsert(JobJournalLine: Record "Job Journal Line"; var JobLedgerEntry: Record "Job Ledger Entry")
    begin
        if CanCreateSustValueEntry(JobJournalLine, JobLedgerEntry) then
            PostSustainabilityValueEntry(JobJournalLine, JobLedgerEntry);
    end;

    local procedure CanCreateSustValueEntry(JobJournalLine: Record "Job Journal Line"; var JobLedgerEntry: Record "Job Ledger Entry"): Boolean
    begin
        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit(false);

        exit((JobJournalLine."Sust. Account No." <> '') and (JobLedgerEntry.Type <> JobLedgerEntry.Type::Item));
    end;

    local procedure PostSustainabilityValueEntry(JobJournalLine: Record "Job Journal Line"; var JobLedgerEntry: Record "Job Ledger Entry")
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        GHGCredit: Boolean;
        CO2eToPost: Decimal;
        Sign: Integer;
    begin
        CheckSustainabilityItemJnlLine(JobJournalLine."Sust. Account No.", JobJournalLine."Sust. Account Category", JobJournalLine."Sust. Account Subcategory", JobJournalLine."Total CO2e");
        GHGCredit := JobJournalLine.IsGHGCreditLine();
        Sign := JobJournalLine.GetPostingSign(GHGCredit);

        CO2eToPost := JobJournalLine."CO2e per Unit" * Abs(JobLedgerEntry.Quantity) * JobLedgerEntry."Qty. per Unit of Measure";
        CO2eToPost := CO2eToPost * Sign;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine.Validate("Posting Date", JobJournalLine."Posting Date");
        SustainabilityJnlLine.Validate("Document No.", JobLedgerEntry."Document No.");
        SustainabilityJnlLine.Validate("Account No.", JobJournalLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Account Category", JobJournalLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", JobJournalLine."Sust. Account Subcategory");
        SustainabilityJnlLine."Dimension Set ID" := JobJournalLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := JobJournalLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := JobJournalLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", CO2eToPost);
        SustainabilityJnlLine.Validate("Country/Region Code", JobJournalLine."Country/Region Code");
        SustainabilityPostMgt.InsertValueEntry(SustainabilityJnlLine, JobLedgerEntry);
    end;

    local procedure CheckSustainabilityItemJnlLine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; CO2eToPost: Decimal)
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustValueEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2eToPost = 0) then
                    Error(CO2eMustNotBeZeroErr);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';
        NotAllowedToPostSustValueEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Value Entry for water or waste in Production document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}