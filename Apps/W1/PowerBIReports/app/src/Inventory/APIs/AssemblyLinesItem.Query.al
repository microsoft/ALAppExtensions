// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Assembly.Document;

query 36965 "Assembly Lines - Item"
{
    Access = Internal;
    Caption = 'Power BI Assembly Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'assemblyLine';
    EntitySetName = 'assemblyLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(assemblyLines; "Assembly Line")
        {

            DataItemTableFilter = Type = const(Item);
            column(itemNo; "No.")
            {
            }
            column(remainingQuantity; "Remaining Quantity (Base)")
            {
                Method = Sum;
            }
            column(dueDate; "Due Date")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(documentNo; "Document No.")
            {
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