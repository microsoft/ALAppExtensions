// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Budget;

query 36961 "G/L Budgets"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI G/L Budgets';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'generalLedgerBudget';
    EntitySetName = 'generalLedgerBudgets';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLBudgetName; "G/L Budget Name")
        {
            column(budgetName; Name)
            {
            }
            column(budgetDescription; Description)
            {
            }
        }
    }
}