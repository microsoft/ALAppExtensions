namespace Microsoft.DataMigration.GP;

query 40101 "GP Item Aggregate"
{
    QueryType = Normal;

    elements
    {
        dataitem(GPIV00101; "GP IV00101")
        {
            column(DECPLCUR; DECPLCUR)
            {
                Method = Max;
            }
        }
    }
}