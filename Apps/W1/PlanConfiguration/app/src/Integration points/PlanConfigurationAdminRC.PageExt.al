#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Add the available plan configuration to the Security Admin role center.
/// </summary>
pageextension 9048 "Plan Configuration Admin RC" extends "Security Admin Role Center"
{
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