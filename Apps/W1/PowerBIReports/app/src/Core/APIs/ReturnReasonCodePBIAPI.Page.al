// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;
using Microsoft.Foundation.AuditCodes;

page 36965 "Return Reason Code - PBI API"
{
    PageType = API;
    Caption = 'Power BI Reason Codes';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'returnReasonCode';
    EntitySetName = 'returnReasonCodes';
    SourceTable = "Return Reason";
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(reasonCode; Rec."Code") { }
                field(reasonDescription; Rec.Description) { }
            }
        }
    }
}