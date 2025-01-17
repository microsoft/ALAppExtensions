// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Bank.VoucherInterface;
using Microsoft.Finance.GeneralLedger.Setup;

pageextension 18971 "Payment Journal VI" extends "Payment Journal"
{
    layout
    {
        addafter("Bank Payment Type")
        {
            field("Cheque Date"; Rec."Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque date of the journal entry.';
            }
            field("Cheque No."; Rec."Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque number of the journal entry.';
            }
        }
    }
    actions
    {
        modify("Void Check")
        {
            Visible = false;
        }
        addafter("Void Check")
        {
            action("IN_Void_Check")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Void Check';
                Image = VoidCheck;
                Promoted = true;
                PromotedCategory = Category11;
                ToolTip = 'Void the check if, for example, the check is not cashed by the bank.';

                trigger OnAction()
                begin
                    VoidCheckVoucher();
                end;
            }
        }
    }

    var
        VoidLbl: Label 'Void Check %1?', Comment = '%1= Cheque No.';

    local procedure VoidCheckVoucher()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CheckManagementSubscriber: Codeunit "Check Management Subscriber";
    begin
        Rec.TestField("Bank Payment Type", Rec."Bank Payment Type"::"Computer Check");
        Rec.TestField("Check Printed", true);
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Activate Cheque No." then begin
            if Confirm(VoidLbl, false, Rec."Document No.") then
                CheckManagementSubscriber.VoidCheckVoucher(Rec);
        end else
            if Confirm(VoidLbl, false, Rec."Cheque No.") then
                CheckManagementSubscriber.VoidCheckVoucher(Rec);
    end;
}
