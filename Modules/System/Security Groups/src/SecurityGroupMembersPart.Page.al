// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Present security group memberships in a page part or factbox.
/// </summary>
page 9866 "Security Group Members Part"
{
    Caption = 'Members';
    PageType = ListPart;
    SourceTable = "Security Group Member Buffer";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the user.';
                }
                field("User Full Name"; Rec."User Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the full name of the user.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Refresh();
    end;

    internal procedure Refresh()
    var
        SecurityGroup: Codeunit "Security Group";
    begin
        SecurityGroup.GetMembers(Rec);
    end;
}

