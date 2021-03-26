pageextension 20243 "Posted Purchase Cr. Memo Ext" extends "Posted Purchase Credit Memo"
{

    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = PurchCrMemoLines;
                SubPageLink = "Table ID Filter" = const(125), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}