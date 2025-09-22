// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Inventory.Planning;

query 36970 "Planning Components"
{
    Access = Internal;
    Caption = 'Power BI Planning Component Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'planningComponentLine';
    EntitySetName = 'planningComponentLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(planningComponent; "Planning Component")
        {
            DataItemTableFilter = "Planning Line Origin" = const(" ");
            column(itemNo; "Item No.")
            {

            }
            column(dueDate; "Due Date")
            {

            }
            column(locationCode; "Location Code")
            {

            }
            column(expectedQuantityBase; "Expected Quantity (Base)")
            {
                Method = Sum;
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(qtyPerUnitOfMeasure; "Qty. per Unit of Measure")
            {
            }
            column(unitOfMeasureCode; "Unit of Measure Code")
            {
            }
        }
    }
}