// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that shows the settings of all users.
/// </summary>
page 9206 "User Settings List"
{
    Caption = 'User Settings';
    CardPageID = "User Personalization";
    AdditionalSearchTerms = 'User Personalization,User Preferences';
    UsageCategory = Administration;
    ApplicationArea = All;
    Editable = false;
    PageType = List;
    SourceTable = "User Personalization";
    SourceTableView = sorting("User ID") order(ascending);
    HelpLink = 'https://go.microsoft.com/fwlink/?linkid=2149387';
    AboutTitle = 'About user settings';
    AboutText = '**User Settings** control the look and feel of the user interface the next time the users log in. Each user can also make their own choices in their **My Settings** page, unless you restrict their permissions.';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    ToolTip = 'Specifies the user’s unique identifier.';
                    DrillDown = false;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the user’s full name.';
                    Editable = false;
                    Visible = false;
                }
                field(Role; Rec.Role)
                {
                    ApplicationArea = All;
                    Caption = 'Role';
                    ToolTip = 'Specifies the user role that defines the user’s default Role Center and role-specific customizations. Unless restricted by permissions, users can change their role on the My Settings page.';
                }
                field("Language"; Rec."Language Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Language';
                    ToolTip = 'Specifies the language in which Business Central will display. Users can change this on the My Settings page.';
                }
                field(Region; Rec.Region)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Region';
                    Importance = Additional;
                    ToolTip = 'Specifies the region setting for the user. The region defines display formats, for example, for dates, numbering, symbols, and currency. Users can change this on the My Settings page.';
                }
                field("Time Zone"; Rec."Time Zone")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Time Zone';
                    ToolTip = 'Specifies the time zone for the user. Users can change this on the My Settings page.';
                    Visible = false;
                }
                field(Company; Rec.Company)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company';
                    ToolTip = 'Specifies the company that the user works in. Unless restricted by permissions, users can change this on the My Settings page.';
                    Lookup = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
    begin
        UserSettingsImpl.HideExternalUsers(Rec);
    end;
}
