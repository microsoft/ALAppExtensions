namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

query 36962 "G/L Entries - Income Statement"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Income Stmt. G/L Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'incomeStatementGeneralLedgerEntry';
    EntitySetName = 'incomeStatementGeneralLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLAccount; "G/L Account")
        {
            DataItemTableFilter = "Income/Balance" = const("Income Statement");
            column(incomeBalance; "Income/Balance")
            {
            }
            column(accountNo; "No.")
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
        DateFilterText: Text;
        SourceCodeText: Text;
    begin
        DateFilterText := PBIMgt.GenerateFinanceReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);

        SourceCodeText := PBIMgt.GenerateFinanceReportSourceCodeFilter();
        if SourceCodeText <> '' then
            CurrQuery.SetFilter(sourceCode, '<>%1', SourceCodeText);
    end;
}