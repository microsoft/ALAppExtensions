namespace Microsoft.DataMigration.GP.HistoricalData;
using Microsoft.Inventory.Item;

page 41030 "Hist. Invt. Trx. SerlLot. List"
{
    Caption = 'Historical Inventory Transaction Serial/Lot List';
    AdditionalSearchTerms = 'history,snapshot,serial,lot';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Invt. Trx. SerialLot";
    CardPageId = "Hist. Invt. Trx. SerialLot";

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

                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';

                    trigger OnDrillDown()
                    var
                        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
                        HistInventoryTrx: Page "Hist. Inventory Trx.";
                    begin
                        HistInventoryTrxHeader.SetRange("Document Type", Rec."Document Type");
                        HistInventoryTrxHeader.SetRange("Document No.", Rec."Document No.");

                        if HistInventoryTrxHeader.FindFirst() then begin
                            HistInventoryTrx.SetRecord(HistInventoryTrxHeader);
                            HistInventoryTrx.Run();
                        end else
                            Message(CouldNotFindRecordMsg);
                    end;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Line Sequence Number"; Rec."Line Sequence Number")
                {
                    ToolTip = 'Specifies the value of the Line Sequence Number field.';
                }
                field("Serial/Lot Seq. Number"; Rec."Serial/Lot Seq. Number")
                {
                    ToolTip = 'Specifies the value of the Serial/Lot Seq. Number field.';
                }
                field("From Bin"; Rec."From Bin")
                {
                    ToolTip = 'Specifies the value of the From Bin field.';
                }
                field("To Bin"; Rec."To Bin")
                {
                    ToolTip = 'Specifies the value of the To Bin field.';
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
                    HistInvtTrxSerialLotCard: Page "Hist. Invt. Trx. SerialLot";
                begin
                    HistInvtTrxSerialLotCard.SetRecord(Rec);
                    HistInvtTrxSerialLotCard.Run();
                end;
            }
        }
    }

    internal procedure SetFilterInventoryTrxLine(var HistInventoryTrxLine: Record "Hist. Inventory Trx. Line")
    begin
        Rec.SetRange("Document Type", HistInventoryTrxLine."Document Type");
        Rec.SetRange("Document No.", HistInventoryTrxLine."Document No.");
        Rec.SetRange("Line Sequence Number", HistInventoryTrxLine."Line Item Sequence");
    end;

    var
        CouldNotFindRecordMsg: Label 'Could not find the matching record.';
}