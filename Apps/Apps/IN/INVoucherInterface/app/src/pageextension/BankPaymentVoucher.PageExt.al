// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Bank.VoucherInterface;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Reporting;

pageextension 18941 "Bank Payment Voucher" extends "Bank Payment Voucher"
{
    layout
    {
        modify("Bank Payment Type")
        {
            Visible = true;
        }
        addafter("Bank Payment Type")
        {
            field("Cheque No."; Rec."Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque number of the journal entry.';
            }
            field("Cheque Date"; Rec."Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque date of the journal entry.';
            }
        }
        addbefore(Narration)
        {
            group("Cheque_No.")
            {
                ShowCaption = false;

                field("Cheque No.2"; Rec."Cheque No.")
                {
                    Caption = 'Cheque No.';
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cheque number of the journal entry.';
                }
            }
        }
    }

    actions
    {
        addafter(Approvals)
        {
            group("&Check")
            {
                Caption = '&Check';
                Image = Check;

                action("P&review Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&review Check';
                    ToolTip = 'Select this option to preview computer check, if the Bank Payment Type field on the Payment Journal window is set to Computer Check, the checks must be printed before posting the journal.';
                    Image = ViewCheck;
                    RunObject = Page "Check Preview Custom";
                    RunPageLink = "Journal Template Name" = field("Journal Template Name"),
                                  "Journal Batch Name" = field("Journal Batch Name"),
                                  "Line No." = field("Line No.");
                }
                action("Print Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Check';
                    ToolTip = 'Select this option to Print computer check, if the Bank Payment Type field on the Payment Journal window is set to Computer Check, the checks must be printed before posting the journal.';
                    Ellipsis = true;
                    Image = PrintCheck;

                    trigger OnAction()
                    var
                        GenJournalLine: Record "Gen. Journal Line";
                        DocumentPrint: Codeunit "Document-Print";
                    begin
                        GenJournalLine.Reset();
                        GenJournalLine.Copy(Rec);
                        DocumentPrint.PrintCheck(GenJournalLine);
                        Codeunit.Run(Codeunit::"Adjust Gen. Journal Balance", GenJournalLine);
                    end;
                }
                action("Void Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Void Check';
                    ToolTip = 'Select this option to void one check. Select the line with Computer Check in the Bank Payment Type field on the Journal.';
                    Image = VoidCheck;

                    trigger OnAction()
                    var
                        GeneralLedgerSetup: Record "General Ledger Setup";
                        CheckManagementSubscriber: Codeunit "Check Management Subscriber";
                    begin
                        Rec.TestField("Bank Payment Type", Rec."Bank Payment Type"::"Computer Check");
                        Rec.TestField("Check Printed", true);
                        GeneralLedgerSetup.Get();
                        if not GeneralLedgerSetup."Activate Cheque No." then begin
                            if Confirm(VoidCheckConfirmationLbl, false, Rec."Document No.") then
                                CheckManagementSubscriber.VoidCheckVoucher(Rec);
                        end else
                            if Confirm(VoidCheckConfirmationLbl, false, Rec."Cheque No.") then
                                CheckManagementSubscriber.VoidCheckVoucher(Rec);
                    end;
                }
                action("Void &All Checks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Void &All Checks';
                    ToolTip = 'Select this option to void all checks which have printed but not posted on the journal';
                    Image = VoidAllChecks;

                    trigger OnAction()
                    var
                        GenJournalLine: Record "Gen. Journal Line";
                        CheckManagement: Codeunit "Check Management Subscriber";
                    begin
                        if Confirm(VoidAllCheckLbl, false) then begin
                            GenJournalLine.Reset();
                            GenJournalLine.Copy(Rec);
                            GenJournalLine.SetRange("Bank Payment Type", Rec."Bank Payment Type"::"Computer Check");
                            GenJournalLine.SetRange("Check Printed", true);
                            if GenJournalLine.FindSet() then
                                repeat
                                    CheckManagement.VoidCheckVoucher(Rec);
                                until GenJournalLine.Next() = 0;
                        end;
                    end;
                }
            }
        }
    }

    var
        VoidCheckConfirmationLbl: Label 'Void Check %1?', Comment = '%1 = Check No';
        VoidAllCheckLbl: Label 'Void all printed checks?';
}
