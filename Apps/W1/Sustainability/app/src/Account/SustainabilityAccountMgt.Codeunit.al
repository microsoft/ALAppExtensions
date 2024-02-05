namespace Microsoft.Sustainability.Account;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Journal;
using Microsoft.Finance.Dimension;
using System.Utilities;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Calculation;

codeunit 6210 "Sustainability Account Mgt."
{
    var
        SustainAccIndentQst: Label 'This function updates the indentation of all sustainability accounts in the chart of sustainability accounts. All accounts between a Begin-Total and the matching End-Total are indented one level. The Totaling for each End-total is also updated.\\Do you want to indent the chart of sustainability accounts?';
        IndSustainAccountsTxt: Label 'Indenting the Chart of Sustainability Accounts #1##########', Comment = '%1 - Sustainability Account number';
        EndTotalMissingErr: Label 'End-Total %1 is missing a matching Begin-Total.', Comment = '%1 - Sustainability Account number';
        MaxIndentationLevelReachedErr: Label 'You can only indent %1 levels for accounts of the type Begin-Total.', Comment = '%1 = A number bigger than 1';
        LedgerEntryExistsAndChangeBlockedErr: Label 'You cannot change this value because there are one or more ledger entries associated with %1. And the field %2 is set to false in the setup table: %3.', Comment = '%1 = Account No. or Category Code, %2 = Field Caption, %3 = Setup Table Name';
        ChangeCriticalSetupEvenThereAreTransactionQst: Label 'You are changing %1 field of %2 %3, which is already used in associated transactions.\\We recommend to create new %2 instead of modifying current one.\\Do you want to change the value?', Comment = '%1 - Field Caption, %2 - Table Caption  %3 - Account No.';
        ChangeAndUpdateJournalLinesQst: Label 'There are journal lines associated with %1. Do you want to continue and update them?', Comment = '%1 = Account No. or Category Code';

    procedure IndentChartOfSustainabilityAccounts()
    var
        SustainAccount: Record "Sustainability Account";
        ConfirmManagement: Codeunit "Confirm Management";
        Window: Dialog;
        AccNo: array[10] of Code[20];
        Indentation: Integer;
    begin
        if not ConfirmManagement.GetResponseOrDefault(SustainAccIndentQst, true) then
            exit;

        Window.Open(IndSustainAccountsTxt);

        Indentation := 0;
        if SustainAccount.FindSet() then
            repeat
                Window.Update(1, SustainAccount."No.");

                if SustainAccount."Account Type" = SustainAccount."Account Type"::"End-Total" then begin
                    if Indentation < 1 then
                        Error(EndTotalMissingErr, SustainAccount."No.");
                    SustainAccount.Totaling := AccNo[Indentation] + '..' + SustainAccount."No.";
                    Indentation -= 1;
                end;

                SustainAccount.Validate(Indentation, Indentation);
                SustainAccount.Modify();

                if SustainAccount."Account Type" = SustainAccount."Account Type"::"Begin-Total" then begin
                    Indentation += 1;
                    if Indentation > ArrayLen(AccNo) then
                        Error(MaxIndentationLevelReachedErr, ArrayLen(AccNo));
                    AccNo[Indentation] := SustainAccount."No.";
                end;
            until SustainAccount.Next() = 0;

        Window.Close();
    end;

    procedure CheckIfChangeAllowedForAccount(AccountNo: Code[20]; FieldCaption: Text)
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        if IsThereLedgerEntryForAccount(AccountNo) then begin
            if SustainabilitySetup."Block Change If Entry Exists" then
                Error(LedgerEntryExistsAndChangeBlockedErr, AccountNo, SustainabilitySetup.FieldCaption("Block Change If Entry Exists"), SustainabilitySetup.TableCaption());

            if not Dialog.Confirm(StrSubstNo(ChangeCriticalSetupEvenThereAreTransactionQst, FieldCaption, SustainabilityAccount.TableCaption(), AccountNo), false) then
                Error('');
        end;
    end;

    procedure CheckIfChangeAllowedForCategory(CategoryCode: Code[20]; FieldCaption: Text)
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilityLedgerEntry.SetRange("Account Category", CategoryCode);
        if not SustainabilityLedgerEntry.IsEmpty() then begin
            SustainabilitySetup.Get();
            if SustainabilitySetup."Block Change If Entry Exists" then
                Error(LedgerEntryExistsAndChangeBlockedErr, CategoryCode, SustainabilitySetup.FieldCaption("Block Change If Entry Exists"), SustainabilitySetup.TableCaption());

            if not Dialog.Confirm(StrSubstNo(ChangeCriticalSetupEvenThereAreTransactionQst, FieldCaption, SustainAccountCategory.TableCaption(), CategoryCode), false) then
                Error('');
        end;
    end;

    procedure CheckIfChangeAllowedForSubcategory(SubcategoryCode: Code[20]; FieldCaption: Text)
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilityLedgerEntry.SetRange("Account Subcategory", SubcategoryCode);
        if not SustainabilityLedgerEntry.IsEmpty() then begin
            SustainabilitySetup.Get();
            if SustainabilitySetup."Block Change If Entry Exists" then
                Error(LedgerEntryExistsAndChangeBlockedErr, SubcategoryCode, SustainabilitySetup.FieldCaption("Block Change If Entry Exists"), SustainabilitySetup.TableCaption());

            if not Dialog.Confirm(StrSubstNo(ChangeCriticalSetupEvenThereAreTransactionQst, FieldCaption, SustainAccountSubcategory.TableCaption(), SubcategoryCode), false) then
                Error('');
        end;
    end;

    internal procedure ShouldUpdateJournalLineForAccount(AccountNo: Code[20]): Boolean
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        SustainabilityJnlLine.SetRange("Account No.", AccountNo);
        if not SustainabilityJnlLine.IsEmpty() then
            if not Dialog.Confirm(StrSubstNo(ChangeAndUpdateJournalLinesQst, AccountNo), false) then
                Error('')
            else
                exit(true);

        exit(false);
    end;

    procedure ReCalculateJournalLinesForCategory(CategoryCode: Code[20])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
    begin
        SustainabilityJnlLine.SetRange("Account Category", CategoryCode);

        if not SustainabilityJnlLine.IsEmpty() then
            if not Dialog.Confirm(StrSubstNo(ChangeAndUpdateJournalLinesQst, CategoryCode), false) then
                Error('')
            else
                if SustainabilityJnlLine.FindSet() then
                    repeat
                        SustainabilityCalcMgt.CalculationEmissions(SustainabilityJnlLine);
                        SustainabilityJnlLine.Modify(true);
                    until SustainabilityJnlLine.Next() = 0;
    end;

    procedure ReCalculateJournalLinesForSubcategory(SubcategoryCode: Code[20])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
    begin
        SustainabilityJnlLine.SetRange("Account Subcategory", SubcategoryCode);

        if not SustainabilityJnlLine.IsEmpty() then
            if not Dialog.Confirm(StrSubstNo(ChangeAndUpdateJournalLinesQst, SubcategoryCode), false) then
                Error('')
            else
                if SustainabilityJnlLine.FindSet() then
                    repeat
                        SustainabilityCalcMgt.CalculationEmissions(SustainabilityJnlLine);
                        SustainabilityJnlLine.Modify(true);
                    until SustainabilityJnlLine.Next() = 0;
    end;

    internal procedure IsThereLedgerEntryForAccount(AccountNo: Code[20]): Boolean
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Account No.", AccountNo);
        exit(not SustainabilityLedgerEntry.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterUpdateGlobalDimCode', '', true, true)]
    local procedure OnAfterUpdateGlobalDimCode(GlobalDimCodeNo: Integer; TableID: Integer; AccNo: Code[20]; NewDimValue: Code[20])
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        if SustainabilityAccount.Get(AccNo) then begin
            case GlobalDimCodeNo of
                1:
                    SustainabilityAccount."Global Dimension 1 Code" := NewDimValue;
                2:
                    SustainabilityAccount."Global Dimension 2 Code" := NewDimValue;
            end;
            SustainabilityAccount.Modify(true);
        end;
    end;
}