// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

page 18814 "Sales Line Buffer TCS On Pmt."
{
    PageType = Worksheet;
    SourceTable = "Sales Line Buffer TCS On Pmt.";
    Caption = 'Sales Lines For TCS On Payment';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the source code.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the open posted sales invoice.';
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the number of the customer account.';
                }
                field("Posted Invoice No."; Rec."Posted Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of open posted sales invoice.';
                }
                field("Invoice Line No."; Rec."Invoice Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the line number of open posted sales invoice.';
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of entity that is posted for this sales line, such as, Item or  G/L Account.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of a general ledger account, item, resource, etc. depending on the contents of the Type field.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the entry, which is based on the contents of the Type and No. fields.';
                }

                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies additional description of the entry, which is based on the contents of the Type and No. fields.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the inventory location from where the items were sold.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how each unit of item or resource is measured, such as in pieces or hours.';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many units are sold.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifes the price for one unit on the posted sales lines.';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the net amount, excluding any discount amount.';
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the discount amount that is granted for the item on the line.';
                }
                field("Inv. Discount Amount"; Rec."Inv. Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the discount amount that is deducted.';
                }
                field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TCS Nature of collection on which the TCS is calculated on open posted sales invoice.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Base amount on which GST is calculated.';
                }
                field("Total GST Amount"; Rec."Total GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total GST amount calculated on posted sales invoice.';
                }
                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the net amount of the posted sales invoice.';
                }
                field("Select"; Rec."Select")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select this field to update amount in TCS on Recpt. Of Pmt. Amount on payment line.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Select All")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Select All';
                Image = CarryOutActionMessage;
                ToolTip = 'Use this field to select all open posted sales invoice lines to update amount in TCS on Recpt. Of Pmt. Amount on payment line.';

                trigger OnAction();
                var
                    SalesLineBufferTCSOnPayment: Record "Sales Line Buffer TCS On Pmt.";
                begin
                    SalesLineBufferTCSOnPayment.CopyFilters(Rec);
                    SalesLineBufferTCSOnPayment.SetRange(Select, false);
                    SalesLineBufferTCSOnPayment.ModifyAll(Select, true);
                    CurrPage.Update(true);
                end;
            }
            action("Unselect All")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unselect All';
                Image = CarryOutActionMessage;
                ToolTip = 'Use this field to unselect all open posted sales invoice lines to update amount in TCS on Recpt. Of Pmt. Amount on payment line.';

                trigger OnAction();
                var
                    SalesLineBufferTCSOnPayment: Record "Sales Line Buffer TCS On Pmt.";
                begin
                    SalesLineBufferTCSOnPayment.CopyFilters(Rec);
                    SalesLineBufferTCSOnPayment.SetRange(Select, true);
                    SalesLineBufferTCSOnPayment.ModifyAll(Select, false);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}
