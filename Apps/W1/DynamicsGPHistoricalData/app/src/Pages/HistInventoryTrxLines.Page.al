namespace Microsoft.DataMigration.GP.HistoricalData;

page 41011 "Hist. Inventory Trx. Lines"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Historical Inventory Trx. Lines';
    PageType = ListPart;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Inventory Trx. Line";

    layout
    {
        area(Content)
        {
            repeater(ListData)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';

                    trigger OnDrillDown()
                    var
                        HistInvtTrxSerlLotList: Page "Hist. Invt. Trx. SerlLot. List";
                    begin
                        HistInvtTrxSerlLotList.SetFilterInventoryTrxLine(Rec);
                        HistInvtTrxSerlLotList.Run();
                    end;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Unit Cost field.';
                }
                field("Ext. Cost"; Rec."Ext. Cost")
                {
                    ToolTip = 'Specifies the value of the Ext. Cost field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("Transfer To Location Code"; Rec."Transfer To Location Code")
                {
                    ToolTip = 'Specifies the value of the Transfer To Location Code field.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ToolTip = 'Specifies the value of the Reason Code field.';
                }
                field("Source Description"; Rec."Source Description")
                {
                    ToolTip = 'Specifies the value of the Source Description field.';
                }
            }
        }
    }
}