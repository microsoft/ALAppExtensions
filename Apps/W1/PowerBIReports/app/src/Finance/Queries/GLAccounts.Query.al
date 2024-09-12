namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;

query 36959 "G/L Accounts"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI G/L Accounts';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'generalLedgerAccount';
    EntitySetName = 'generalLedgerAccounts';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLAccount; "G/L Account")
        {
            column(accountNo; "No.")
            {
            }
            column(accountName; Name)
            {
            }
            column(accountType; "Account Type")
            {
            }
            column(incomeBalance; "Income/Balance")
            {
            }
            column(accountSubcategoryEntryNo; "Account Subcategory Entry No.")
            {
            }
            column(indentation; Indentation)
            {
            }
            column(totaling; Totaling)
            {
            }
        }
    }
}