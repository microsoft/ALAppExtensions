namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

query 36956 "G/L Entries - Closing"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Closing G/L Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'closingGeneralLedgerEntry';
    EntitySetName = 'closingGeneralLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLAccount; "G/L Account")
        {
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

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Finance Filter Helper";
        SourceCodeText: Text;
    begin
        SourceCodeText := PBIMgt.GenerateFinanceReportSourceCodeFilter();
        if SourceCodeText <> '' then
            CurrQuery.SetFilter(sourceCode, '%1', SourceCodeText);
    end;
}