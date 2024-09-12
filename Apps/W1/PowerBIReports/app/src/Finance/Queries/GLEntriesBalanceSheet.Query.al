namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

query 36955 "G\L Entries - Balance Sheet"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Balance Sheet G/L Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'balanceSheetGeneralLedgerEntry';
    EntitySetName = 'balanceSheetGeneralLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLAccount; "G/L Account")
        {
            DataItemTableFilter = "Income/Balance" = const("Balance Sheet");
            column(incomeBalance; "Income/Balance")
            {
            }
            column(glAccountNo; "No.")
            {
            }
            dataitem(GLEntry; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = GLAccount."No.";
                SqlJoinType = InnerJoin;

                column(postingDate; "Posting Date")
                {
                }
                column(amount; Amount)
                {
                }
                column(dimensionSetID; "Dimension Set ID")
                {
                }
                column(sourceCode; "Source Code")
                {
                }
                column(entryNo; "Entry No.")
                {
                }
                column(systemModifiedAt; SystemModifiedAt)
                {
                }
                column(description; Description)
                {
                }
                column(sourceType; "Source Type")
                {
                }
                column(sourceNo; "Source No.")
                {
                }
            }
        }
    }
}