namespace Microsoft.DataMigration.GP.HistoricalData;

using Microsoft.Inventory.Item;

page 41028 "Hist. Recv. Trx. SerlLot. List"
{
    Caption = 'Historical Receivables Transaction Serial/Lot List';
    AdditionalSearchTerms = 'history,snapshot,serial,lot';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Recv. Trx. SerialLot";
    CardPageId = "Hist. Recv. Trx. SerialLot";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Serial/Lot Number"; Rec."Serial/Lot Number")
                {
                    ToolTip = 'Specifies the value of the Serial/Lot Number field.';
                }
                field("Serial/Lot Qty."; Rec."Serial/Lot Qty.")
                {
                    ToolTip = 'Specifies the value of the Serial/Lot Qty. field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                        ItemCard: Page "Item Card";
                    begin
                        if Item.Get(Rec."Item No.") then begin
                            ItemCard.SetRecord(Item);
                            ItemCard.Run()
                        end else
                            Message(CouldNotFindRecordMsg);
                    end;
                }
                field("Qty. Type"; Rec."Qty. Type")
                {
                    ToolTip = 'Specifies the value of the Qty. Type field.';
                }
                field("Date Received"; Rec."Date Received")
                {
                    ToolTip = 'Specifies the value of the Date Received field.';
                }
                field("Date Sequence No."; Rec."Date Sequence No.")
                {
                    ToolTip = 'Specifies the value of the Date Sequence No. field.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Unit Cost field.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';

                    trigger OnDrillDown()
                    var
                        HistSalesTrxHeader: Record "Hist. Sales Trx. Header";
                        HistSalesTrxCard: Page "Hist. Sales Trx.";
                    begin
                        HistSalesTrxHeader.SetRange("Sales Trx. Type", Rec."Sales Trx. Type");
                        HistSalesTrxHeader.SetRange("No.", Rec."No.");

                        if HistSalesTrxHeader.FindFirst() then begin
                            HistSalesTrxCard.SetRecord(HistSalesTrxHeader);
                            HistSalesTrxCard.Run();
                        end else
                            Message(CouldNotFindRecordMsg);
                    end;
                }
                field("Sales Trx. Type"; Rec."Sales Trx. Type")
                {
                    ToolTip = 'Specifies the value of the Sales Trx. Type field.';
                }
                field("Line Item Sequence"; Rec."Line Item Sequence")
                {
                    ToolTip = 'Specifies the value of the Line Item Sequence field.';
                }
                field("Component Sequence"; Rec."Component Sequence")
                {
                    ToolTip = 'Specifies the value of the Component Sequence field.';
                }
                field("Serial/Lot Seq. Number"; Rec."Serial/Lot Seq. Number")
                {
                    ToolTip = 'Specifies the value of the Serial/Lot Seq. Number field.';
                }
                field("Override Serial/Lot"; Rec."Override Serial/Lot")
                {
                    ToolTip = 'Specifies the value of the Override Serial/Lot field.';
                }
                field("Bin"; Rec."Bin")
                {
                    ToolTip = 'Specifies the value of the Bin field.';
                }
                field("Manufacture Date"; Rec."Manufacture Date")
                {
                    ToolTip = 'Specifies the value of the Manufacture Date field.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ToolTip = 'Specifies the value of the Expiration Date field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ViewDetails)
            {
                ApplicationArea = All;
                Caption = 'View Details';
                ToolTip = 'View more details about this entry.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Find;
                ShortcutKey = Return;

                trigger OnAction()
                var
                    HistRecvTrxSerialLot: Page "Hist. Recv. Trx. SerialLot";
                begin
                    HistRecvTrxSerialLot.SetRecord(Rec);
                    HistRecvTrxSerialLot.Run();
                end;
            }
        }
    }

    internal procedure SetFilterSalesTrxLine(var HistSalesTrxLine: Record "Hist. Sales Trx. Line")
    begin
        Rec.SetRange("Sales Trx. Type", HistSalesTrxLine."Sales Trx. Type");
        Rec.SetRange("No.", HistSalesTrxLine."Sales Header No.");
        Rec.SetRange("Line Item Sequence", HistSalesTrxLine."Line Item Sequence No.");
    end;

    var
        CouldNotFindRecordMsg: Label 'Could not find the matching record.';
}