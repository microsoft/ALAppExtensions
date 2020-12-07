query 4099 "GP Item Transaction"
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
            column(ReceiptNumber; ReceiptNumber)
            {
            }
            column(DateReceived; DateReceived)
            {
            }
            column(UnitCost; UnitCost)
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}