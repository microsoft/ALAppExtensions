pageextension 18796 "Charge Sales Quote Ext" extends "Sales Quote"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("Charge Group Code"; Rec."Charge Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the charge group code is assigned to the document';
            }
        }
    }
}