pageextension 96361 "E-Doc TE Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        modify(GLN)
        {
            Visible = false;
        }
        addafter(GLN)
        {
            field("Peppol Id"; Rec."Service Participant Id")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies the customer in connection with electronic document sending.';
            }
        }
    }

    actions
    {

    }
}
