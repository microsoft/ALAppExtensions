namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

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
                column(Shpfy_Order_Line_Id; "Shpfy Order Line Id") { }

                dataitem(OrderLine; "Shpfy Order Line")
                {
                    DataItemLink = "Line Id" = SalesShipmentLine."Shpfy Order Line Id";
                    SqlJoinType = InnerJoin;

                    column(LocationId; "Location Id") { }

                    column(NoOfLines)
                    {
                        Method = Count;
                    }
                }
            }
        }
    }
}
