// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Adds user groups to plan configurations.
/// </summary>
pageextension 9049 "Plan Configuration User Groups" extends "Plan Configuration Card"
{
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
                Visible = not Rec.Customized;
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
                Visible = Rec.Customized;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.UserGroups.Page.SetPlanId(Rec."Plan ID");
    end;
}