query 2402 "Bank Acct Ledger Entries"
{
    QueryType = Normal;
    OrderBy = ascending (Bank_Account_No, Document_No);
    Caption = 'Bank Account Ledger Entries';

    elements
    {
        dataitem(Bank_Account_Ledger_Entry; "Bank Account Ledger Entry")
        {
            column(Bank_Account_No; "Bank Account No.")
            {
                Caption = 'Bank Account No.';
            }

            column(Document_No; "Document No.")
            {
                Caption = 'Document No.';
            }

            column(Document_Date; "Document Date")
            {
                Caption = 'Document Date';
            }

            column(Document_Type; "Document Type")
            {
                Caption = 'Document Type';
            }

            column(Description; Description)
            {

            }

            column(Amount__LCY_; "Amount (LCY)")
            {
                Caption = 'Amount (LCY)';
            }

            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
                Caption = 'Dimension Code 1';
            }
            column(Global_Dimension_2_Code; "Global Dimension 2 Code")
            {
                Caption = 'Dimension Code 2';
            }

            column(Balance_Account_Type; "Bal. Account Type")
            {
                Caption = 'Balance Account Type';
            }
            column(Balance_Account_No_; "Bal. Account No.")
            {
                Caption = 'Balance Account No.';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}