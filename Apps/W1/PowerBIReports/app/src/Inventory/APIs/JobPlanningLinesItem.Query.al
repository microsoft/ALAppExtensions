// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Projects.Project.Planning;

query 36969 "Job Planning Lines - Item"
{
    Access = Internal;
    Caption = 'Power BI Project Planning Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'itemJobPlanningLine';
    EntitySetName = 'itemJobPlanningLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(jobPlanningLine; "Job Planning Line")
        {

            DataItemTableFilter = Type = const(Item), Status = const(Order);
            column(itemNo; "No.")
            {
            }
            column(remainingQtyBase; "Remaining Qty. (Base)")
            {
                Method = Sum;
            }
            column(planningDate; "Planning Date")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(documentNo; "Document No.")
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