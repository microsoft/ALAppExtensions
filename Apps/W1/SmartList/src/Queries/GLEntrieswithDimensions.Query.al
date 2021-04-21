query 2403 "GL Entries with Dimensions"
{
    QueryType = Normal;
    OrderBy = ascending (Document_No);
    Caption = 'General Ledger Entries with Dimensions';

    elements
    {
        dataitem(G_L_Entry; "G/L Entry")
        {
            column(Document_No; "Document No.")
            {
                Caption = 'Document No.';
            }
            column(G_L_Account_No_; "G/L Account No.")
            {
                Caption = 'G/L Account No.';
            }
            column(Account_Name; "G/L Account Name")
            {
                Caption = 'Account Name';
            }
            column(Posting_Date; "Posting Date")
            {
                Caption = 'Posting Date';
            }
            column(Document_Type; "Document Type")
            {
                Caption = 'Document Type';
            }
            column(Description; Description)
            {

            }

            column(Balance_Account_Type; "Bal. Account Type")
            {
                Caption = 'Balance Account Type';
            }

            column(Balance_Account_No; "Bal. Account No.")
            {
                Caption = 'Balance Account No.';
            }
            column(Debit_Amount; "Debit Amount")
            {
                Caption = 'Debit Amount';
            }
            column(Credit_Amount; "Credit Amount")
            {
                Caption = 'Credit Amount';
            }
            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
                Caption = 'Dimension Code 1';
            }
            column(Global_Dimension_2_Code; "Global Dimension 2 Code")
            {
                Caption = 'Dimension Code 2';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}