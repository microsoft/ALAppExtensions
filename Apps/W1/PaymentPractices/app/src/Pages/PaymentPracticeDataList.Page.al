// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

page 686 "Payment Practice Data List"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Payment Practice Data";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                Caption = 'Lines';
                Editable = false;

                field("Invoice Entry No."; Rec."Invoice Entry No.")
                {
                    ToolTip = 'Specifies the invoice entry number that is the source for this entry.';
                }
                field("Payment Entry No."; Rec."Pmt. Entry No.")
                {
                    ToolTip = 'Specifies the closing payment entry number that is associated with the source invoicy entry, if any was applied.';
                }
                field("Invoice Posting Date"; Rec."Invoice Posting Date")
                {
                    ToolTip = 'Specifies the posting date of the invoice entry that is the source for this entry.';
                }
                field("Invoice Received Date"; Rec."Invoice Received Date")
                {
                    ToolTip = 'Specifies the date the invoice was received that is the source for this buffer entry. If empty, the posting date is used.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the due date of the invoice entry that is the source for this entry.';
                }
                field("Pmt. Posting Date"; Rec."Pmt. Posting Date")
                {
                    ToolTip = 'Specifies the posting date of the payment entry that is associated with the source invoicy entry, if any was applied.';
                }
                field("Invoice Is Open"; Rec."Invoice Is Open")
                {
                    ToolTip = 'Specifies whether the invoice entry that is the source for this entry is open.';
                }
                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ToolTip = 'Specifies the amount of the invoice entry that is the source for this entry.';
                }
                field("Company Size Code"; Rec."Company Size Code")
                {
                    ToolTip = 'Specifies the company size code of the vendor that is the source for this entry.';
                }
                field("Agreed Payment Days"; Rec."Agreed Payment Days")
                {
                    ToolTip = 'Specifies the number of days that was the agreed period for payment for the invoice.';
                }
                field("Actual Payment Days"; Rec."Actual Payment Days")
                {
                    ToolTip = 'Specifies the number of days that was the actual period for payment for the invoice.';
                    Style = Unfavorable;
                    StyleExpr = Rec."Actual Payment Days" > Rec."Agreed Payment Days";
                }
            }
        }
    }
}
