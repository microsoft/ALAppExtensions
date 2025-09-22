// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Routing;

query 37009 "Routing Links - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Routing Links';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'routingLink';
    EntitySetName = 'routingLinks';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(routingLink; "Routing Link")
        {
            column(code; Code) { }
            column(description; Description) { }
        }
    }
}