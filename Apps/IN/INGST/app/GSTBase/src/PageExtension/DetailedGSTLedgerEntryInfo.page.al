// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

page 18009 "Detailed GST Ledger Entry Info"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Detailed GST Ledger Entry Info";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who posted the transaction.';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the amount in the line is positive or not.';
                }
                field("Nature of Supply"; Rec."Nature of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of location.';
                }
                field("Buyer/Seller State Code"; Rec."Buyer/Seller State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer/vendor state code.';
                }
                field("Bill Of Export No."; Rec."Bill Of Export No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bill of export number. It is a document number which is submitted to custom department .';
                }
                field("Bill Of Export Date"; Rec."Bill Of Export Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry date defined in bill of export document.';
                }
                field("Sales Invoice Type"; Rec."Sales Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice type of the sales transaction.';
                }
                field("Component Calc. Type"; Rec."Component Calc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Component Calc. Type for the ledger Entry.';
                }
                field("Cess Amount Per Unit Factor"; Rec."Cess Amount Per Unit Factor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Cess Amount per Unit Factor for the ledger entry.';
                }
                field("Cess UOM"; Rec."Cess UOM")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Cess Unit of Measure for the ledger entry.';
                }
                field("Cess Factor Quantity"; Rec."Cess Factor Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Cess Factor Quantity for the ledger entry.';
                }
                field("Bill of Entry No."; Rec."Bill of Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bill of entry number. It is a document number which is submitted to custom department.';
                }
                field("Bill of Entry Date"; Rec."Bill of Entry Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Bill of entry date on the GST ledger entry.';
                }
                field("Jnl. Bank Charge"; Rec."Jnl. Bank Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank charge code.';
                }
                field("RCM Exempt"; Rec."RCM Exempt")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the RCM exempt on the GST ledger entry.';
                }
                field("GST Base Amount FCY"; Rec."GST Base Amount FCY")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the tax amount computed by applying GST percentage on GST base in foreign currency';
                }
                field("GST Amount FCY"; Rec."GST Amount FCY")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the tax amount in foreign currency, computed by applying GST percentage on GST base.';
                }
            }
        }
    }
}
