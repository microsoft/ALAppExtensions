pageextension 20248 "Posted Transfer Shipment Ext" extends "Posted Transfer Shipment"
{
    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = TransferShipmentLines;
                SubPageLink = "Table ID Filter" = const(5745), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}