query 5286 "G/L Entry By Trans. SAF-T"
{
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLEntry; "G/L Entry")
        {
            filter(Posting_Date; "Posting Date")
            {

            }
            column(Transaction_No_; "Transaction No.")
            {
            }
            column(Count)
            {
                Method = Count;
            }
        }
    }
}