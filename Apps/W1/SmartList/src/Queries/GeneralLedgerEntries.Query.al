query 2401 "General Ledger Entries"
{
    QueryType = Normal;
    OrderBy = ascending (Document_No);
    Caption = 'General Ledger Entries';

    elements
    {
        dataitem(G_L_Entry; "G/L Entry")
        {
            column(Document_No; "Document No.")
            {
                Caption = 'Document No.';
            }

            column(Account_No; "G/L Account No.")
            {
                Caption = 'G/L Account No.';
            }

            column(Account_Name; "G/L Account Name")
            {
                Caption = 'Account Name';
            }

            column(Description; Description)
            { }

            column(Posting_Date; "Posting Date")
            {
                Caption = 'Posting Date';
            }

            column(Document_Type; "Document Type")
            {
                Caption = 'Document Type';
            }

            column(Debit_Amount; "Debit Amount")
            {
                Caption = 'Debit Amount';
            }

            column(Credit_Amount; "Credit Amount")
            {
                Caption = 'Credit Amount';
            }
        }
    }
}