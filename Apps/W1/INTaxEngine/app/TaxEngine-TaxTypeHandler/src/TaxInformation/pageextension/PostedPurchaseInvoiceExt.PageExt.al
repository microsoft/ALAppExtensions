pageextension 20244 "Posted Purchase Invoice Ext" extends "Posted Purchase Invoice"
{

    layout
    {

        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = PurchInvLines;
                SubPageLink = "Table ID Filter" = const(123), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}