pageextension 20247 "Posted Transfer Receipt Ext" extends "Posted Transfer Receipt"
{
    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = TransferReceiptLines;
                SubPageLink = "Table ID Filter" = const(5747), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}