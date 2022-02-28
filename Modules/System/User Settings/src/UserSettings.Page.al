// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page that shows the settings of a given user.
/// </summary>
page 9204 "User Settings"
{
    AdditionalSearchTerms = 'company,role center,work date,role';
    DataCaptionExpression = Rec."User ID";
    ApplicationArea = All;
    Caption = 'My Settings';
    PageType = StandardDialog;
    UsageCategory = Administration;
    SourceTable = "User Settings";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    LinksAllowed = false;
    Extensible = true;
    HelpLink = 'https://go.microsoft.com/fwlink/?linkid=2149387';
    Permissions = tabledata User = r;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                Caption = 'User Settings';
                group("User Settings")
                {
                    ShowCaption = false;
                    field(UserRoleCenter; UserSettingsImpl.GetProfileName(Rec.Scope, Rec."App ID", Rec."Profile ID"))
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Caption = 'Role';
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the role that defines your home page with links to the most common tasks.';

                        trigger OnAssistEdit()
                        begin
                            UserSettingsImpl.ProfileLookup(Rec);
                        end;
                    }
                    field(Company; UserSettingsImpl.GetCompanyDisplayName(Rec.Company))
                    {
                        ApplicationArea = All;
                        Caption = 'Company';
                        Editable = false;
                        ToolTip = 'Specifies the database company that you work in. You must sign out and then sign in again for the change to take effect.';

                        trigger OnAssistEdit()
                        var
                            UserSettingsImpl: Codeunit "User Settings Impl.";
                        begin
                            UserSettingsImpl.LookupCompanies(Rec.Company);
                        end;
                    }
                    field("Work Date"; Rec."Work Date")
                    {
                        ApplicationArea = All;
                        Caption = 'Work Date';
                        ToolTip = 'Specifies the date that will be entered on transactions, typically today''s date. This change only affects the date on new transactions. Changes to this field will only be valid for the current session.';
                    }
                    field(Region; Language.GetWindowsLanguageName(Rec."Locale ID"))
                    {
                        ApplicationArea = All;
                        Caption = 'Region';
                        ToolTip = 'Specifies the regional settings, such as date and numeric format, on all devices. You must sign out and then sign in again for the change to take effect.';

                        trigger OnAssistEdit()
                        begin
                            Language.LookupWindowsLanguageId(Rec."Locale ID");
                        end;
                    }
                    field(LanguageName; Language.GetWindowsLanguageName(Rec."Language ID"))
                    {
                        ApplicationArea = All;
                        Caption = 'Language';
                        Importance = Promoted;
                        ToolTip = 'Specifies the display language, on all devices. You must sign out and then sign in again for the change to take effect.';

                        trigger OnAssistEdit()
                        begin
                            Language.LookupApplicationLanguageId(Rec."Language ID");
                        end;
                    }
                    field("Time Zone"; TimeZoneSelection.GetTimeZoneDisplayName(Rec."Time Zone"))
                    {
                        ApplicationArea = All;
                        Caption = 'Time Zone';
                        ToolTip = 'Specifies the time zone that you work in. You must sign out and then sign in again for the change to take effect.';

                        trigger OnAssistEdit()
                        begin
                            TimeZoneSelection.LookupTimeZone(Rec."Time Zone");
                        end;
                    }
                    field("Teaching Tips"; Rec."Teaching Tips")
                    {
                        ApplicationArea = All;
                        Caption = 'Teaching Tips';
                        ToolTip = 'Specifies whether to display short messages that inform, remind, or teach you about important fields and actions when you open a page.';
                    }
                }
                group(Security)
                {
                    Caption = 'Security';
                    Visible = LastLoginInfoVisible;
                    field("Last Login Info"; LastLoginInfo)
                    {
                        ApplicationArea = All;
                        Caption = 'LastLoginInfo';
                        ShowCaption = false;
                        Visible = LastLoginInfoVisible;
                        Editable = false;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Initialized then
            UserSettingsImpl.GetUserSettings(UserSecurityID(), Rec);

        OldUserSettings := Rec;

        LastLoginInfo := UserSettingsImpl.GetLastLoginInfo(Rec."Last Login");
        LastLoginInfoVisible := (Rec."User Security ID" = UserSecurityId()) and (LastLoginInfo <> '');
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            UserSettingsImpl.UpdateUserSettings(OldUserSettings, Rec);
    end;

    var
        OldUserSettings: Record "User Settings";
        Language: Codeunit Language;
        TimeZoneSelection: Codeunit "Time Zone Selection";
        UserSettingsImpl: Codeunit "User Settings Impl.";
        LastLoginInfo: Text;
        LastLoginInfoVisible: Boolean;
}