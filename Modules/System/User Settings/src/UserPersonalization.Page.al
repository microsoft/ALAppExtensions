// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page that shows the settings of a given user.
/// </summary>
page 9214 "User Personalization"
{
    Caption = 'User Settings Card';
    AdditionalSearchTerms = 'User Personalization Card,User Preferences Card';
    DataCaptionExpression = Rec."User ID";
    DelayedInsert = true;
    PageType = Card;
    SourceTable = "User Personalization";
    HelpLink = 'https://go.microsoft.com/fwlink/?linkid=2149387';
    AboutTitle = 'About user setting details';
    AboutText = 'Here, you manage an individual user''s settings. If a setting is left blank, a default value is provided when the user signs in.';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    ToolTip = 'Specifies the user''s unique identifier.';
                    DrillDown = false;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        if UserSettingsImpl.EditUserID(Rec) then
                            CurrPage.Update();
                    end;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the user''s full name.';
                    Editable = false;
                    Visible = false;
                }
                field(Role; Rec.Role)
                {
                    ApplicationArea = All;
                    Caption = 'Role';
                    ToolTip = 'Specifies the user role that defines the user''s default Role Center and role-specific customizations. Unless restricted by permissions, users can change their role on the My Settings page.';

                    trigger OnAssistEdit()
                    begin
                        UserSettingsImpl.EditProfileID(Rec);
                    end;
                }
                field("Language"; Language.GetWindowsLanguageName(Rec."Language ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Language';
                    ToolTip = 'Specifies the language in which Business Central will display. Users can change this on the My Settings page.';

                    trigger OnAssistEdit()
                    begin
                        Language.LookupApplicationLanguageId(Rec."Language ID");
                    end;
                }
                field(Region; Language.GetWindowsLanguageName(Rec."Locale ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Region';
                    ToolTip = 'Specifies the region setting for the user. The region defines display formats, for example, for dates, numbering, symbols, and currency. Users can change this on the My Settings page.';

                    trigger OnAssistEdit()
                    begin
                        Language.LookupWindowsLanguageId(Rec."Locale ID");
                    end;
                }
                field("Time Zone"; TimeZoneSelection.GetTimeZoneDisplayName(Rec."Time Zone"))
                {
                    ApplicationArea = All;
                    Caption = 'Time Zone';
                    ToolTip = 'Specifies the time zone for the user. Users can change this on the My Settings page.';

                    trigger OnAssistEdit()
                    begin
                        TimeZoneSelection.LookupTimeZone(Rec."Time Zone");
                    end;
                }
                field(Company; Rec.Company)
                {
                    ApplicationArea = All;
                    Caption = 'Company';
                    ToolTip = 'Specifies the company that the user works in. Unless restricted by permissions, users can change this on the My Settings page.';
                }
                field("Teaching Tips"; TeachingTipsEnabled)
                {
                    ApplicationArea = All;
                    Caption = 'Teaching Tips';
                    ToolTip = 'Specifies whether to display short messages that inform, remind, or teach the user about important fields and actions when they open a page.';

                    trigger OnValidate()
                    begin
                        if TeachingTipsEnabled then
                            UserSettingsImpl.EnableTeachingTips(Rec."User SID")
                        else
                            UserSettingsImpl.DisableTeachingTips(Rec."User SID");
                    end;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField("User SID");
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.TestField("User SID");
    end;

    trigger OnOpenPage()
    begin
        UserSettingsImpl.HideExternalUsers(Rec);
        CurrPage.Caption := UserSettingsTok;

        TeachingTipsEnabled := UserSettingsImpl.TeachingTipsEnabled(Rec."User SID");
    end;

    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
        Language: Codeunit Language;
        TimeZoneSelection: Codeunit "Time Zone Selection";
        TeachingTipsEnabled: Boolean;
        UserSettingsTok: Label 'User Settings';
}
