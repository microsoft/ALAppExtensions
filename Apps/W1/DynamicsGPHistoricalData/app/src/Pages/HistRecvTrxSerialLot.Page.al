namespace Microsoft.DataMigration.GP.HistoricalData;

page 41027 "Hist. Recv. Trx. SerialLot"
{
    Caption = 'Historical Receivables Transaction Serial/Lot Detail';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Recv. Trx. SerialLot";
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
                    ToolTip = 'Specifies the value of the Serial/Lot Seq. No. field.';
                }
                field("Override Serial/Lot"; Rec."Override Serial/Lot")
                {
                    ToolTip = 'Specifies the value of the Override Serial/Lot field.';
                }
                field(Bin; Rec.Bin)
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

    trigger OnAfterGetCurrRecord()
    begin
        DataCaptionExpressionTxt := Rec."Item No." + ' - ' + Rec."Serial/Lot Number";
    end;

    var
        DataCaptionExpressionTxt: Text;
}