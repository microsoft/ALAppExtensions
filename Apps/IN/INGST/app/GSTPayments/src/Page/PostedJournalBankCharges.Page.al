// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

page 18248 "Posted Journal Bank Charges"
{
    PageType = list;
    Caption = 'Posted Journal Bank Charges';
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Posted Jnl. Bank Charges";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Bank Charge"; Rec."Bank Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank charge code.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank charge amount of the journal line.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customer/Vendors/Banks numbering system.';
                }
                field(Exempted; Rec.Exempted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the journal is exempted from GST.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount in local currency as defined in company information.';
                }
                field("Foreign Exchange"; Rec."Foreign Exchange")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction has a foreign currency involved.';
                }
                field("GST Document Type"; Rec."GST Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Document Type of the journal.';
                }
                field(LCY; Rec.LCY)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is in local currency.';
                }
            }
        }
    }
}
