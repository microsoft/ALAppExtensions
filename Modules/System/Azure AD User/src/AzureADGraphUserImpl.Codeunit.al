// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9011 "Azure AD Graph User Impl."
{
    Access = Internal;
    Permissions = tabledata User = rm,
                  tabledata "User Property" = r;

    trigger OnRun()
    begin
    end;

    var
        AzureADGraph: Codeunit "Azure AD Graph";
        GraphUserInfo: DotNet UserInfo;
        UserDoesNotObjectIdSetErr: Label 'The user with the security ID %1 does not have a valid object ID in Azure Active Directory.', Comment = '%1 =  The specified User Security ID';
        CouldNotFindGraphUserErr: Label 'An Azure Active Directory user with the object ID %1 was not found.', Comment = '%1 = The specified object id';

    [TryFunction]
    [NonDebuggable]
    procedure GetGraphUser(UserSecurityId: Guid; ForceFetchFromGraph: Boolean; var GraphUserOut: DotNet UserInfo)
    begin
        InitializeGraphUser(UserSecurityId, ForceFetchFromGraph);
        GraphUserOut := GraphUserInfo;
    end;

    [NonDebuggable]
    procedure GetObjectId(UserSecurityID: Guid): Text
    begin
        InitializeGraphUser(UserSecurityID, false);

        if IsNull(GraphUserInfo) then
            exit;

        exit(GraphUserInfo.ObjectId());
    end;

    [NonDebuggable]
    procedure GetUserAuthenticationObjectId(UserSecurityId: Guid): Text
    var
        UserProperty: Record "User Property";
    begin
        if not UserProperty.Get(UserSecurityId) then
            Error(UserDoesNotObjectIdSetErr, UserSecurityId);

        exit(UserProperty."Authentication Object ID");
    end;

    [NonDebuggable]
    procedure TryGetUserAuthenticationObjectId(UserSecurityId: Guid; var AuthenticationObjectId: Text): Boolean
    var
        UserProperty: Record "User Property";
    begin
        if not UserProperty.Get(UserSecurityId) then
            exit(false);

        AuthenticationObjectId := UserProperty."Authentication Object ID";
        exit(true);
    end;

    [NonDebuggable]
    procedure GetUser(AuthenticationObjectID: Text; var User: Record User): Boolean
    var
        UserProperty: Record "User Property";
    begin
        UserProperty.SetRange("Authentication Object ID", AuthenticationObjectId);
        if UserProperty.FindFirst() then
            exit(User.Get(UserProperty."User Security ID"));
    end;

    [NonDebuggable]
    procedure UpdateUserFromAzureGraph(var User: Record User; var GraphUserInfo: DotNet UserInfo): Boolean
    var
        ModifyUser: Boolean;
        IsUserModified: Boolean;
        TempString: Text;
    begin
        if IsNull(GraphUserInfo) then
            exit;

        if not CheckUpdateUserRequired(User, GraphUserInfo) then
            exit;

        User.LockTable();
        if not User.Get(User."User Security ID") then begin
            Commit();
            exit;
        end;

        SetUserLanguage(GraphUserInfo, User."User Security ID");

        if GraphUserInfo.AccountEnabled() and (User.State = User.State::Disabled) then begin
            User.State := User.State::Enabled;
            ModifyUser := true;
        end;

        if (not GraphUserInfo.AccountEnabled()) and (User.State = User.State::Enabled) then begin
            User.State := User.State::Disabled;
            ModifyUser := true;
        end;

        TempString := GetFullName(GraphUserInfo);
        if LowerCase(User."Full Name") <> LowerCase(TempString) then begin
            User."Full Name" := CopyStr(TempString, 1, MaxStrLen(User."Full Name"));
            ModifyUser := true;
        end;

        if not IsNull(GraphUserInfo.Mail()) then begin
            TempString := GetContactEmail(GraphUserInfo);
            if LowerCase(User."Contact Email") <> LowerCase(TempString) then begin
                User."Contact Email" := CopyStr(TempString, 1, MaxStrLen(User."Contact Email"));
                ModifyUser := true;
            end;
        end;

        TempString := GetAuthenticationEmail(GraphUserInfo);
        if LowerCase(User."Authentication Email") <> LowerCase(TempString) then begin
            // Clear current authentication mail
            User."Authentication Email" := '';
            User.Modify();

            ModifyUser := false;
            IsUserModified := true;

            EnsureAuthenticationEmailIsNotInUse(TempString);
            UpdateAuthenticationEmail(User, GraphUserInfo);
        end;

        if ModifyUser then
            User.Modify();

        Commit();
        exit(ModifyUser or IsUserModified);
    end;

    [NonDebuggable]
    procedure EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail: Text)
    var
        User: Record User;
        ModifiedUser: Record User;
        GraphUserLocal: DotNet UserInfo;
        UserSecurityId: Guid;
        GraphUserExists: Boolean;
    begin
        // Clear all duplicate authentication email.
        User.SetRange("Authentication Email", CopyStr(AuthenticationEmail, 1, MaxStrLen(User."Authentication Email")));
        if not User.FindSet() then
            exit;
        repeat
            UserSecurityId := User."User Security ID";

            GraphUserExists := GetGraphUser(UserSecurityId, false, GraphUserLocal);

            User."Authentication Email" := '';
            User.Modify();

            if GraphUserExists then begin
                // Cascade changes to authentication email, terminates at the first time an authentication email is not found.
                EnsureAuthenticationEmailIsNotInUse(GraphUserLocal.UserPrincipalName());
                if ModifiedUser.Get(UserSecurityId) then
                    UpdateAuthenticationEmail(ModifiedUser, GraphUserLocal);
            end;
        until User.Next() = 0;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure InitializeGraphUser(UserSecurityID: Guid; ForceFetchFromGraph: Boolean)
    var
        UserObjectID: Text;
    begin
        Clear(GraphUserInfo);

        if not ForceFetchFromGraph then
            if UserSecurityID = UserSecurityId() then begin
                AzureADGraph.GetCurrentUser(GraphUserInfo);
                if not IsNull(GraphUserInfo) then
                    exit;
            end;

        UserObjectID := GetUserAuthenticationObjectId(UserSecurityID);
        if UserObjectID = '' then
            Error(CouldNotFindGraphUserErr, UserObjectID);

        AzureADGraph.GetUserByObjectId(UserObjectID, GraphUserInfo);
        if IsNull(GraphUserInfo) then
            Error(CouldNotFindGraphUserErr, UserObjectID);
    end;

    [NonDebuggable]
    local procedure CheckUpdateUserRequired(var User: Record User; var GraphUserInfo: DotNet UserInfo): Boolean
    var
        TempString: Text;
    begin
        if not User.Get(User."User Security ID") then
            exit(false);

        if GraphUserInfo.AccountEnabled() and (User.State = User.State::Disabled) then
            exit(true);

        if (not GraphUserInfo.AccountEnabled()) and (User.State = User.State::Enabled) then
            exit(true);

        TempString := GetFullName(GraphUserInfo);
        if LowerCase(User."Full Name") <> LowerCase(TempString) then
            exit(true);

        if not IsNull(GraphUserInfo.Mail()) then begin
            TempString := GetContactEmail(GraphUserInfo);
            if LowerCase(User."Contact Email") <> LowerCase(TempString) then
                exit(true);
        end;

        TempString := CopyStr(Format(GraphUserInfo.UserPrincipalName()), 1, MaxStrLen(User."Authentication Email"));
        if LowerCase(User."Authentication Email") <> LowerCase(TempString) then
            exit(true);

        exit(false);
    end;

    [NonDebuggable]
    local procedure UpdateAuthenticationEmail(var User: Record User; var GraphUserInfo: DotNet UserInfo)
    var
        NavUserAuthenticationHelper: DotNet NavUserAccountHelper;
    begin
        if IsNull(GraphUserInfo) then
            exit;

        User."Authentication Email" := GetAuthenticationEmail(GraphUserInfo);
        if User.Modify() then
            NavUserAuthenticationHelper.SetAuthenticationObjectId(User."User Security ID", GraphUserInfo.ObjectId());
    end;

    [NonDebuggable]
    procedure IsUserDelegatedAdmin(): Boolean
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
        IsUserDelegatedAdministrator, Handled : Boolean;
    begin
        OnIsUserDelegatedAdmin(IsUserDelegatedAdministrator, Handled);
        if Handled then
            exit(IsUserDelegatedAdministrator);

        exit(UserAccountHelper.IsUserDelegatedAdmin());
    end;

    [NonDebuggable]
    procedure IsUserDelegatedHelpdesk(): Boolean
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
    begin
        exit(UserAccountHelper.IsUserDelegatedHelpdesk());
    end;

    [NonDebuggable]
    local procedure SetUserLanguage(GraphUserToQuery: DotNet UserInfo; UserSecID: Guid)
    var
        Language: Codeunit Language;
        LanguageId: Integer;
    begin
        LanguageId := GetPreferredLanguageID(GraphUserToQuery);
        Language.SetPreferredLanguageID(UserSecID, LanguageId);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetLanguageCode(CultureName: Text; var CultureCode: Code[10])
    var
        CultureInfo: DotNet CultureInfo;
    begin
        CultureInfo := CultureInfo.CultureInfo(CultureName);
        CultureCode := CultureInfo.ThreeLetterWindowsLanguageName();
    end;

    [NonDebuggable]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADGraph.SetTestInProgress(TestInProgress);
    end;

    [NonDebuggable]
    procedure GetAuthenticationEmail(GraphUserToQuery: DotNet UserInfo): Text[250]
    var
        DummyUser: Record User;
    begin
        exit(CopyStr(Format(GraphUserToQuery.UserPrincipalName()), 1, MaxStrLen(DummyUser."Authentication Email")));
    end;

    [NonDebuggable]
    procedure GetDisplayName(GraphUserToQuery: DotNet UserInfo): Text[50]
    var
        DummyUser: Record User;
    begin
        if IsNull(GraphUserToQuery.DisplayName()) then
            exit('');
        exit(CopyStr(Format(GraphUserToQuery.DisplayName()), 1, MaxStrLen(DummyUser."User Name")));
    end;

    [NonDebuggable]
    procedure GetContactEmail(GraphUserToQuery: DotNet UserInfo): Text[250]
    var
        DummyUser: Record User;
    begin
        if IsNull(GraphUserToQuery.Mail()) then
            exit('');
        exit(CopyStr(GraphUserToQuery.Mail(), 1, MaxStrLen(DummyUser."Contact Email")));
    end;

    [NonDebuggable]
    procedure GetFullName(GraphUserToQuery: DotNet UserInfo): Text[80]
    var
        DummyUser: Record User;
        FullUserName: Text;
        GivenName: Text;
        Surname: Text;
    begin
        if IsNull(GraphUserToQuery.GivenName()) then
            GivenName := ''
        else
            GivenName := Format(GraphUserToQuery.GivenName());

        if IsNull(GraphUserToQuery.Surname()) then
            Surname := ''
        else
            Surname := Format(GraphUserToQuery.Surname());

        FullUserName := GivenName;
        if Surname <> '' then
            FullUserName := FullUserName + ' ';
        FullUserName := FullUserName + Surname;
        exit(CopyStr(FullUserName, 1, MaxStrLen(DummyUser."Full Name")));
    end;

    [NonDebuggable]
    procedure GetPreferredLanguageID(GraphUserToQuery: DotNet UserInfo): Integer
    var
        LanguageManagement: Codeunit Language;
        LanguageCode: Code[10];
        LanguageId: Integer;
        PreferredLanguage: Text;
    begin
        if IsNull(GraphUserToQuery.PreferredLanguage()) then
            exit(0);

        PreferredLanguage := GraphUserToQuery.PreferredLanguage();

        if PreferredLanguage <> '' then
            if TryGetLanguageCode(PreferredLanguage, LanguageCode) then
                // If we support the language, get the language id
                LanguageId := LanguageManagement.GetLanguageId(LanguageCode);

        exit(LanguageId);
    end;

    [InternalEvent(false)]
    local procedure OnIsUserDelegatedAdmin(var IsUserDelegatedAdmin: Boolean; var Handled: Boolean)
    begin
    end;
}

