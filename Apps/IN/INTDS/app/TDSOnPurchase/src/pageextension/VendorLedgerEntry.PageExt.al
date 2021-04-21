pageextension 18721 "Vendor Ledger Entry" extends "Vendor Ledger Entries"
{
    layout
    {
        addafter(Amount)
        {
            field("TDS Section Code"; Rec."TDS Section Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the Section codes under which tax has been deducted.';
            }
        }
    }
}