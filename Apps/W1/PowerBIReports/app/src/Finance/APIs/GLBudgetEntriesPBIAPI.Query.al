// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Budget;

query 36960 "G/L Budget Entries - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI G/L Budget Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'generalLedgerBudgetEntry';
    EntitySetName = 'generalLedgerBudgetEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLBudgetEntry; "G/L Budget Entry")
        {
            column(budgetName; "Budget Name")
            {
            }
            column(glAccountNo; "G/L Account No.")
            {
            }
            column(budgetDate; Date)
            {
            }
            column(budgetAmount; Amount)
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(entryNo; "Entry No.")
            {
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
            CurrQuery.SetFilter(budgetDate, DateFilterText);
    end;
}