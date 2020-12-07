query 4098 "GP Item Transaction Average"
{
    QueryType = Normal;

    elements
    {
        dataitem(MigrationGPItemTransaction; "GP Item Transactions")
        {
            column(No; No)
            {
            }
            column(Location; Location)
            {
            }
            column(CurrentCost; CurrentCost)
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}