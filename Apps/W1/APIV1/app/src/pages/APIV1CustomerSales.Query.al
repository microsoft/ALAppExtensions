query 20000 "APIV1 - Customer Sales"
{
    APIVersion = 'v1.0';
    Caption = 'customerSales', Locked = true;
    EntityName = 'customerSale';
    EntitySetName = 'customerSales';
    QueryType = API;

    elements
    {
        dataitem(QueryElement1; Customer)
        {
            column(customerId; SystemId)
            {
                Caption = 'SystemId', Locked = true;
            }
            column(customerNumber; "No.")
            {
                Caption = 'No', Locked = true;
            }
            column(name; Name)
            {
                Caption = 'Name', Locked = true;
            }
            dataitem(QueryElement10; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = QueryElement1."No.";
                SqlJoinType = LeftOuterJoin;
                DataItemTableFilter = "Document Type" = FILTER(Invoice | "Credit Memo");
                column(totalSalesAmount; "Sales (LCY)")
                {
                    Caption = 'TotalSalesAmount', Locked = true;
                    Method = Sum;
                }
                filter(dateFilter; "Posting Date")
                {
                    Caption = 'DateFilter', Locked = true;
                }
            }
        }
    }
}

