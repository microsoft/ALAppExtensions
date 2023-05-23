// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Present security group memberships
/// </summary>
page 9869 "Security Group Members"
{
    Caption = 'Security Group Members';
    DataCaptionFields = "Security Group Code", "Security Group Name";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Security Group Member Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(UserName; Rec."User Name")
                {
                    ApplicationArea = All;
                    Caption = 'User Name';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the user.';
                }
                field("User Full Name"; Rec."User Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the full name of the user.';
                }
                field("Security Group Code"; Rec."Security Group Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a security group.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SecurityGroup: Codeunit "Security Group";
    begin
        SecurityGroup.GetMembers(Rec);
    end;
}

