// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using System.Utilities;

report 31286 "Create Payment Recon. Jnl. CZB"
{
    Caption = 'Create Payment Reconciliation Journal';
    Permissions = tabledata "Iss. Bank Statement Header CZB" = m;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Iss. Bank Statement Header CZB"; "Iss. Bank Statement Header CZB")
        {
            RequestFilterFields = "No.";
            dataitem("Iss. Bank Statement Line CZB"; "Iss. Bank Statement Line CZB")
            {
                DataItemLink = "Bank Statement No." = field("No.");
                DataItemTableView = sorting("Bank Statement No.", "Line No.");

                trigger OnAfterGetRecord()
                begin
                    if not HideMessages then
                        WindowDialog.Update(1, "Line No.");

                    CreateBankAccReconciliationLine("Iss. Bank Statement Header CZB", "Iss. Bank Statement Line CZB");
                end;

                trigger OnPostDataItem()
                begin
                    if not HideMessages then
                        WindowDialog.Close();
                end;

                trigger OnPreDataItem()
                begin
                    if not HideMessages then
                        WindowDialog.Open(CreatingLinesMsg);
                end;
            }

            trigger OnAfterGetRecord()
            var
                BankAccReconciliation: Record "Bank Acc. Reconciliation";
                PostedPaymentReconHdr: Record "Posted Payment Recon. Hdr";
                ConfirmManagement: Codeunit "Confirm Management";
                ExistErr: Label '%1 %2 already exist.', Comment = '%1 = TableCaption, %2 = No.';
                ExistJournallinesQst: Label '%1 %2 already exist. Existing journal lines will be deleted and new ones will be created based on the bank statement lines. Do you want to continue?', Comment = '%1 = TableCaption, %2 = No.';
            begin
                if PostedPaymentReconciliationExist("Iss. Bank Statement Header CZB") then
                    Error(ExistErr, PostedPaymentReconHdr.TableCaption(), "No.");
                if PaymentReconcialiationOrGeneralJournalExist() then
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ExistJournallinesQst, BankAccReconciliation.TableCaption(), "No."), false) then
                        Error('')
                    else
                        DeleteBankAccReconsiliation("Iss. Bank Statement Header CZB");
                CreateBankAccReconciliation("Iss. Bank Statement Header CZB");
                UpdatePaymentReconciliationStatus("Payment Reconciliation Status"::Opened);
            end;

            trigger OnPostDataItem()
            begin
                if not HideMessages then
                    Message(SuccessCreatedMsg);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(VariableSymbolToDescriptionCZB; VariableSymbolToDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Variable Symbol to Description';
                        ToolTip = 'Specifies if variable symbol will be transferred to description';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            GetParameters();
        end;
    }

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            GetParameters();
    end;

    var
        WindowDialog: Dialog;
        VariableSymbolToDescription: Boolean;
        VarBankAccReconciliationCreated: Boolean;
        CreatingLinesMsg: Label 'Creating payment reconciliation journal lines...\\Line No. #1##########', Comment = '%1 = Progress bar';
        SuccessCreatedMsg: Label 'Payment reconciliation journal lines were successfully created.';
        HideMessages: Boolean;

    procedure SetHideMessages(HideMessagesNew: Boolean)
    begin
        HideMessages := HideMessagesNew;
    end;

    procedure BankAccReconciliationCreated(): Boolean
    begin
        exit(VarBankAccReconciliationCreated);
    end;

    local procedure GetParameters()
    var
        BankAccount: Record "Bank Account";
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        BankStatementNo: Code[20];
    begin
        BankStatementNo := CopyStr("Iss. Bank Statement Header CZB".GetFilter("No."), 1, MaxStrLen(BankStatementNo));
        if BankStatementNo = '' then
            exit;

        IssBankStatementHeaderCZB.Get(BankStatementNo);
        if BankAccount.Get(IssBankStatementHeaderCZB."Bank Account No.") then
            VariableSymbolToDescription := BankAccount."Variable S. to Description CZB";
    end;

    local procedure CreateBankAccReconciliation(IssBankStatementHeader: Record "Iss. Bank Statement Header CZB")
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        IssBankStatementHeader.CalcFields(Amount);
        BankAccReconciliation.Init();
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Payment Application";
        BankAccReconciliation."Bank Account No." := IssBankStatementHeader."Bank Account No.";
        BankAccReconciliation."Statement No." := IssBankStatementHeader."No.";
        BankAccReconciliation."Statement Date" := IssBankStatementHeader."Document Date";
        BankAccReconciliation."Statement Ending Balance" := IssBankStatementHeader.Amount;
        BankAccReconciliation."Created From Bank Stat. CZB" := true;
        BankAccReconciliation.Insert(true);
    end;

    local procedure CreateBankAccReconciliationLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB")
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.Init();
        BankAccReconciliationLine."Statement Type" := BankAccReconciliationLine."Statement Type"::"Payment Application";
        BankAccReconciliationLine."Transaction Date" := IssBankStatementHeaderCZB."Document Date";
        BankAccReconciliationLine."Bank Account No." := IssBankStatementHeaderCZB."Bank Account No.";
        BankAccReconciliationLine."Statement No." := IssBankStatementHeaderCZB."No.";
        BankAccReconciliationLine."Statement Line No." := IssBankStatementLineCZB."Line No.";
        if (IssBankStatementLineCZB."Currency Code" = '') and (IssBankStatementLineCZB."Bank Statement Currency Code" <> '') then
            BankAccReconciliationLine.Validate(BankAccReconciliationLine."Statement Amount", IssBankStatementLineCZB."Amount (Bank Stat. Currency)")
        else
            BankAccReconciliationLine.Validate(BankAccReconciliationLine."Statement Amount", IssBankStatementLineCZB.Amount);
        BankAccReconciliationLine.Description := IssBankStatementLineCZB.Description;
        BankAccReconciliationLine."Transaction Text" := IssBankStatementLineCZB.Description;
        BankAccReconciliationLine."Related-Party Bank Acc. No." := IssBankStatementLineCZB.IBAN;
        if BankAccReconciliationLine."Related-Party Bank Acc. No." = '' then
            BankAccReconciliationLine."Related-Party Bank Acc. No." := IssBankStatementLineCZB."Account No.";
        BankAccReconciliationLine."Related-Party Name" := IssBankStatementLineCZB.Name;

        if VariableSymbolToDescription and (IssBankStatementLineCZB."Variable Symbol" <> '') then begin
            BankAccReconciliationLine.Description := IssBankStatementLineCZB."Variable Symbol";
            BankAccReconciliationLine."Transaction Text" := IssBankStatementLineCZB."Variable Symbol";
        end;

        OnCreateBankAccReconLineOnBeforeInsertBankAccReconLine(IssBankStatementHeaderCZB, IssBankStatementLineCZB, BankAccReconciliationLine, VariableSymbolToDescription);
        BankAccReconciliationLine.Insert(true);
        VarBankAccReconciliationCreated := true;
    end;

    local procedure PostedPaymentReconciliationExist(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"): Boolean
    var
        PostedPaymentReconHdr: Record "Posted Payment Recon. Hdr";
    begin
        PostedPaymentReconHdr.Reset();
        PostedPaymentReconHdr.SetRange("Bank Account No.", IssBankStatementHeaderCZB."Bank Account No.");
        PostedPaymentReconHdr.SetRange("Statement No.", IssBankStatementHeaderCZB."No.");
        exit(not PostedPaymentReconHdr.IsEmpty());
    end;

    local procedure DeleteBankAccReconsiliation(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BankAccReconciliation.Reset();
        BankAccReconciliation.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
        BankAccReconciliation.SetRange("Bank Account No.", IssBankStatementHeaderCZB."Bank Account No.");
        BankAccReconciliation.SetRange("Statement No.", IssBankStatementHeaderCZB."No.");
        OnDeleteBankAccReconsiliationOnAfterSetBankAccReconsiliationFilters(BankAccReconciliation, IssBankStatementHeaderCZB);
        BankAccReconciliation.DeleteAll(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateBankAccReconLineOnBeforeInsertBankAccReconLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; VariableSymbolToDescription: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteBankAccReconsiliationOnAfterSetBankAccReconsiliationFilters(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    begin
    end;
}
