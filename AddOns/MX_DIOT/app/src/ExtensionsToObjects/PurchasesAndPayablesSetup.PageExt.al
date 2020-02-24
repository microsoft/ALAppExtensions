pageextension 27030 "DIOT Purch. & Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Default Qty. to Receive")
        {
            field("Default Vendor DIOT Type"; "Default Vendor DIOT Type")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Default Vendor DIOT Type';
                ToolTip = 'Specifies the default DIOT operation type to be used for all vendors.';
            }
        }
    }
}