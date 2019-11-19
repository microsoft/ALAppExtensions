// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9011 "Azure AD Graph User Impl."
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        AzureADGraph: Codeunit "Azure AD Graph";
        GraphUser: DotNet UserInfo;
        UserDoesNotObjectIdSetErr: Label 'The user with the security ID %1 does not have a valid object ID in Azure Active Directory.', Comment = '%1 =  The specified User Security ID';
        CouldNotFindGraphUserErr: Label 'An Azure Active Directory user with the object ID %1 was not found.', Comment = '%1 = The specified object id';

    [TryFunction]
    procedure GetGraphUser(UserSecurityId: Guid; var GraphUserOut: DotNet UserInfo)
    begin
        InitializeGraphUser(UserSecurityId);
        GraphUserOut := GraphUser;
    end;

    procedure GetObjectId(UserSecurityID: Guid): Text
    begin
        InitializeGraphUser(UserSecurityID);

        if IsNull(GraphUser) then
            exit;

        exit(GraphUser.ObjectId());
    end;

    procedure GetUserAuthenticationObjectId(UserSecurityId: Guid): Text
    var
        UserProperty: Record "User Property";
    begin
        if not UserProperty.Get(UserSecurityId) then
            Error(UserDoesNotObjectIdSetErr, UserSecurityId);

        exit(UserProperty."Authentication Object ID");
    end;

    procedure UpdateUserFromAzureGraph(var User: Record User; var GraphUser: DotNet UserInfo): Boolean
    var
        ModifyUser: Boolean;
        IsUserModified: Boolean;
        TempString: Text;
    begin
        if IsNull(GraphUser) then
            exit;

        if not CheckUpdateUserRequired(User, GraphUser) then
            exit;

        User.LockTable();
        if not User.Get(User."User Security ID") then begin
            Commit();
            exit;
        end;

        SetUserLanguage(GraphUser.PreferredLanguage());

        if GraphUser.AccountEnabled() and (User.State = User.State::Disabled) then begin
            User.State := User.State::Enabled;
            ModifyUser := true;
        end;

        if (not GraphUser.AccountEnabled()) and (User.State = User.State::Enabled) then begin
            User.State := User.State::Disabled;
            ModifyUser := true;
        end;

        TempString := CopyStr(GetUserFullName(User."User Security ID"), 1, MaxStrLen(User."Full Name"));
        if LowerCase(User."Full Name") <> LowerCase(TempString) then begin
            User."Full Name" := CopyStr(TempString, 1, MaxStrLen(User."Full Name"));
            ModifyUser := true;
        end;

        if not IsNull(GraphUser.Mail()) then begin
            TempString := CopyStr(Format(GraphUser.Mail()), 1, MaxStrLen(User."Contact Email"));
            if LowerCase(User."Contact Email") <> LowerCase(TempString) then begin
                User."Contact Email" := CopyStr(TempString, 1, MaxStrLen(User."Contact Email"));
                ModifyUser := true;
            end;
        end;

        TempString := CopyStr(Format(GraphUser.UserPrincipalName()), 1, MaxStrLen(User."Authentication Email"));
        if LowerCase(User."Authentication Email") <> LowerCase(TempString) then begin
            // Clear current authentication mail
            User."Authentication Email" := '';
            User.Modify();

            ModifyUser := false;
            IsUserModified := true;

            EnsureAuthenticationEmailIsNotInUse(TempString);
            UpdateAuthenticationEmail(User, GraphUser);
        end;

        if ModifyUser then
            User.Modify();

        Commit();
        exit(ModifyUser or IsUserModified);
    end;

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

            GraphUserExists := GetGraphUser(UserSecurityId, GraphUserLocal);

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
    local procedure InitializeGraphUser(UserSecurityID: Guid)
    var
        UserObjectID: Text;
    begin
        Clear(GraphUser);

        if UserSecurityID = UserSecurityId() then begin
            AzureADGraph.GetCurrentUser(GraphUser);
            if not IsNull(GraphUser) then
                exit;
        end;

        UserObjectID := GetUserAuthenticationObjectId(UserSecurityID);
        if UserObjectID = '' then
            Error(CouldNotFindGraphUserErr, UserObjectID);

        AzureADGraph.GetUserByObjectId(UserObjectID, GraphUser);
        if IsNull(GraphUser) then
            Error(CouldNotFindGraphUserErr, UserObjectID);
    end;

    local procedure GetUserFullName(UserSecurityID: Guid): Text
    var
        FullUserName: Text;
    begin
        if IsNull(GraphUser) then
            exit;

        FullUserName := Format(GraphUser.GivenName());
        if Format(GraphUser.Surname()) <> '' then
            FullUserName := FullUserName + ' ';
        FullUserName := FullUserName + Format(GraphUser.Surname());
        exit(FullUserName);
    end;

    local procedure CheckUpdateUserRequired(var User: Record User; var GraphUser: DotNet UserInfo): Boolean
    var
        TempString: Text;
    begin
        if not User.Get(User."User Security ID") then
            exit(false);

        if GraphUser.AccountEnabled() and (User.State = User.State::Disabled) then
            exit(true);

        if (not GraphUser.AccountEnabled()) and (User.State = User.State::Enabled) then
            exit(true);

        TempString := CopyStr(GetUserFullName(User."User Security ID"), 1, MaxStrLen(User."Full Name"));
        if LowerCase(User."Full Name") <> LowerCase(TempString) then
            exit(true);

        if not IsNull(GraphUser.Mail()) then begin
            TempString := CopyStr(Format(GraphUser.Mail()), 1, MaxStrLen(User."Contact Email"));
            if LowerCase(User."Contact Email") <> LowerCase(TempString) then
                exit(true);
        end;

        TempString := CopyStr(Format(GraphUser.UserPrincipalName()), 1, MaxStrLen(User."Authentication Email"));
        if LowerCase(User."Authentication Email") <> LowerCase(TempString) then
            exit(true);

        exit(false);
    end;

    local procedure UpdateAuthenticationEmail(var User: Record User; var GraphUser: DotNet UserInfo)
    var
        NavUserAuthenticationHelper: DotNet NavUserAccountHelper;
    begin
        if IsNull(GraphUser) then
            exit;

        User."Authentication Email" := CopyStr(Format(GraphUser.UserPrincipalName()), 1, MaxStrLen(User."Authentication Email"));
        if User.Modify() then
            NavUserAuthenticationHelper.SetAuthenticationObjectId(User."User Security ID", GraphUser.ObjectId());
    end;

    local procedure SetUserLanguage(PreferredLanguage: Text)
    var
        UserPersonalization: Record "User Personalization";
        LanguageManagement: Codeunit Language;
        LanguageCode: Code[10];
        LanguageId: Integer;
        NonDefaultLanguageId: Integer;
    begin
        LanguageId := LanguageManagement.GetDefaultApplicationLanguageId();

        // We will use default application language if the PreferredLanguage is blank or en-us
        // (i.e. don't spend time trying to lookup the code)
        if not (LowerCase(PreferredLanguage) in ['', 'en-us']) then
            if TryGetLanguageCode(PreferredLanguage, LanguageCode) then;

        // If we support the language, get the language id
        // If we don't, we keep the current value (default application language)
        NonDefaultLanguageId := LanguageManagement.GetLanguageId(LanguageCode);
        if NonDefaultLanguageId <> 0 then
            LanguageId := NonDefaultLanguageId;

        if not UserPersonalization.Get(UserSecurityId()) then
            exit;

        // Only lock the table if there is a change
        if UserPersonalization."Language ID" = LanguageId then
            exit; // No changes required

        UserPersonalization.LockTable();
        UserPersonalization.Get(UserSecurityId());
        UserPersonalization.Validate("Language ID", LanguageId);
        UserPersonalization.Validate("Locale ID", LanguageId);
        UserPersonalization.Modify(true);
    end;

    [TryFunction]
    local procedure TryGetLanguageCode(CultureName: Text; var CultureCode: Code[10])
    var
        CultureInfo: DotNet CultureInfo;
    begin
        CultureInfo := CultureInfo.CultureInfo(CultureName);
        CultureCode := CultureInfo.ThreeLetterWindowsLanguageName();
    end;

    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADGraph.SetTestInProgress(TestInProgress);
    end;
}

