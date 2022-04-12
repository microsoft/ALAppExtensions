query 30100 "Shpfy Shipment Location"
{
    Access = Internal;
    Caption = 'Shopify Shipment Location';
    QueryType = Normal;

    elements
    {
        dataitem(SalesShipmentHeader; "Sales Shipment Header")
        {
            column(No; "No.") { }

            dataitem(SalesShipmentLine; "Sales Shipment Line")
            {
                DataItemLink = "Document No." = SalesShipmentHeader."No.";
                DataItemTableFilter = Type = const(Item), Quantity = filter('>0');
                SqlJoinType = InnerJoin;
                column(LocationCode; "Location Code") { }

                dataitem(ShopLocation; "Shpfy Shop Location")
                {
                    DataItemLink = "Default Location Code" = SalesShipmentLine."Location Code";
                    SqlJoinType = InnerJoin;

                    column(LocationId; Id) { }

                    column(NoOfLines)
                    {
                        Method = Count;
                    }
                }
            }
        }
    }
}
