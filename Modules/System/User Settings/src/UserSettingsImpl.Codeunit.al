// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9175 "User Settings Impl."
{
    Access = Internal;
    Permissions = tabledata "All Profile" = r,
                  tabledata Company = r,
#if not CLEAN20
                  tabledata "Extra Settings" = rim,
#endif
                  tabledata "Application User Settings" = rim,
                  tabledata "Tenant Profile" = r,
                  tabledata User = r,
                  tabledata "User Personalization" = rim;

    var
        CompanySetUpInProgressMsg: Label 'Company %1 was just created, and we are still setting it up for you.\This may take up to 10 minutes, so take a short break before you begin to use %2.', Comment = '%1 - a company name,%2 - our product name';
        MyLastLoginLbl: Label 'Your last sign in was on %1.', Comment = '%1 - a date time object';
        TrialStartMsg: Label 'We''re glad you''ve chosen to explore %1!\\Your session will restart to activate the new settings.', Comment = '%1 - our product name';
        UserCreatedAppNameTxt: Label '(User-created)';
        DescriptionFilterTxt: Label 'Navigation menu only.';
        NotEnoughPermissionsErr: Label 'You cannot open this page. Only administrators can access settings for other users.';

    procedure GetPageId(): Integer
    var
        UserSettings: Codeunit "User Settings";
        SettingsPageId: Integer;
    begin
        SettingsPageId := Page::"User Settings";
        UserSettings.OnGetSettingsPageID(SettingsPageId);
        exit(SettingsPageId);
    end;

    procedure GetLastLoginInfo(LastLoginDateTime: DateTime): Text
    begin
        if LastLoginDateTime <> 0DT then
            exit(StrSubstNo(MyLastLoginLbl, LastLoginDateTime));

        exit('');
    end;

    procedure GetProfileName(Scope: Option System,Tenant; AppID: Guid; ProfileID: Code[30]) ProfileName: Text
    var
        AllProfile: Record "All Profile";
    begin
        // If current profile has been changed, then find it and update the description; else, get the default
        if not AllProfile.Get(Scope, AppID, ProfileID) then
            exit;

        ProfileName := AllProfile.Caption;
    end;

    procedure ProfileLookup(var UserSettingsRec: Record "User Settings")
    var
        TempAllProfile: Record "All Profile" temporary;
#if not CLEAN19
        UserSettings: Codeunit "User Settings";
#endif
    begin
        PopulateProfiles(TempAllProfile);

        if TempAllProfile.Get(UserSettingsRec.Scope, UserSettingsRec."App ID", UserSettingsRec."Profile ID") then;
        if Page.RunModal(Page::Roles, TempAllProfile) = Action::LookupOK then begin
            UserSettingsRec."Profile ID" := TempAllProfile."Profile ID";
            UserSettingsRec."App ID" := TempAllProfile."App ID";
            UserSettingsRec.Scope := TempAllProfile.Scope;
        end;

#if not CLEAN19
        UserSettings.OnUserRoleCenterChange(TempAllProfile);
#endif
    end;

    procedure PopulateProfiles(var TempAllProfile: Record "All Profile" temporary)
    var
        AllProfile: Record "All Profile";
    begin
        TempAllProfile.Reset();
        TempAllProfile.DeleteAll();
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter(Description, '<> %1', DescriptionFilterTxt);
        if AllProfile.FindSet() then
            repeat
                TempAllProfile := AllProfile;
                if IsNullGuid(TempAllProfile."App ID") then
                    TempAllProfile."App Name" := UserCreatedAppNameTxt;
                TempAllProfile.Insert();
            until AllProfile.Next() = 0;
    end;

    procedure GetUserSettings(UserSecurityID: Guid; var UserSettingsRec: Record "User Settings")
    var
        UserPersonalization: Record "User Personalization";
        ApplicationUserSettings: Record "Application User Settings";
        AllProfile: Record "All Profile";
        UserSettings: Codeunit "User Settings";
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
    begin
        GetPlatformSettings(UserSecurityID, UserPersonalization);

        UserSettingsRec."User Security ID" := UserSecurityID;
        UserPersonalization.CalcFields("User ID");
        UserSettingsRec."User ID" := UserPersonalization."User ID";
        UserSettingsRec."Profile ID" := UserPersonalization."Profile ID";
        UserSettingsRec."App ID" := UserPersonalization."App ID";
        UserSettingsRec.Scope := UserPersonalization.Scope;

        if UserSettingsRec."Profile ID" = '' then begin
            AllProfile.SetRange("Default Role Center", true);
            AllProfile.SetRange(Enabled, true);
            if AllProfile.FindFirst() then begin
                UserSettings.OnGetDefaultProfile(AllProfile);
                UserSettingsRec."Profile ID" := AllProfile."Profile ID";
                UserSettingsRec."App ID" := AllProfile."App ID";
                UserSettingsRec.Scope := AllProfile.Scope;
            end;
        end;

        UserSettingsRec."Language ID" := UserPersonalization."Language ID";
        UserSettingsRec."Locale ID" := UserPersonalization."Locale ID";
        UserSettingsRec."Time Zone" := UserPersonalization."Time Zone";

        if CompanyName() <> '' then
            UserSettingsRec.Company := CopyStr(CompanyName(), 1, 30)
        else
            UserSettingsRec.Company := UserPersonalization.Company;

        UserSettingsRec."Last Login" := UserLoginTimeTracker.GetPenultimateLoginDateTime(UserSecurityID);
        UserSettingsRec."Work Date" := WorkDate();
        UserSettingsRec.Initialized := true;
        UserSettings.OnAfterGetUserSettings(UserSettingsRec);

        GetAppSettings(UserSecurityID, ApplicationUserSettings);
        UserSettingsRec."Teaching Tips" := ApplicationUserSettings."Teaching Tips";

        if not UserSettingsRec.Insert() then
            UserSettingsRec.Modify();
    end;

    procedure RefreshUserSettings(var UserSettings: Record "User Settings")
    begin
        GetUserSettings(UserSettings."User Security ID", UserSettings);
    end;

    procedure UpdateUserSettings(OldUserSettings: Record "User Settings"; NewUserSettings: Record "User Settings")
    var
        UserSettings: Codeunit "User Settings";
    begin
        UserSettings.OnUpdateUserSettings(OldUserSettings, NewUserSettings);

        if NewUserSettings."User Security ID" = UserSecurityId() then
            UpdateCurrentUsersSettings(OldUserSettings, NewUserSettings)
        else
            UpdateOtherUsersSettings(NewUserSettings);
    end;

    local procedure UpdateOtherUsersSettings(NewUserSettings: Record "User Settings")
    var
        UserPersonalization: Record "User Personalization";
        ApplicationUserSettings: Record "Application User Settings";
    begin
        UserPersonalization.Get(NewUserSettings."User Security ID");

        UserPersonalization."Language ID" := NewUserSettings."Language ID";
        UserPersonalization."Locale ID" := NewUserSettings."Locale ID";
        UserPersonalization.Company := NewUserSettings.Company;
        UserPersonalization."Time Zone" := NewUserSettings."Time Zone";
        UserPersonalization."Profile ID" := NewUserSettings."Profile ID";
        UserPersonalization.Scope := NewUserSettings.Scope;
        UserPersonalization."App ID" := NewUserSettings."App ID";
        UserPersonalization.Modify();

        GetAppSettings(NewUserSettings."User Security ID", ApplicationUserSettings);
        ApplicationUserSettings."Teaching Tips" := NewUserSettings."Teaching Tips";
        ApplicationUserSettings.Modify();
    end;

    local procedure UpdateCurrentUsersSettings(OldUserSettings: Record "User Settings"; NewUserSettings: Record "User Settings")
    var
#if not CLEAN19
        AllProfile: Record "All Profile";
#endif
        ApplicationUserSettings: Record "Application User Settings";
#if not CLEAN19
        UserSettings: Codeunit "User Settings";
#endif
        TenantLicenseState: Codeunit "Tenant License State";
        sessionSetting: SessionSettings;
        WasEvaluation: Boolean;
        ShouldRefreshSession: Boolean;
    begin
        sessionSetting.Init();

        if OldUserSettings."Language ID" <> NewUserSettings."Language ID" then begin
#if not CLEAN19
            UserSettings.OnBeforeLanguageChange(OldUserSettings."Language ID", NewUserSettings."Language ID");
#endif
            sessionSetting.LanguageId := NewUserSettings."Language ID";
            ShouldRefreshSession := true;
        end;

        if OldUserSettings."Locale ID" <> NewUserSettings."Locale ID" then begin
            sessionSetting.LocaleId := NewUserSettings."Locale ID";
            ShouldRefreshSession := true;
        end;

        if OldUserSettings."Time Zone" <> NewUserSettings."Time Zone" then begin
            ShouldRefreshSession := true;
            sessionSetting.Timezone := NewUserSettings."Time Zone";
        end;

        if OldUserSettings.Company <> NewUserSettings.Company then begin
            ShouldRefreshSession := true;
            WasEvaluation := TenantLicenseState.IsEvaluationMode();
            sessionSetting.Company := NewUserSettings.Company;
            if WasEvaluation and TenantLicenseState.IsTrialMode() then
                Message(StrSubstNo(TrialStartMsg, ProductName.Marketing()));
        end;

        if (OldUserSettings."Profile ID" <> NewUserSettings."Profile ID") or
            (OldUserSettings."App ID" <> NewUserSettings."App ID") or
            (OldUserSettings.Scope <> NewUserSettings.Scope)
        then begin
            ShouldRefreshSession := true;
            sessionSetting.ProfileId := NewUserSettings."Profile ID";
            sessionSetting.ProfileAppId := NewUserSettings."App ID";
            sessionSetting.ProfileSystemScope := NewUserSettings.Scope = NewUserSettings.Scope::System;
        end;

#if not CLEAN19
        if OldUserSettings."Work Date" <> NewUserSettings."Work Date" then begin
            UserSettings.OnBeforeWorkdateChange(WorkDate(), NewUserSettings."Work Date");
            WorkDate(NewUserSettings."Work Date");
        end;

        if AllProfile.Get(NewUserSettings.Scope, NewUserSettings."App ID", NewUserSettings."Profile ID") then;
        UserSettings.OnAfterQueryClosePage(NewUserSettings."Language ID", NewUserSettings."Locale ID", NewUserSettings."Time Zone", NewUserSettings.Company, AllProfile);
#else
        if OldUserSettings."Work Date" <> NewUserSettings."Work Date" then
            WorkDate(NewUserSettings."Work Date");
#endif

        if OldUserSettings."Teaching Tips" <> NewUserSettings."Teaching Tips" then begin
            GetAppSettings(UserSecurityId(), ApplicationUserSettings);
            ApplicationUserSettings."Teaching Tips" := NewUserSettings."Teaching Tips";
            ApplicationUserSettings.Modify();
        end;

        if ShouldRefreshSession then
            sessionSetting.RequestSessionUpdate(true);
    end;

    procedure GetCompanyDisplayName(CompanyName: Text[30]): Text[250]
    var
        Company: Record Company;
    begin
        if Company.Get(CompanyName) then
            exit(GetCompanyDisplayName(Company))
    end;

    procedure GetCompanyDisplayName(Company: Record Company): Text[250]
    begin
        if Company."Display Name" <> '' then
            exit(Company."Display Name");
        exit(Company.Name)
    end;

    procedure GetAllUsersSettings(var UserSettings: Record "User Settings")
    var
        User: Record User;
        UserSelection: Codeunit "User Selection";
    begin
        UserSelection.HideExternalUsers(User);
        if User.FindSet() then
            repeat
                GetUserSettings(User."User Security ID", UserSettings);
            until User.Next() = 0;
    end;

    procedure LookupCompanies(var CompanyName: Text[30])
    var
        SelectedCompany: Record Company;
        UserSettings: Codeunit "User Settings";
        AccessibleCompanies: Page "Accessible Companies";
        IsSetupInProgress: Boolean;
    begin
        AccessibleCompanies.Initialize();

        if SelectedCompany.Get(CompanyName) then
            AccessibleCompanies.SetRecord(SelectedCompany);

        AccessibleCompanies.LookupMode(true);

        if AccessibleCompanies.RunModal() = Action::LookupOK then begin
            AccessibleCompanies.GetRecord(SelectedCompany);
            UserSettings.OnCompanyChange(SelectedCompany.Name, IsSetupInProgress);
            if IsSetupInProgress then
                Message(StrSubstNo(CompanySetUpInProgressMsg, SelectedCompany.Name, ProductName.Short()))
            else
                CompanyName := SelectedCompany.Name;
        end;
    end;

    [Scope('OnPrem')]
    procedure GetAllowedCompaniesForCurrentUser(var TempCompany: Record Company temporary)
    var
        Company: Record Company;
        UserAccountHelper: DotNet NavUserAccountHelper;
        CompanyName: Text[30];
    begin
        TempCompany.DeleteAll();
        foreach CompanyName in UserAccountHelper.GetAllowedCompanies() do
            if Company.Get(CompanyName) then begin
                TempCompany := Company;
                TempCompany."Display Name" := GetCompanyDisplayName(TempCompany);
                TempCompany.Insert();
            end;
    end;

    procedure InitializePlatformSettings(UserSecurityID: Guid; var UserPersonalization: Record "User Personalization")
    var
        SessionSetting: SessionSettings;
    begin
        // Initialize with Current User's Settings as default
        SessionSetting.Init();
        UserPersonalization.Init();
        UserPersonalization."User SID" := UserSecurityID;
        UserPersonalization."Language ID" := SessionSetting.LanguageId;
        UserPersonalization."Locale ID" := SessionSetting.LocaleId;
        UserPersonalization."Time Zone" := CopyStr(SessionSetting.TimeZone, 1, MaxStrLen(UserPersonalization."Time Zone"));
        UserPersonalization.Insert();
    end;

#if not CLEAN20
    [Obsolete('Replaced with function that takes Application User Settings record', '20.0')]
    procedure InitializeAppSettings(UserSecurityID: Guid; var ExtraSettings: Record "Extra Settings")
    begin
        ExtraSettings."User Security ID" := UserSecurityID;
        ExtraSettings."Teaching Tips" := true;
        ExtraSettings.Insert();
    end;
#endif

    procedure InitializeAppSettings(UserSecurityID: Guid; var ApplicationUserSettings: Record "Application User Settings")
    begin
        ApplicationUserSettings."User Security ID" := UserSecurityID;
        ApplicationUserSettings."Teaching Tips" := true;
        ApplicationUserSettings.Insert();
    end;

#if not CLEAN20
    [Obsolete('Replaced with function that takes Application User Settings record', '20.0')]
    procedure GetAppSettings(UserSecurityID: Guid; var ExtraSettings: Record "Extra Settings")
    begin
        if not ExtraSettings.Get(UserSecurityID) then
            InitializeAppSettings(UserSecurityID, ExtraSettings);
    end;
#endif

    procedure GetAppSettings(UserSecurityID: Guid; var ApplicationUserSettings: Record "Application User Settings")
    begin
        if not ApplicationUserSettings.Get(UserSecurityID) then
            InitializeAppSettings(UserSecurityID, ApplicationUserSettings);
    end;

    procedure GetPlatformSettings(UserSecurityID: Guid; var UserPersonalization: Record "User Personalization")
    begin
        if not UserPersonalization.Get(UserSecurityID) then
            InitializePlatformSettings(UserSecurityID, UserPersonalization);
    end;

    procedure GetUsersFullName(UserSecurityId: Guid): Text
    var
        User: Record User;
    begin
        if User.Get(UserSecurityId) then
            exit(User."Full Name");
    end;

    procedure DisableTeachingTips(UserSecurityId: Guid)
    var
        ApplicationUserSettings: Record "Application User Settings";
    begin
        GetAppSettings(UserSecurityId, ApplicationUserSettings);
        ApplicationUserSettings."Teaching Tips" := false;
        ApplicationUserSettings.Modify();
    end;

    procedure EnableTeachingTips(UserSecurityId: Guid)
    var
        ApplicationUserSettings: Record "Application User Settings";
    begin
        GetAppSettings(UserSecurityId, ApplicationUserSettings);
        ApplicationUserSettings."Teaching Tips" := true;
        ApplicationUserSettings.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetAutoStartTours', '', false, false)]
    local procedure CheckIfUserCalloutsAreEnabled(var IsEnabled: Boolean)
    var
        ApplicationUserSettings: Record "Application User Settings";
    begin
        GetAppSettings(UserSecurityId(), ApplicationUserSettings);
        IsEnabled := ApplicationUserSettings."Teaching Tips";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OpenSettings', '', false, false)]
    local procedure OpenSettings()
    begin
        OpenUserSettings(UserSecurityId());
    end;

    procedure OpenUserSettings(UserSecurityID: Guid)
    var
        UserSettingsRec: Record "User Settings";
        UserSettings: Codeunit "User Settings";
        SettingsPageID: Integer;
        Handled: Boolean;
    begin
        SettingsPageID := GetPageId();
        UserSettings.OnBeforeOpenSettings(Handled);
        if Handled then
            exit;
        UserSettings.GetUserSettings(UserSecurityID, UserSettingsRec);
        Page.Run(SettingsPageID, UserSettingsRec);
    end;

    procedure HideExternalUsers(var UserPersonalization: Record "User Personalization")
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not EnvironmentInfo.IsSaaS() then
            exit;

        UserPersonalization.FilterGroup(2);
        UserPersonalization.CalcFields("License Type");
        UserPersonalization.SetFilter("License Type", '<>%1&<>%2', UserPersonalization."License Type"::"External User", UserPersonalization."License Type"::Application);
        UserPersonalization.FilterGroup(0);
    end;

    procedure CheckPermissions(var UserSettings: Record "User Settings")
    begin
        if (UserSettings.Count() > 1) or (UserSettings."User Security ID" <> UserSecurityId()) then
            CheckPermissionsInternal();
    end;

    procedure CheckPermissions(var UserPersonalization: Record "User Personalization")
    begin
        if (UserPersonalization.Count() > 1) or (UserPersonalization."User SID" <> UserSecurityId()) then
            CheckPermissionsInternal();
    end;

    local procedure CheckPermissionsInternal()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADUserManagement: Codeunit "Azure AD User Management";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        UserPermissions: Codeunit "User Permissions";
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() and
            (not AzureADUserManagement.IsUserTenantAdmin()) and
            (not AzureADGraphUser.IsUserDelegatedAdmin()) and
            (not AzureADGraphUser.IsUserDelegatedHelpdesk())
        then
            Error(NotEnoughPermissionsErr);
        if EnvironmentInformation.IsOnPrem() and not UserPermissions.IsSuper(UserSecurityId()) then
            Error(NotEnoughPermissionsErr);
    end;

    procedure EditUserID(var UserPersonalization: Record "User Personalization"): Boolean
    var
        UserPersonalization2: Record "User Personalization";
        User: Record User;
        UserSelection: Codeunit "User Selection";
        UserAlreadyExistErr: Label '%1 %2 already exists.', Comment = '%1 = UserPersonalization TableCaption; %2 = UserID.';
    begin
        if not UserSelection.Open(User) then
            exit(false);

        if IsNullGuid(User."User Security ID") then
            exit(false);

        if User."User Security ID" <> UserPersonalization."User SID" then begin
            if UserPersonalization2.Get(User."User Security ID") then begin
                UserPersonalization2.CalcFields("User ID");
                Error(UserAlreadyExistErr, UserPersonalization.TableCaption, UserPersonalization2."User ID");
            end;

            UserPersonalization.Validate("User SID", User."User Security ID");
            UserPersonalization.CalcFields("User ID");
            UserPersonalization.CalcFields("Full Name");
            exit(true);
        end;
        exit(false);
    end;

    internal procedure EditProfileID(var UserPersonalization: Record "User Personalization")
    var
        TempAllProfile: Record "All Profile" temporary;
    begin
        PopulateProfiles(TempAllProfile);

        if TempAllProfile.Get(UserPersonalization.Scope, UserPersonalization."App ID", UserPersonalization."Profile ID") then;
        if Page.RunModal(Page::Roles, TempAllProfile) = Action::LookupOK then begin
            UserPersonalization."Profile ID" := TempAllProfile."Profile ID";
            UserPersonalization."App ID" := TempAllProfile."App ID";
            UserPersonalization.Scope := TempAllProfile.Scope;
            UserPersonalization.CalcFields("Role");
        end;
    end;
}
