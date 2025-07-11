// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18486 "Posted Subcon Comp. Receipt"
{
    Caption = 'Posted Subcon Comp. Receipt';
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Sub. Comp. Rcpt. Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item number is linked to.';
                    Editable = false;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the buy from vendor number is linked to.';
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the buy from vendor name.';
                    Editable = false;
                }
                field("Buy-from Address"; Rec."Buy-from Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the buy from vendor Address';
                    Editable = false;
                }
                field("Buy-from Address 2"; Rec."Buy-from Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the buy from vendor Address 2';
                    Editable = false;
                }
                field("Buy-from Post Code"; Rec."Buy-from Post Code")
                {
                    Caption = 'Buy-from Post Code/City';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the buy from postal code';
                    Editable = false;
                }
                field("Buy-from City"; Rec."Buy-from City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the buy from City';
                    Editable = false;
                }
                field("Buy-from Contact"; Rec."Buy-from Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the buy from Contact';
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                    Editable = false;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order number.';
                    Editable = false;
                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor order number.';
                    Editable = false;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor shipment number.';
                    Editable = false;
                }
                field("Order Address Code"; Rec."Order Address Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order address code of the vendor.';
                    Editable = false;
                }
            }
            part(PostedSubCompRcptSubform; "Posted SubComp. Rcpt. Subform")
            {
                SubPageLink = "Document No." = field("No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Navigate';
                ToolTip = 'Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }
        }
    }
}
