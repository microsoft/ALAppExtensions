// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Foundation.AuditCodes;

table 36955 "PBI C. Income St. Source Code"
{
    Caption = 'Power BI Close Income Statement Source Codes';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            ToolTip = 'Specifies the code linked to entries that are posted when you run the Close Income Statement batch job.';
            TableRelation = "Source Code";
        }
    }
}