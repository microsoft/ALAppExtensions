query 2400 "Account Summary"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    QueryCategory = 'Chart of Accounts';
    Caption = 'Account Summary';

    elements
    {
        dataitem("G_L_Account"; "G/L Account")
        {
            DataItemTableFilter = "Account Type" = const (Posting);
            column(No; "No.")
            { }
            column(Name; Name)
            { }

            column(Income_Balance; "Income/Balance")
            {
                Caption = 'Income/Balance';
            }

            column(Account_Category; "Account Category")
            {
                Caption = 'Account Category';
            }

            column(Account_Subcategory; "Account Subcategory Descript.")
            {
                Caption = 'Account Subcategory';
            }

            column(Balance; Balance)
            { }

            column(Blocked; Blocked)
            { }

            column(Gen_Bus_Posting_Group; "Gen. Bus. Posting Group")
            {
                Caption = 'Gen. Bus. Posting Group';
            }
            column(Gen_Prod_Posting_Group; "Gen. Prod. Posting Group")
            {
                Caption = 'Gen. Prod. Posting Group';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}