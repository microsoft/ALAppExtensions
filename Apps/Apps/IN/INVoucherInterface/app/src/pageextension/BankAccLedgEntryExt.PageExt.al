// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Ledger;

pageextension 18938 "Bank Acc Ledg Entry Ext" extends "Bank Account Ledger Entries"
{
    layout
    {
        addafter(Description)
        {
            field("Cheque No."; Rec."Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the cheque number on the bank account ledger entry.';
            }
            field("Cheque Date"; Rec."Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the cheque date on the bank account ledger entry.';
            }
            field("Stale Cheque"; Rec."Stale Cheque")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if the cheque has been marked as stale on the bank account ledger entry.';
            }
            field("Stale Cheque Expiry Date"; Rec."Stale Cheque Expiry Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the date before which the cheque cannot be marked as stale cheque on the bank account ledger entry.';
            }
            field("Cheque Stale Date"; Rec."Cheque Stale Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the cheque stale date on the bank account ledger entry.';
            }
        }
    }

    actions
    {
        addafter("Reverse Transaction")
        {
            action("Stale_Check")
            {
                Caption = 'Stale Check';
                ApplicationArea = Basic, Suite;
                Image = StaleCheck;
                ToolTip = 'Select this option to  mark a check as stale. This function will update Stale Check, Check Stale Date and Entry Status fields to indicate that the check is void.';
                trigger OnAction()
                begin
                    if Rec."Stale Cheque" = true then
                        Message(ChequeMarkedStaleMsg)
                    else
                        if Confirm(StaleConfirmLbl, false, Rec."Cheque No.", Rec."Bal. Account Type", Rec."Bal. Account No.") then begin
                            if Rec."Stale Cheque Expiry Date" >= WorkDate() then
                                Error(StaleChequeExpiryDateErr, Rec."Stale Cheque Expiry Date");
                            Rec."Stale Cheque" := true;
                            Rec."Cheque Stale Date" := WorkDate();
                            Rec.Modify();
                        end;
                end;
            }
        }
    }

    var
        StaleChequeExpiryDateErr: Label 'Bank Ledger Entry can be marked as stale only after %1.', Comment = '%1 = Stale Cheque Expiry Date';
        ChequeMarkedStaleMsg: Label 'The cheque has already been marked stale.';
        StaleConfirmLbl: Label 'Financially stale check %1 to %2 %3', Comment = '%1= Cheque No, %2 = Balance Account Type, %3= Balance Account No.';
}
