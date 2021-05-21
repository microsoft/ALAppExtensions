pageextension 20245 "Posted Sales Cr. Memo Ext" extends "Posted Sales Credit Memo"
{

    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = SalesCrMemoLines;
                SubPageLink = "Table ID Filter" = const(115), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}