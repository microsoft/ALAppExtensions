// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains all available roles.
/// </summary>
page 9212 Roles
{
    Caption = 'Available Roles';
    Editable = false;
    LinksAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "All Profile";
    SourceTableTemporary = true;
    Permissions = tabledata "All Profile" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(CaptionField; Caption)
                {
                    Caption = 'Display Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the organizational role.';
                }
                field(AppNameField; "App Name")
                {
                    Caption = 'Source';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the origin of this role, which can be either an extension, shown by its name, or a custom profile created by a user.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
       if Rec.IsEmpty() then
           Initialize();
    end;

    /// <summary>
    ///  Initializes the page by populating the source record.
    /// </summary>
    procedure Initialize()
    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
    begin
        UserSettingsImpl.PopulateProfiles(Rec);
    end;
}

