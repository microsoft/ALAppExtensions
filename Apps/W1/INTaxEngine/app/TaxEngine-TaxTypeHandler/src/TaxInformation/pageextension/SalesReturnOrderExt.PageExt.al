pageextension 20260 "Sales Return Order Ext" extends "Sales Return Order"
{
    layout
    {
        addfirst(factboxes)
        {
            part("Tax Information"; "Tax Information Factbox")
            {
                ApplicationArea = Basic, Suite;
                Provider = SalesLines;
                SubPageLink = "Table ID Filter" = const(37), "Document Type Filter" = field("Document Type"), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
            }
        }
    }
}