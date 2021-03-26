pageextension 20246 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{

    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = SalesInvLines;
                SubPageLink = "Table ID Filter" = const(113), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}