query 18049 GSTR2GSTPer
{
    QueryType = Normal;


    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            filter(Posting_Date; "Posting Date")
            {
            }
            column(GST__; "GST %")
            {
            }
            column(Document_No_; "Document No.")
            {

            }
            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }

            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {

            }
            column(GST_Component_Code; "GST Component Code")
            {
                ColumnFilter = GST_Component_Code = filter(<> 'CESS');
            }
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
            column(UnApplied; UnApplied)
            {
            }
            column(Reversed; Reversed)
            {
            }
        }
    }
}