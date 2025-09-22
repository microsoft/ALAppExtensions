// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Assembly.Document;

query 36964 "Assembly Headers - Order"
{
    Access = Internal;
    Caption = 'Power BI Assembly Headers';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'assemblyHeader';
    EntitySetName = 'assemblyHeaders';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(assemblyHeader; "Assembly Header")
        {

            DataItemTableFilter = "Document Type" = const(Order);
            column(documentNo; "No.")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(quantity; Quantity)
            {
                Method = Sum;
            }
            column(remainingQtyBase; "Remaining Quantity (Base)")
            {
                Method = Sum;
            }
            column(dueDate; "Due Date")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(status; Status)
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