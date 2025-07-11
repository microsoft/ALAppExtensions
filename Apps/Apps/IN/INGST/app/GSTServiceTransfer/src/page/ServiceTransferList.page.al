// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;

page 18357 "Service Transfer List"
{
    Caption = 'Service Transfer List';
    CardPageID = "Service Transfer Order";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Document';
    SourceTable = "Service Transfer Header";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the location that services are transferred from.';
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the location that services are transferred to.';
                }
                field("Ship Control Account"; Rec."Ship Control Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number used for ship control account.';
                }
                field("Receive Control Account"; Rec."Receive Control Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number used for receive control account.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shipment date of the service transfer order.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transfer order is open or released.';
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
            }
        }
        area(factboxes)
        {
            systempart(RecordLinks; Links)
            {
                Visible = false;
                ApplicationArea = Basic, Suite;
            }
            systempart(Notes; Notes)
            {
                Visible = true;
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Order)
            {
                Caption = 'Order';
                Image = "Order";
                action(Dimensions)
                {
                    AccessByPermission = TableData "Dimension" = R;
                    Caption = 'Dimensions';
                    ApplicationArea = Dimensions;
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Dimensions (Shift+Ctrl+D)';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("<Page Posted Serv. Trans. Shipme>")
                {
                    Caption = 'S&hipments';
                    ApplicationArea = Basic, Suite;
                    Image = Shipment;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Posted Serv. Transfer Shipment";
                    RunPageLink = "Service Transfer Order No." = FIELD("No.");
                    ToolTip = 'View a list of posted Service transfer shipments for the document.';

                }
                action("<Page Posted Serv. Trans. Receip>")
                {
                    Caption = 'Re&ceipts';
                    Image = PostedReceipts;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'View a list of posted Service transfer receipts for the document.';
                    RunObject = Page "Posted Serv. Trans. Receipts";
                    RunPageLink = "Service Transfer Order No." = FIELD("No.");
                }
            }
        }
    }
}
