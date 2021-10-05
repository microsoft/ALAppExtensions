// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A Factbox that shows the settings of a given user.
/// </summary>
page 9208 "User Settings FactBox"
{
    Caption = 'User Settings';
    Editable = false;
    PageType = CardPart;
    SourceTable = "User Settings";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field(UserRoleCenter; UserSettingsImpl.GetProfileName(Rec.Scope, Rec."App ID", Rec."Profile ID"))
            {
                ApplicationArea = All;
                Caption = 'Role';
                ToolTip = 'Specifies the user role that defines the user’s default Role Center and role-specific customizations. Unless restricted by permissions, users can change their role on the My Settings page.';
            }
            field(Company; UserSettingsImpl.GetCompanyDisplayName(Rec.Company))
            {
                ApplicationArea = All;
                Caption = 'Company';
                ToolTip = 'Specifies the company that is associated with the user.';
            }
            field("Language"; Language.GetWindowsLanguageName(Rec."Language ID"))
            {
                ApplicationArea = All;
                Caption = 'Language';
                ToolTip = 'Specifies the language in which Business Central will display. Users can change this on the My Settings page.';
            }
            field(Region; Language.GetWindowsLanguageName(Rec."Locale ID"))
            {
                ApplicationArea = All;
                Caption = 'Region';
                Importance = Additional;
                ToolTip = 'Specifies the region setting for the user. The region defines display formats, for example, for dates, numbering, symbols, and currency. Users can change this on the My Settings page.';
            }
            field("Time Zone"; Rec."Time Zone")
            {
                ApplicationArea = All;
                Caption = 'Time Zone';
                ToolTip = 'Specifies the time zone that Microsoft Windows is set up to run for the selected user.';
            }
            field("Teaching Tips"; Rec."Teaching Tips")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Teaching Tips';
                ToolTip = 'Specifies whether to display short messages that inform, remind, or teach you about important fields and actions when you open a page.';
            }
        }
    }

    trigger OnInit()
    begin
        UserSettingsImpl.GetAllUsersSettings(Rec);
    end;

    var
        Language: Codeunit Language;
        UserSettingsImpl: Codeunit "User Settings Impl.";
}

