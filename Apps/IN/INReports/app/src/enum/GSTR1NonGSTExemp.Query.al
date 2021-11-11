query 18031 GSTR1NonGSTExemp
{
    QueryType = Normal;

    elements
    {
        dataitem(Sales_Invoice_Header; "Sales Invoice Header")
        {
            column(Posting_Date; "Posting Date")
            {
            }
            column(GST_Customer_Type; "GST Customer Type")
            {
            }
            dataitem(Sales_Invoice_Line; "Sales Invoice Line")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Document No." = Sales_Invoice_Header."No.";
                DataItemTableFilter = "Line No." = filter(= 10000);

                column(GST_Group_Code; "GST Group Code")
                {
                    ColumnFilter = GST_Group_Code = filter(= '');
                }
                column(HSN_SAC_Code; "HSN/SAC Code")
                {
                    ColumnFilter = HSN_SAC_Code = filter(= '');
                }
                dataitem(Cust__Ledger_Entry; "Cust. Ledger Entry")
                {
                    SqlJoinType = InnerJoin;
                    DataItemLink = "Document No." = Sales_Invoice_Header."No.";
                    DataItemTableFilter = "Document Type" = const(Invoice);
                    column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
                    {
                    }
                    column(Location_GST_Reg__No_; "Location GST Reg. No.")
                    {
                    }
                    column(Amount; Amount)
                    {
                    }

                }
            }
        }
    }
}

