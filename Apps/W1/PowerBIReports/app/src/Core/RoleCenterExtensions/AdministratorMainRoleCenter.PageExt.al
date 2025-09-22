// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;

using Microsoft.RoleCenters;

pageextension 36950 "Administrator Main Role Center" extends "Administrator Main Role Center"
{
    actions
    {
        addlast(Group2)
        {
            action("Power BI Connector Setup")
            {
                ApplicationArea = All;
                Caption = 'Power BI Connector Setup';
                ToolTip = 'View and edit Power BI Connector settings.';
                RunObject = page "PowerBI Reports Setup";
            }
        }
    }
}