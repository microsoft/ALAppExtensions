query 10670 "SAF-T G/L Entry By Trans."
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