pageextension 4814 "Intrastat Report Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Receiving)
        {
            group(Intrastat)
            {
                Caption = 'Intrastat';
                field("Default Trans. Type"; Rec."Default Trans. Type")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the default transaction type for regular sales shipments and service shipments.';
                }
                field("Default Trans. Type - Return"; Rec."Default Trans. Type - Return")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the default transaction type for sales returns and service returns.';
                }
                field("Def. Transport Method"; Rec."Def. Transport Method")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the default transport method, for the purpose of reporting to INTRASTAT.';
                }
            }
        }
    }
}