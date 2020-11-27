pageextension 11784 "Source Code Setup CZL" extends "Source Code Setup"
{
    layout
    {
        addafter("Compress Cust. Ledger")
        {
            field("Sales VAT Delay CZL"; Rec."Sales VAT Delay CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for sales VAT delay.';
            }
        }
        addafter("Compress Vend. Ledger")
        {
            field("Purchase VAT Delay CZL"; Rec."Purchase VAT Delay CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for purchase VAT delay.';
            }
        }
    }
}
