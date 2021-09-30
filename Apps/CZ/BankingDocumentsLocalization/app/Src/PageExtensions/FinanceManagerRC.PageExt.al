pageextension 31291 "Finance Manager RC CZB" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Group13)
        {
            action("Payment Orders CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Orders';
                RunObject = page "Payment Orders CZB";
            }
            action("Issued Payment Orders CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Payment Orders';
                RunObject = page "Iss. Payment Orders CZB";
            }
            action("Bank Statements CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Statements';
                RunObject = page "Bank Statements CZB";
            }
            action("Issued Bank Statements CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Bank Statements';
                RunObject = page "Iss. Bank Statements CZB";
            }
        }
    }
}
