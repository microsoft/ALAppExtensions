// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10841 "Payment Report FR"
{
    Caption = 'Payment Report';
    Editable = false;
    PageType = List;
    SourceTable = "Payment Status FR";
    SourceTableView = where(ReportMenu = const(true));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment class.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies text to describe the payment status.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OK)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Print';
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    PaymentLine: Record "Payment Line FR";
                begin
                    PaymentLine.SetRange("Payment Class", Rec."Payment Class");
                    PaymentLine.SetRange("Status No.", Rec.Line);
                    REPORT.RunModal(REPORT::"Payment List FR", true, true, PaymentLine);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(OK_Promoted; OK)
                {
                }
            }
        }
    }
}

