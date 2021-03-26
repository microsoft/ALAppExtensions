query 4000 "Hybrid Tables For Replication"
{
    QueryType = Normal;
    elements
    {
        dataitem(Hybrid_Company; "Hybrid Company")
        {
            filter(Replicate; Replicate)
            {
                ColumnFilter = Replicate = const (true);
            }
            dataitem(Hybrid_Replication_Detail; "Hybrid Replication Detail")
            {
                DataItemLink = "Company Name" = Hybrid_Company.Name;
                SqlJoinType = InnerJoin;
                column(TableName; "Table Name")
                {

                }
                column(CompanyName; "Company Name")
                {

                }
                column(Counts)
                {
                    Method = Count;
                }
            }
        }

    }
}