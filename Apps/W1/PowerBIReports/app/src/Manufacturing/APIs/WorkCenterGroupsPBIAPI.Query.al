// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.WorkCenter;

query 37012 "Work Center Groups - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Work Center Groups';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'workCenterGroup';
    EntitySetName = 'workCenterGroups';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(workCenterGroup; "Work Center Group")
        {
            column(code; Code) { }
            column(name; Name) { }
        }
    }
}