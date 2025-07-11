// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

page 18351 "Posted Serv. Transfer Shipment"
{
    Caption = 'Posted Serv. Transfer Shipment';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Service Transfer Shpt. Header";
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;

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
                    ToolTip = 'Specifies the number assigned to posted document.';
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location from which service will be shipped.';

                }
                field("Ship Control Account"; Rec."Ship Control Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies general ledger account number which will be used for ship control.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shipment date of the posted transaction.';
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location where service will be received.';
                }
                field("Receive Control Account"; Rec."Receive Control Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies general ledger account number which will be used for receive control.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the receipt date of the posted transaction.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 1, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 2, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("External Doc No."; Rec."External Doc No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customer or Vendors numbering system.';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who created the document.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the posted transaction. For example,  Shipped/Received.';
                }

            }
            part("Shipment Lines"; "Posted ServTrans Shpt. Subform")
            {
                Caption = 'Shipment Lines';
                SubPageLink = "Document No." = FIELD("No.");
                ApplicationArea = Basic, Suite;
            }
            group("Transfer-from")
            {
                Caption = 'Transfer-from';
                field("Transfer-from Name"; Rec."Transfer-from Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the location from which service will be shipped.';
                }
                field("Transfer-from Name 2"; Rec."Transfer-from Name 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name 2 of the location from which service will be shipped.';
                }
                field("Transfer-from Address"; Rec."Transfer-from Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of the location from which service will be shipped.';
                }
                field("Transfer-from Address 2"; Rec."Transfer-from Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address 2 of the location from which service will be shipped.';
                }
                field("Transfer-from Post Code"; Rec."Transfer-from Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code of the location from which service will be shipped.';
                }
                field("Transfer-from City"; Rec."Transfer-from City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the location from which service will be shipped.';
                }
                field("Transfer-from State"; Rec."Transfer-from State")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of from location.';
                }
            }
            group("Transfer-to")
            {
                Caption = 'Transfer-to';
                field("Transfer-to Name"; Rec."Transfer-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the location where service will be received.';
                }
                field("Transfer-to Name 2"; Rec."Transfer-to Name 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name 2 of the location where service will be received.';
                }
                field("Transfer-to Address"; Rec."Transfer-to Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of the location where service will be received.';
                }
                field("Transfer-to Address 2"; Rec."Transfer-to Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address 2 of the location where service will be received.';
                }
                field("Transfer-to Post Code"; Rec."Transfer-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code of the location where service will be received.';
                }
                field("Transfer-to City"; Rec."Transfer-to City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the location where service will be received.';
                }
                field("Transfer-to State"; Rec."Transfer-to State")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of to location.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Print)
            {
                Caption = 'Print';
                action("&Navigate")
                {
                    Caption = '&Navigate';
                    ApplicationArea = Basic, Suite;
                    Image = Navigate;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                    trigger OnAction()
                    begin
                        Rec.Navigate();
                    end;
                }
            }
        }
    }
}

