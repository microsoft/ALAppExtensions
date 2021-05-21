pageextension 31142 "General Journal Templates CZL" extends "General Journal Templates"
{
    layout
    {
        addlast(Control1)
        {
            field("Not Check Doc. Type CZL"; Rec."Not Check Doc. Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether to suppress the document balance check according to document type.';
                Visible = false;
            }
        }
    }
}