pageextension 11781 "Account Schedule Names CZL" extends "Account Schedule Names"
{
    layout
    {
        addlast(Control1)
        {
            field("Acc. Schedule Type CZL"; Rec."Acc. Schedule Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of account schedule (Balance Sheet or Income Statement).';
            }
        }
    }
}
