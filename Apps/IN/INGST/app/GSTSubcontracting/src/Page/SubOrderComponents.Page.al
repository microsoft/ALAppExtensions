// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;

page 18496 "Sub Order Components"
{
    AutoSplitKey = true;
    Caption = 'Sub Order Components';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Sub Order Component List";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item number is linked to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the item.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure of the item.';
                }
                field("Total Qty at Vendor Location"; Rec."Total Qty at Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total quantity of the item at vendor location.';
                }
                field("Qty. at Vendor Location"; Rec."Qty. at Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of the item at vendor location.';
                }
                field("Prod. Order Qty."; Rec."Prod. Order Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order quantity.';
                }
                field("Quantity To Send"; Rec."Quantity To Send")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Quantity to Send';
                }
                field("Qty. for Rework"; Rec."Qty. for Rework")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity needs to send for Rework';
                }
                field("Company Location"; Rec."Company Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company location code for the document.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Bin Code for the company location.';
                }
                field("Vendor Location"; Rec."Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor location code for the document.';
                }
                field("Job Work Return Period"; Rec."Job Work Return Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job work return period for the document.';
                }
                field("Identification Mark"; Rec."Identification Mark")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the identification mark for the item is linked to.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    ToolTip = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        ShowDimension();
                    end;
                }
                group("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = AllLines;
                    action("Quantity Send")
                    {
                        Caption = 'Quantity To Send';
                        ToolTip = 'Quantity to Send';
                        Image = SendTo;
                        ApplicationArea = Basic, Suite;

                        trigger OnAction()
                        begin
                            ShowItemTrackingSubcon();
                        end;
                    }
                }
            }
        }
    }


    procedure CalculateQuantitytoSend(PurchaseLine: Record "Purchase Line"; Quantity: Decimal)
    begin
        Rec.CalculateQtyToSend(PurchaseLine, Quantity);
    end;

    procedure ShowItemTracking()
    begin
        Rec.OpenItemTrackingLines(Rec);
    end;

    procedure ShowDimension()
    begin
        Rec.ShowDimensions();
    end;

    procedure ShowItemTrackingSubcon()
    begin
        Rec.OpenItemTrackingLinesSubcon();
    end;
}
