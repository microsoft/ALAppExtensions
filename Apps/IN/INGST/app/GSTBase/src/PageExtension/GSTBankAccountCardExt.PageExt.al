pageextension 18001 "GST Bank Account Card Ext" extends "Bank Account Card"
{
    layout
    {
        addlast(Posting)
        {
            group("GST")
            {
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of the bank.';
                }
                field("GST Registration Status"; Rec."GST Registration Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Registration Status of the bank.';
                }
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Species the GST Registration number of the bank.';
                }
            }
        }
    }
}