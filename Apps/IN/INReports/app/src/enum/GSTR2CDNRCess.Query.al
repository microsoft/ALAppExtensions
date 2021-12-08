query 18064 GSTR2CDNRCess
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = const('CESS');
            column(Document_No_; "Document No.")
            {
            }
            column(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            column(Document_Type; "Document Type")
            {
            }
            column(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(GST_Component_Code; "GST Component Code")
            {
            }
            column(Eligibility_for_ITC; "Eligibility for ITC")
            {
            }
            column(GST_Amount; "GST Amount")
            {
                Method = Sum;
            }

        }

    }

}