// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that hold the default user groups assigned to a plan.
/// </summary>
page 9049 "Default User Groups In Plan"
{
    PageType = ListPart;
    SourceTable = "User Group Plan";
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            group("Default User Groups")
            {
                ShowCaption = false;

                repeater(Group)
                {
                    field("User Group"; Rec."User Group Code")
                    {
                        ApplicationArea = All;
                        Caption = 'User Group';
                        ToolTip = 'Specifies the ID of the user group.';
                    }
                    field("User Group Name"; Rec."User Group Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        ToolTip = 'Specifies the description of the user group.';
                    }
                    field(Company; FirstCompanyTok)
                    {
                        ApplicationArea = All;
                        Caption = 'Company';
                        ToolTip = 'The user group will be assigned to the first company that a member of the user group signs in to.';
                        Style = AttentionAccent;
                    }
                }
            }
        }
    }

    var
        FirstCompanyTok: Label '(first company sign-in)', Comment = 'The brackets around should stay';
}