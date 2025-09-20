// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

query 37014 "G/L Income Statement - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI G/L Entries Income Statement';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'incomeStmtGeneralLedgerEntry';
    EntitySetName = 'incomeStmtGeneralLedgerEntries';
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
    begin
        DateFilterText := PBIMgt.GenerateFinanceReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}