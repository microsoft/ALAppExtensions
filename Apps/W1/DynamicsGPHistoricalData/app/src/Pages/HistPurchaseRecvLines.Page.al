namespace Microsoft.DataMigration.GP.HistoricalData;

page 41015 "Hist. Purchase Recv. Lines"
{
    Caption = 'Historical Purchase Recv. Trx. Lines';
    PageType = ListPart;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Purchase Recv. Line";

    layout
    {
        area(Content)
        {
            repeater(ListData)
            {
                field("PO Number"; Rec."PO Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PO Number field.';
                }
                field("Actual Ship Date"; Rec."Actual Ship Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Actual Ship Date field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Item Desc."; Rec."Item Desc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Desc. field.';
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Item No. field.';
                }
                field("Vendor Item Desc."; Rec."Vendor Item Desc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Item Desc. field.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure field.';
                }
                field("Base UofM Qty."; Rec."Base UofM Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base UofM Qty. field.';
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Shipped field.';
                }
                field("Quantity Invoiced"; Rec."Quantity Invoiced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Invoiced field.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost field.';
                }
                field("Ext. Cost"; Rec."Ext. Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ext. Cost field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("Ship Method"; Rec."Ship Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship Method field.';
                }
                field("Orig. Unit Cost"; Rec."Orig. Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. Unit Cost field.';
                }
                field("Orig. Ext. Cost"; Rec."Orig. Ext. Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. Ext. Cost field.';
                }
                field("Orig. Disc. Taken Amount"; Rec."Orig. Disc. Taken Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. Disc. Taken Amount field.';
                }
                field("Orig. Trade Disc. Amount"; Rec."Orig. Trade Disc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. Trade Disc. Amount field.';
                }
                field("Orig. Freight Amount"; Rec."Orig. Freight Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. Freight Amount field.';
                }
                field("Orig. Misc. Amount"; Rec."Orig. Misc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. Misc. Amount field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
            }
        }
    }
}