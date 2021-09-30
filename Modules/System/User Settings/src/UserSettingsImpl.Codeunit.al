// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9175 "User Settings Impl."
{
    Access = Internal;
    Permissions = tabledata "All Profile" = r,
                  tabledata Company = r,
                  tabledata "Extra Settings" = rim,
                  tabledata "Tenant Profile" = r,
                  tabledata User = r,
                  tabledata "User Personalization" = rim;

    var
        CompanySetUpInProgressMsg: Label 'Company %1 was just created, and we are still setting it up for you.\This may take up to 10 minutes, so take a short break before you begin to use %2.', Comment = '%1 - a company name,%2 - our product name';
        MyLastLoginLbl: Label 'Your last sign in was on %1.', Comment = '%1 - a date time object';
        TrialStartMsg: Label 'We''re glad you''ve chosen to explore %1!\\Your session will restart to activate the new settings.', Comment = '%1 - our product name';
        UserCreatedAppNameTxt: Label '(User-created)';
        DescriptionFilterTxt: Label 'Navigation menu only.';
        NotEnoughPermissionsErr: Label 'You cannot access settings for other users.';

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

    procedure GetUserSettings(UserSecurityID: Guid; var UserSettingsRec : Record "User Settings")
    var
        UserPersonalization: Record "User Personalization";
        ExtraSettings: Record "Extra Settings";
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
        
        UserSettingsRec.Company := UserPersonalization.Company;

        UserSettingsRec."Last Login" := UserLoginTimeTracker.GetPenultimateLoginDateTime();
        UserSettingsRec."Work Date" := WorkDate();
        UserSettingsRec.Initialized := true;
        UserSettings.OnAfterGetUserSettings(UserSettingsRec);

        GetAppSettings(UserSecurityID, ExtraSettings);
        UserSettingsRec."Teaching Tips" := ExtraSettings."Teaching Tips";

        if not UserSettingsRec.Insert() then
           UserSettingsRec.Modify();
    end;

    procedure RefreshUserSettings(var UserSettings: Record "User Settings")
    begin
        GetUserSettings(UserSettings."User Security ID", UserSettings);
    end;

    procedure UpdateUserSettings(OldSettings : Record "User Settings"; NewSettings : Record "User Settings") 
    var
        UserSettings: Codeunit "User Settings";
    begin
        UserSettings.OnUpdateUserSettings(OldSettings, NewSettings);

        if NewSettings."User Security ID" = UserSecurityId() then
            UpdateCurrentUsersSettings(OldSettings, NewSettings)
        else
            UpdateOtherUsersSettings(NewSettings);
    end;

    local procedure UpdateOtherUsersSettings(NewUserSettings : Record "User Settings")
    var
        UserPersonalization: Record "User Personalization";
        ExtraSettings: Record "Extra Settings";
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

        GetAppSettings(NewUserSettings."User Security ID", ExtraSettings);
        ExtraSettings."Teaching Tips" := NewUserSettings."Teaching Tips";
        ExtraSettings.Modify();
    end;

    local procedure UpdateCurrentUsersSettings(OldSettings : Record "User Settings"; NewSettings : Record "User Settings") 
    var
#if not CLEAN19
        AllProfile: Record "All Profile";
#endif
        ExtraSettings: Record "Extra Settings";
#if not CLEAN19
        UserSettings: Codeunit "User Settings";
#endif
        TenantLicenseState: Codeunit "Tenant License State";
        sessionSetting: SessionSettings;
        WasEvaluation: Boolean;
        ShouldRefreshSession: Boolean;
    begin
        sessionSetting.Init();
            
        if OldSettings."Language ID" <> NewSettings."Language ID" then begin
#if not CLEAN19
            UserSettings.OnBeforeLanguageChange(OldSettings."Language ID", NewSettings."Language ID");
#endif
            sessionSetting.LanguageId := NewSettings."Language ID";
            ShouldRefreshSession := true;
        end;
        
        if OldSettings."Locale ID" <> NewSettings."Locale ID" then begin
            sessionSetting.LocaleId := NewSettings."Locale ID";
            ShouldRefreshSession := true;
        end;
        
        if OldSettings."Time Zone" <> NewSettings."Time Zone" then begin
            ShouldRefreshSession := true;
            sessionSetting.Timezone := NewSettings."Time Zone";
        end;

        if OldSettings.Company <> NewSettings.Company then begin
            ShouldRefreshSession := true;
            WasEvaluation := TenantLicenseState.IsEvaluationMode();
            sessionSetting.Company := NewSettings.Company;
            if WasEvaluation and TenantLicenseState.IsTrialMode() then
                Message(StrSubstNo(TrialStartMsg, ProductName.Marketing()));
        end;

        if (OldSettings."Profile ID" <> NewSettings."Profile ID") or
            (OldSettings."App ID" <> NewSettings."App ID") or
            (OldSettings.Scope <> NewSettings.Scope)
        then begin
            ShouldRefreshSession := true;
            sessionSetting.ProfileId := NewSettings."Profile ID";
            sessionSetting.ProfileAppId := NewSettings."App ID";
            sessionSetting.ProfileSystemScope := NewSettings.Scope = NewSettings.Scope::System;
        end;

#if not CLEAN19
        if OldSettings."Work Date" <> NewSettings."Work Date" then begin
            UserSettings.OnBeforeWorkdateChange(WorkDate(), NewSettings."Work Date");
            WorkDate(NewSettings."Work Date");
        end;

        if AllProfile.Get(NewSettings.Scope, NewSettings."App ID", NewSettings."Profile ID") then;
            UserSettings.OnAfterQueryClosePage(NewSettings."Language ID", NewSettings."Locale ID", NewSettings."Time Zone", NewSettings.Company, AllProfile);
#else
        if OldSettings."Work Date" <> NewSettings."Work Date" then
            WorkDate(NewSettings."Work Date");
#endif

        if OldSettings."Teaching Tips" <> NewSettings."Teaching Tips" then begin
            GetAppSettings(UserSecurityId(), ExtraSettings);
            ExtraSettings."Teaching Tips" := NewSettings."Teaching Tips";
            ExtraSettings.Modify();
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

    procedure InitializeAppSettings(UserSecurityID: Guid; var ExtraSettings: Record "Extra Settings")
    begin
        ExtraSettings."User Security ID" := UserSecurityID;
        ExtraSettings."Teaching Tips" := true;
        ExtraSettings.Insert();
    end;

    procedure GetAppSettings(UserSecurityID: Guid; var ExtraSettings: Record "Extra Settings")
    begin
        if not ExtraSettings.Get(UserSecurityID) then
            InitializeAppSettings(UserSecurityID, ExtraSettings);
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
        ExtraSettings: Record "Extra Settings";
    begin
        GetAppSettings(UserSecurityId, ExtraSettings);
        ExtraSettings."Teaching Tips" := false;
        ExtraSettings.Modify();
    end;

    procedure EnableTeachingTips(UserSecurityId: Guid)
    var
        ExtraSettings: Record "Extra Settings";
    begin
        GetAppSettings(UserSecurityId, ExtraSettings);
        ExtraSettings."Teaching Tips" := true;
        ExtraSettings.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetAutoStartTours', '', false, false)]
    local procedure CheckIfUserCalloutsAreEnabled(var IsEnabled: Boolean)
    var
        ExtraSettings: Record "Extra Settings";
    begin
        GetAppSettings(UserSecurityId(), ExtraSettings);
        IsEnabled := ExtraSettings."Teaching Tips";
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
        UserPersonalization.SetFilter("License Type", '<>%1', UserPersonalization."License Type"::"External User");
        UserPersonalization.FilterGroup(0);
    end;

    procedure CheckPermissions(var UserSettings: Record "User Settings")
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
        EnvironmentInformation: Codeunit "Environment Information";
        UserPermissions: Codeunit "User Permissions";
    begin
        if (UserSettings.Count() > 1) or (UserSettings."User Security ID" <> UserSecurityId()) then begin
            if EnvironmentInformation.IsSaaSInfrastructure() and not AzureADUserManagement.IsUserTenantAdmin() then
                Error(NotEnoughPermissionsErr);
            if EnvironmentInformation.IsOnPrem() and not UserPermissions.IsSuper(UserSecurityId()) then
                Error(NotEnoughPermissionsErr);
        end;
    end;

    procedure CheckPermissions(var UserPersonalization: Record "User Personalization")
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
        EnvironmentInformation: Codeunit "Environment Information";
        UserPermissions: Codeunit "User Permissions";
    begin
        if (UserPersonalization.Count() > 1) or (UserPersonalization."User SID" <> UserSecurityId()) then begin
            if EnvironmentInformation.IsSaaSInfrastructure() and not AzureADUserManagement.IsUserTenantAdmin() then
                Error(NotEnoughPermissionsErr);
            if EnvironmentInformation.IsOnPrem() and not UserPermissions.IsSuper(UserSecurityId()) then
                Error(NotEnoughPermissionsErr);
        end;
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
