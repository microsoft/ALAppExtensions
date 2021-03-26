query 4001 "Hybrid Enabled Co Rep. Details"
{
    // Query for finding most recent completed run for only companies that have replication enabled

    QueryType = Normal;
    OrderBy = descending (StartTime, RunID);

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

                column(RunID; "Run ID")
                {
                }
                column(StartTime; "Start Time")
                {
                }
                column(Status; Status)
                {
                }
            }
        }
    }
}