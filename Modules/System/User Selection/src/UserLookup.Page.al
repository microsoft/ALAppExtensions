// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lookup page for users.
/// </summary>
page 9843 "User Lookup"
{
    Extensible = false;
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = User;
    SourceTableView = SORTING("User Name");
    Permissions = tabledata User = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name"; "User Name")
                {
                    ApplicationArea = All;
                    Caption = 'User Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the user. If the user must enter credentials when they sign in, this is the name they must enter.';
                }
                field("Full Name"; "Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    Editable = false;
                    ToolTip = 'Specifies the full name of the user.';
                }
                field("Windows Security ID"; "Windows Security ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Windows Security ID of the user. This is only relevant for Windows authentication.';
                    Visible = NOT IsSaaS;
                }
                field("Authentication Email"; "Authentication Email")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the Microsoft account that this user uses to sign in to Office 365 or SharePoint Online.';
                    Visible = IsSaaS;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        UserSelectionImpl.HideExternalUsers(Rec);
        IsSaaS := EnvironmentInfo.IsSaaS();
    end;

    var
        UserSelectionImpl: Codeunit "User Selection Impl.";
        IsSaaS: Boolean;

    /// <summary>
    /// Gets the currently selected users.
    /// </summary>
    /// <param name="SelectedUser">A record that contains the currently selected users</param>
    [Scope('OnPrem')]
    procedure GetSelectedUsers(var SelectedUser: Record User)
    var
        User: Record User;
    begin
        if SelectedUser.IsTemporary() then begin
            SelectedUser.Reset();
            SelectedUser.DeleteAll();
            CurrPage.SetSelectionFilter(User);
            if User.FindSet() then
                repeat
                    SelectedUser.Copy(User);
                    SelectedUser.Insert();
                until User.Next() = 0;
        end else begin
            CurrPage.SetSelectionFilter(SelectedUser);
            SelectedUser.FindSet();
        end;
    end;
}

