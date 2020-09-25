query 30001 "APIV2 - Vendor Purchases"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Vendor Purchase';
    EntitySetCaption = 'Vendor Purchases';
    EntityName = 'vendorPurchase';
    EntitySetName = 'vendorPurchases';
    QueryType = API;

    elements
    {
        dataitem(QueryElement1; Vendor)
        {
            column(vendorId; SystemId)
            {
                Caption = 'System Id';
            }
            column(vendorNumber; "No.")
            {
                Caption = 'No.';
            }
            column(name; Name)
            {
                Caption = 'Name';
            }
            dataitem(QueryElement3; "Vendor Ledger Entry")
            {
                DataItemLink = "Vendor No." = QueryElement1."No.";
                SqlJoinType = LeftOuterJoin;
                column(totalPurchaseAmount; "Purchase (LCY)")
                {
                    Caption = 'Total Purchase Amount';
                    Method = Sum;
                    ReverseSign = true;
                }
                filter(dateFilter; "Posting Date")
                {
                    Caption = 'Date Filter';
                }
            }
        }
    }
}

