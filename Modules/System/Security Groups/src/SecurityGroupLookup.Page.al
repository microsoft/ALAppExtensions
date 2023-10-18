// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

page 9877 "Security Group Lookup"
{
    Caption = 'Available Security Groups';
    Editable = false;
    PageType = List;
    SourceTable = "Security Group Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec."Group Name")
                {
                    Caption = 'Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the security group.';
                }
                field(ID; Rec."Group ID")
                {
                    Caption = 'ID';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the security group.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SecurityGroup: Codeunit "Security Group Impl.";
    begin
        SecurityGroup.GetAvailableGroups(Rec);
    end;
}

