namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;

page 7251 "Bank Acc. Rec. AI Proposal Sub"
{
    Caption = 'Match Proposals';
    PageType = ListPart;
    ApplicationArea = All;
    Extensible = false;
    SourceTable = "Bank Acc. Rec. AI Prop. Buf.";
    SourceTableTemporary = true;
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    InherentPermissions = X;
    InherentEntitlements = X;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the transaction date';

                    trigger OnDrillDown()
                    begin
                        OpenStatementLine();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the transaction description';
                }
                field(Difference; Rec.Difference)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the amount to apply';
                }
                field("AI Proposal"; Rec."AI Proposal")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the action proposed by the AI';

                    trigger OnDrillDown()
                    begin
                        OpenProposedRecord();
                    end;
                }
                field("Map Text to Account"; MapTextToAccountTxt)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    ToolTip = 'Specifies a drill-down to save this proposal and reuse it next time';
                    Visible = MapTextToAccountVisible;

                    trigger OnDrillDown()
                    begin
                        SaveToTextToAccountMapping();
                    end;

                }
            }
        }
    }

    local procedure OpenProposedRecord()
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempBankAccountLedgerEntry: Record "Bank Account Ledger Entry" temporary;
        GLAccount: Record "G/L Account";
        SelectedGLAccount: Record "G/L Account";
        LookupGLAccount: Record "G/L Account";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        GLAccountList: Page "G/L Account List";
    begin
        TempInitialBankAccRecAIProposal.Reset();
        TempInitialBankAccRecAIProposal.SetRange("Statement Type", Rec."Statement Type");
        TempInitialBankAccRecAIProposal.SetRange("Bank Account No.", Rec."Bank Account No.");
        TempInitialBankAccRecAIProposal.SetRange("Statement No.", Rec."Statement No.");
        TempInitialBankAccRecAIProposal.SetRange("Statement Line No.", Rec."Statement Line No.");
        TempInitialBankAccRecAIProposal.SetFilter("Bank Account Ledger Entry No.", '<>0');

        if (Rec."G/L Account No." <> '') or ((Rec."G/L Account No." = '') and TempInitialBankAccRecAIProposal.IsEmpty()) then begin
            LookupGLAccount.SetRange("Direct Posting", true);
            if not LookupGLAccount.IsEmpty() then begin
                GLAccountList.LookupMode(true);
                GLAccountList.SetTableView(LookupGLAccount);
                if GLAccount.Get(Rec."G/L Account No.") then
                    GLAccountList.SetRecord(GLAccount);
                if GLAccountList.RunModal() = Action::LookupOK then begin
                    GLAccountList.SetSelection(SelectedGLAccount);
                    if SelectedGLAccount.FindFirst() then
                        if Rec."G/L Account No." <> SelectedGLAccount."No." then begin
                            Rec.Validate("G/L Account No.", SelectedGLAccount."No.");
                            Rec.Modify();
                            Session.LogMessage('0000LET', TelemetryUserChangedProposalTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
                            CurrPage.Update();
                            exit;
                        end;
                end;
            end;
            exit;
        end;

        if not TempInitialBankAccRecAIProposal.IsEmpty() then begin
            TempInitialBankAccRecAIProposal.Reset();
            TempInitialBankAccRecAIProposal.SetRange("Statement Type", Rec."Statement Type");
            TempInitialBankAccRecAIProposal.SetRange("Bank Account No.", Rec."Bank Account No.");
            TempInitialBankAccRecAIProposal.SetRange("Statement No.", Rec."Statement No.");
            TempInitialBankAccRecAIProposal.SetRange("Statement Line No.", Rec."Statement Line No.");
            TempInitialBankAccRecAIProposal.SetFilter("Bank Account Ledger Entry No.", '<>0');
            if TempInitialBankAccRecAIProposal.FindSet() then
                repeat
                    if BankAccountLedgerEntry.Get(TempInitialBankAccRecAIProposal."Bank Account Ledger Entry No.") then begin
                        OnBeforeOpenProposedRecordOnBeforeCopyFromBankAccLedgerEntry(TempBankAccountLedgerEntry, BankAccountLedgerEntry);
                        TempBankAccountLedgerEntry.CopyFromBankAccLedgerEntry(BankAccountLedgerEntry, '');
                    end;
                until TempInitialBankAccRecAIProposal.Next() = 0;

            Page.Run(Page::"Bank Account Ledger Entries", TempBankAccountLedgerEntry);
            exit;
        end;
    end;

    local procedure OpenStatementLine()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary;
    begin
        if BankAccReconciliationLine.Get(Rec."Statement Type", Rec."Bank Account No.", Rec."Statement No.", Rec."Statement Line No.") then begin
            TempBankAccReconciliationLine.TransferFields(BankAccReconciliationLine, true);
            TempBankAccReconciliationLine.Insert();
            Page.Run(Page::"Bank Acc. Reconciliation Lines", TempBankAccReconciliationLine);
        end;
    end;

    internal procedure Load(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary): Integer
    var
        StatementLines: List of [Integer];
        StatementLinesCount: Integer;
    begin
        TempBankAccRecAIProposal.Reset();
        MapTextToAccountVisible := false;
        if TempBankAccRecAIProposal.FindSet() then
            repeat
                TempInitialBankAccRecAIProposal.Copy(TempBankAccRecAIProposal, false);
                TempInitialBankAccRecAIProposal.Insert();
                if not StatementLines.Contains(TempBankAccRecAIProposal."Statement Line No.") then begin
                    Rec."Statement Type" := TempBankAccRecAIProposal."Statement Type";
                    Rec."Bank Account No." := TempBankAccRecAIProposal."Bank Account No.";
                    Rec."Statement No." := TempBankAccRecAIProposal."Statement No.";
                    Rec."Statement Line No." := TempBankAccRecAIProposal."Statement Line No.";
                    Rec."Document No." := TempBankAccRecAIProposal."Document No.";
                    Rec."G/L Account No." := TempBankAccRecAIProposal."G/L Account No.";
                    Rec."Transaction Date" := TempBankAccRecAIProposal."Transaction Date";
                    Rec."AI Proposal" := TempBankAccRecAIProposal."AI Proposal";
                    Rec.Difference := TempBankAccRecAIProposal.Difference;
                    Rec.Description := TempBankAccRecAIProposal.Description;
                    Rec.Insert();
                    StatementLines.Add(TempBankAccRecAIProposal."Statement Line No.");
                    if (TempBankAccRecAIProposal."Bank Account Ledger Entry No." <> 0) or (TempBankAccRecAIProposal."G/L Account No." <> '') then
                        StatementLinesCount += 1;
                end
                else begin
                    Rec.Get(TempBankAccRecAIProposal."Statement Type", TempBankAccRecAIProposal."Bank Account No.", TempBankAccRecAIProposal."Statement No.", TempBankAccRecAIProposal."Statement Line No.");
                    Rec."AI Proposal" := ApplyToMultipleLedgerEntriesTxt;
                    Rec.Modify();
                end;
                if TempBankAccRecAIProposal."Bank Account Ledger Entry No." = 0 then
                    MapTextToAccountVisible := true;
            until TempBankAccRecAIProposal.Next() = 0;
        CurrPage.Update();
        exit(StatementLinesCount);
    end;

    local procedure SaveToTextToAccountMapping()
    var
        BankAccRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
    begin
        Session.LogMessage('0000LEU', TelemetryUserSavingProposalTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
        if Rec."G/L Account No." = '' then
            exit;

        BankAccRecTransToAcc.InsertTextToAccountMapping(Rec);
    end;

    internal procedure GetTempRecord(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary)
    begin
        TempBankAccRecAIProposal.DeleteAll();
        Rec.Reset();
        if Rec.FindSet() then
            repeat
                TempInitialBankAccRecAIProposal.Reset();
                TempInitialBankAccRecAIProposal.SetRange("Statement Type", Rec."Statement Type");
                TempInitialBankAccRecAIProposal.SetRange("Bank Account No.", Rec."Bank Account No.");
                TempInitialBankAccRecAIProposal.SetRange("Statement No.", Rec."Statement No.");
                TempInitialBankAccRecAIProposal.SetRange("Statement Line No.", Rec."Statement Line No.");
                if TempInitialBankAccRecAIProposal.FindSet() then
                    repeat
                        TempBankAccRecAIProposal.Copy(TempInitialBankAccRecAIProposal, false);
                        if Rec."G/L Account No." <> '' then
                            if Rec."G/L Account No." <> TempBankAccRecAIProposal."G/L Account No." then
                                TempBankAccRecAIProposal."G/L Account No." := Rec."G/L Account No.";
                        TempBankAccRecAIProposal.Insert();
                    until TempInitialBankAccRecAIProposal.Next() = 0;
            until Rec.Next() = 0;
    end;

    var
        TempInitialBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        MapTextToAccountVisible: Boolean;
        MapTextToAccountTxt: label 'Save...';
        ApplyToMultipleLedgerEntriesTxt: label 'Apply to multiple entries. Drill down to see more.';
        TelemetryUserSavingProposalTxt: label 'User saving Copilot proposal in Text-toAccount Mapping table', Locked = true;
        TelemetryUserChangedProposalTxt: label 'User changed Copilot proposal for transfering to G/L Account', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenProposedRecordOnBeforeCopyFromBankAccLedgerEntry(var TempBankAccountLedgerEntry: Record "Bank Account Ledger Entry" temporary; var BankAccountLedgerEntry: Record "Bank Account Ledger Entry")
    begin
    end;
}