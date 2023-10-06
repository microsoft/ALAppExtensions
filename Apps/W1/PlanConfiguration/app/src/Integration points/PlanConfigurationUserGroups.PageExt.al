#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Security.AccessControl;

/// <summary>
/// Adds user groups to plan configurations.
/// </summary>
pageextension 9049 "Plan Configuration User Groups" extends "Plan Configuration Card"
{
    ObsoleteState = Pending;
    ObsoleteReason = '[220_UserGroups] The element has been moved to the main page. To learn more, go to https://go.microsoft.com/fwlink/?linkid=2245709.';
#pragma warning disable AS0072    
    ObsoleteTag = '22.0';
#pragma warning restore AS0072    

    layout
    {
        addbefore(DefaultPermissionSets)
        {
            part(DefaultUserGroups; "Default User Groups In Plan")
            {
                ApplicationArea = All;
                Caption = 'Default User Groups';
                Editable = false;
                Enabled = false;
                Visible = (not Rec.Customized) and LegacyUserGroupsVisible;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }

        addbefore(CustomPermissionSets)
        {
            part(UserGroups; "Custom User Groups In Plan")
            {
                ApplicationArea = All;
                Caption = 'Custom User Groups';
                UpdatePropagation = Both;
                Visible = Rec.Customized and LegacyUserGroupsVisible;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }
    }

    trigger OnOpenPage()
    var
        LegacyUserGroups: Codeunit "Legacy User Groups";
    begin
        LegacyUserGroupsVisible := LegacyUserGroups.UiElementsVisible();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.UserGroups.Page.SetPlanId(Rec."Plan ID");
    end;

    var
        LegacyUserGroupsVisible: Boolean;
}
#endif