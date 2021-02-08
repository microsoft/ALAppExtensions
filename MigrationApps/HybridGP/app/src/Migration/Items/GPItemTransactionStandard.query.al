query 4101 "GP Item Transaction Standard"
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
            column(StandardCost; StandardCost)
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}