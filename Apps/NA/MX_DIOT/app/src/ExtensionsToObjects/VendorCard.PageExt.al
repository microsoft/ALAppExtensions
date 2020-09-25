pageextension 27031 "DIOT Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("DIOT Type of Operation"; "DIOT Type of Operation")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type to be used for all documents with this vendor.';
            }
        }
    }
}