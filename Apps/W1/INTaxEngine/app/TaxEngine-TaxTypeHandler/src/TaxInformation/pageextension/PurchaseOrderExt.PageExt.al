pageextension 20251 "Purchase Order Ext" extends "Purchase Order"
{
    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = PurchLines;
                SubPageLink = "Table ID Filter" = const(39), "Document Type Filter" = field("Document Type"), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }

    }
}