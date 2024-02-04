namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using System.Utilities;
using Microsoft.Sustainability.Account;

codeunit 6212 "Sustainability Post Mgt"
{
    Access = Internal;
    Permissions =
        tabledata "Sustainability Jnl. Line" = r,
        tabledata "Sustainability Jnl. Batch" = r,
        tabledata "Sustainability Ledger Entry" = i;

    procedure InsertLedgerEntry(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.Init();
        // AutoIncrement requires the PK to be empty
        SustainabilityLedgerEntry."Entry No." := 0;

        SustainabilityLedgerEntry.TransferFields(SustainabilityJnlLine);

        CopyDataFromAccountCategory(SustainabilityLedgerEntry, SustainabilityJnlLine."Account Category");

        CopyDateFromAccountSubCategory(SustainabilityLedgerEntry, SustainabilityJnlLine."Account Category", SustainabilityJnlLine."Account Subcategory");

        SustainabilityLedgerEntry.Validate("User ID", CopyStr(UserId(), 1, 50));
        SustainabilityLedgerEntry.Insert(true);
    end;

    procedure GetNoSeriesFromJournalLine(SustainabilityJnlLine: Record "Sustainability Jnl. Line"): Code[20]
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
    begin
        SustainabilityJnlBatch.Get(SustainabilityJnlLine."Journal Template Name", SustainabilityJnlLine."Journal Batch Name");
        exit(SustainabilityJnlBatch."No Series");
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure CheckJournalLinesWithErrorCollect(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"): Boolean
    var
        TempErrorMessages: Record "Error Message" temporary;
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        if not Codeunit.Run(Codeunit::"Sustainability Jnl.-Check", SustainabilityJnlLine) then
            ErrorMessageManagement.InsertTempLineErrorMessage(TempErrorMessages, SustainabilityJnlLine.RecordId(), Database::"Sustainability Jnl. Line", 0, GetLastErrorText(), GetLastErrorCallStack());

        ErrorMessageManagement.CollectErrors(TempErrorMessages);

        if not TempErrorMessages.IsEmpty() then begin
            Page.RunModal(Page::"Error Messages", TempErrorMessages);
            exit(false);
        end;

        exit(true);
    end;

    procedure PostSustainabilityJournalLines(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; IsRecurring: Boolean)
    begin
        if IsRecurring then
            Codeunit.Run(Codeunit::"Sustainability Recur Jnl.-Post", SustainabilityJnlLine)
        else
            Codeunit.Run(Codeunit::"Sustainability Jnl.-Post", SustainabilityJnlLine);

        Message(SuccessfulPostingLbl);
    end;

    local procedure CopyDataFromAccountCategory(var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry"; CategoryCode: Code[20])
    var
        SustainAccountCategory: Record "Sustain. Account Category";
    begin
        SustainAccountCategory.Get(CategoryCode);

        SustainabilityLedgerEntry.Validate("Emission Scope", SustainAccountCategory."Emission Scope");
        SustainabilityLedgerEntry.Validate(CO2, SustainAccountCategory.CO2);
        SustainabilityLedgerEntry.Validate(CH4, SustainAccountCategory.CH4);
        SustainabilityLedgerEntry.Validate(N2O, SustainAccountCategory.N2O);
        SustainabilityLedgerEntry.Validate("Calculation Foundation", SustainAccountCategory."Calculation Foundation");
    end;

    local procedure CopyDateFromAccountSubCategory(var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry"; CategoryCode: Code[20]; SubCategoryCode: Code[20])
    var
        SustainAccountSubCategory: Record "Sustain. Account Subcategory";
    begin
        SustainAccountSubCategory.Get(CategoryCode, SubCategoryCode);

        SustainabilityLedgerEntry.Validate("Emission Factor CO2", SustainAccountSubCategory."Emission Factor CO2");
        SustainabilityLedgerEntry.Validate("Emission Factor CH4", SustainAccountSubCategory."Emission Factor CH4");
        SustainabilityLedgerEntry.Validate("Emission Factor N2O", SustainAccountSubCategory."Emission Factor N2O");
        SustainabilityLedgerEntry.Validate("Renewable Energy", SustainAccountSubCategory."Renewable Energy");
    end;

    var
        SuccessfulPostingLbl: Label 'The journal lines have been posted successfully.';
}