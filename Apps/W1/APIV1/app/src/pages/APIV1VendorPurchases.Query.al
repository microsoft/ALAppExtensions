query 20001 "APIV1 - Vendor Purchases"
{
    APIVersion = 'v1.0';
    Caption = 'vendorPurchases', Locked = true;
    EntityName = 'vendorPurchase';
    EntitySetName = 'vendorPurchases';
    QueryType = API;

    elements
    {
        dataitem(QueryElement1; Vendor)
        {
            column(vendorId; SystemId)
            {
                Caption = 'SystemId', Locked = true;
            }
            column(vendorNumber; "No.")
            {
                Caption = 'No', Locked = true;
            }
            column(name; Name)
            {
                Caption = 'Name', Locked = true;
            }
            dataitem(QueryElement3; "Vendor Ledger Entry")
            {
                DataItemLink = "Vendor No." = QueryElement1."No.";
                SqlJoinType = LeftOuterJoin;
                column(totalPurchaseAmount; "Purchase (LCY)")
                {
                    Caption = 'TotalPurchaseAmount', Locked = true;
                    Method = Sum;
                    ReverseSign = true;
                }
                filter(dateFilter; "Posting Date")
                {
                    Caption = 'DateFilter', Locked = true;
                }
            }
        }
    }
}

