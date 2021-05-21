pageextension 20261 "Transfer Order Ext" extends "Transfer Order"
{
    layout
    {
        addfirst(factboxes)
        {
            part("Tax Information"; "Tax Information Factbox")
            {
                ApplicationArea = Basic, Suite;
                Provider = TransferLines;
                SubPageLink = "Table ID Filter" = const(5741), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
            }
        }
    }
}