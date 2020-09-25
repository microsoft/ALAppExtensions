query 1950 "LPP Sales Invoice Header Input"
{
    Caption = 'Late Payment Model Input';
    OrderBy = Ascending(DueDate);

    elements
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            DataItemTableFilter = "Due Date" = filter(<> 0D);

            column(DueDate; "Due Date")
            {
            }
            column(No; "No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(BillToCustomerNo; "Bill-to Customer No.")
            {
            }
            column(CustLedgerEntryNo; "Cust. Ledger Entry No.")
            {
            }
            column(Amount; Amount)
            {
                ColumnFilter = Amount = filter(> 0);
            }
            column(Cancelled; Cancelled)
            {
                ColumnFilter = Cancelled = const(false);
            }
            column(Closed; Closed)
            {
            }
            column(Reversed; Reversed)
            {
                ColumnFilter = Reversed = const(false);
            }
        }
    }
}