pageextension 4813 "Intrastat Report Cust. Card" extends "Customer Card"
{
    layout
    {
        addafter(Shipping)
        {
            group(Intrastat)
            {
                Caption = 'Intrastat';
                field("Default Trans. Type"; Rec."Default Trans. Type")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the default transaction type for regular sales shipments and service shipments.';
                }
                field("Default Trans. Type - Return"; Rec."Default Trans. Type - Return")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the default transaction type for sales returns and service returns.';
                }
                field("Def. Transport Method"; Rec."Def. Transport Method")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the default transport method, for the purpose of reporting to INTRASTAT.';
                }
            }
        }
    }
}