// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.Inventory.Analysis;

query 36999 "Item Budget Entries - Purch."
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Purch. Item Budget Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'purchaseItemBudgetEntry';
    EntitySetName = 'purchaseItemBudgetEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(itemBudgetEntry; "Item Budget Entry")
        {
            DataItemTableFilter = "Analysis Area" = const(Purchase);
            column(entryNo; "Entry No.")
            {
            }
            column(budgetName; "Budget Name")
            {
            }
            column(entryDate; Date)
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(sourceType; "Source Type")
            {
            }
            column(sourceNo; "Source No.")
            {
            }
            column(quantity; Quantity)
            {
            }
            column(costAmount; "Cost Amount")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Purchases Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateItemPurchasesReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(entryDate, DateFilterText);
    end;
}

