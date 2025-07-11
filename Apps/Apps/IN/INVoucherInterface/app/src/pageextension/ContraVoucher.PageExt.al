// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Bank.VoucherInterface;

pageextension 18945 "Contra Voucher" extends "Contra Voucher"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Cheque No."; "Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque number of the journal entry.';
            }
            field("Cheque Date"; "Cheque Date")
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
                    begin
                        CheckManagementSubscriber.OnActionPrintCheckforContravoucher(Rec);
                    end;
                }
                action("Void Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Void Check';
                    ToolTip = 'Select this option to void one check. Select the line with Computer Check in the Bank Payment Type field on the Journal.';
                    Image = VoidCheck;

                    trigger OnAction()
                    begin
                        Rec.TestField("Bank Payment Type", Rec."Bank Payment Type"::"Computer Check");
                        Rec.TestField("Check Printed", true);
                        CheckManagementSubscriber.OnActionVoidCheckforContravoucher(Rec);
                    end;
                }
                action("Void &All Checks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Void &All Checks';
                    ToolTip = 'Select this option to void all checks which have printed but not posted on the journal';
                    Image = VoidAllChecks;

                    trigger OnAction()
                    begin
                        CheckManagementSubscriber.OnActionVoidAllChecksforContravoucher(Rec);
                    end;
                }
            }
        }
    }

    var
        CheckManagementSubscriber: Codeunit "Check Management Subscriber";
}
