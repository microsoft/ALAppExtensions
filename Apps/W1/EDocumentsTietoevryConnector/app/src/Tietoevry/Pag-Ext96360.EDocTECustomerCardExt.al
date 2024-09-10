pageextension 96360 "E-Doc TE Customer Card Ext" extends "Customer Card"
{
    layout
    {
        modify(GLN)
        {
            Visible = false;
        }
        modify("Use GLN in Electronic Document")
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
