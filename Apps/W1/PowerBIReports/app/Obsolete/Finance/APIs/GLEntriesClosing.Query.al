#if not CLEAN26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
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
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'closingGeneralLedgerEntry';
    EntitySetName = 'closingGeneralLedgerEntries';
    DataAccessIntent = ReadOnly;
    ObsoleteState = Pending;
    ObsoleteReason = 'This query has been replaced by G/L Entries Balance Sheet and Income Statement queries.';
    ObsoleteTag = '26.0';

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
#endif