pageextension 6370 ExEDEDocCustomerCard extends "Customer Card"
{
    layout
    {
        addafter("Use GLN in Electronic Document")
        {
            field("ExEDE-Document Customer ID"; Rec."SignUpService Participant Id")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies customer ID used by the E-Document Service.';
            }
        }
    }
}