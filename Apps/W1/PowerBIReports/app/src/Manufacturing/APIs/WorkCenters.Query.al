// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.WorkCenter;

query 36991 "Work Centers"
{
    Access = Internal;
    Caption = 'Power BI Work Centers';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'workCenter';
    EntitySetName = 'workCenters';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(WorkCenter; "Work Center")
        {
            column(no; "No.") { }
            column(name; Name) { }
            column(workCenterGroupCode; "Work Center Group Code") { }
            column(subcontractorNo; "Subcontractor No.") { }
            column(unitOfMeasureCode; "Unit of Measure Code") { }
            dataitem(WorkCenterGroup; "Work Center Group")
            {
                DataItemLink = Code = WorkCenter."Work Center Group Code";
                column(workCenterGroupName; Name) { }
            }
        }
    }
}