pageextension 18156 "GST Sales Setup Ext" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast("general")
        {
            field("GST Dependency Type"; Rec."GST Dependency Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST calculation dependency mentioned in sales and receivable setup.';
            }
        }
    }
}