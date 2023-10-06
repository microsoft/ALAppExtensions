#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using Microsoft.RoleCenters;

/// <summary>
/// Add the available plan configuration to the Security Admin role center.
/// </summary>
pageextension 9048 "Plan Configuration Admin RC" extends "Security Admin Role Center"
{
    ObsoleteState = Pending;
    ObsoleteReason = '[220_UserGroups] The element has been moved to the main page. To learn more, go to https://go.microsoft.com/fwlink/?linkid=2245709.';
#pragma warning disable AS0072    
    ObsoleteTag = '22.0';
#pragma warning restore AS0072    

    layout
    {
        addafter(Control4)
        {
            part(LicenseConfigurationsPart; "Plan Configurations Part")
            {
                ApplicationArea = All;
                Caption = 'Default Permissions per License';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'The element has been moved to the main page.';
                ObsoleteTag = '22.0';
            }
        }
    }
}
#endif