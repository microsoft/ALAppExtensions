pageextension 18013 "GST States Ext" extends States
{
    layout
    {
        addlast(General)
        {
            field("State Code (GST Reg. No.)"; Rec."State Code (GST Reg. No.)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the state code for GST Registration of the state as per authorized body.';
            }
        }
    }
}