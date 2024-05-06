namespace Microsoft.DataMigration.GP.HistoricalData;

page 41029 "Hist. Invt. Trx. SerialLot"
{
    Caption = 'Historical Inventory Transaction Serial/Lot Detail';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Invt. Trx. SerialLot";
    DataCaptionExpression = DataCaptionExpressionTxt;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

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
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
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

    trigger OnAfterGetCurrRecord()
    begin
        DataCaptionExpressionTxt := Rec."Item No." + ' - ' + Rec."Serial/Lot Number";
    end;

    var
        DataCaptionExpressionTxt: Text;
}