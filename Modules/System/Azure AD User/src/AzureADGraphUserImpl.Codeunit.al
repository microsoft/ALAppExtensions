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

    procedure GetGraphUser(var GraphUserOut: DotNet UserInfo)
    begin
        GraphUserOut := GraphUser;
    end;

    procedure SetGraphUser(GraphUserParam: DotNet UserInfo)
    begin
        GraphUser := GraphUserParam;
    end;

    [TryFunction]
    procedure SetGraphUser(UserSecurityID: Guid)
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

    procedure IsGraphUserNull(): Boolean
    begin
        exit(IsNull(GraphUser));
    end;

    procedure GetObjectId(): Text
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.ObjectId());
    end;

    procedure IsAccountDisabled(): Boolean
    begin
        if IsGraphUserNull() then
            exit;

        exit(not GraphUser.AccountEnabled());
    end;

    procedure IsAccountEnabled(): Boolean
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.AccountEnabled());
    end;

    procedure GetSurname(): Text
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.Surname());
    end;

    procedure GetDisplayName(): Text
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.DisplayName());
    end;

    procedure GetEmail(): Text
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.Mail());
    end;

    procedure GetUserPrincipalName(): Text
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.UserPrincipalName());
    end;

    procedure GetGivenName(): Text
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.GivenName());
    end;

    procedure GetPreferredLanguage(): Text
    begin
        if IsGraphUserNull() then
            exit;

        exit(GraphUser.PreferredLanguage());
    end;

    procedure GetUserFullName(): Text
    var
        FullUserName: Text;
    begin
        if IsGraphUserNull() then
            exit;

        FullUserName := GetGivenName();
        if GetSurname() <> '' then
            FullUserName := FullUserName + ' ';
        FullUserName := FullUserName + GetSurname();
        exit(FullUserName);
    end;

    procedure GetUserAuthenticationObjectId(UserSecurityId: Guid): Text
    var
        UserProperty: Record "User Property";
    begin
        if not UserProperty.Get(UserSecurityId) then
            Error(UserDoesNotObjectIdSetErr, UserSecurityId);

        exit(UserProperty."Authentication Object ID");
    end;

    procedure UpdateUserFromAzureGraph(var User: Record User): Boolean
    var
        ModifyUser: Boolean;
        IsUserModified: Boolean;
        TempString: Text;
    begin
        if IsGraphUserNull() then
            exit;

        if not CheckUpdateUserRequired(User) then
            exit;

        User.LockTable();
        if not User.Get(User."User Security ID") then begin
            Commit();
            exit;
        end;

        if IsAccountEnabled() and (User.State = User.State::Disabled) then begin
            User.State := User.State::Enabled;
            ModifyUser := true;
        end;

        if IsAccountDisabled() and (User.State = User.State::Enabled) then begin
            User.State := User.State::Disabled;
            ModifyUser := true;
        end;

        TempString := CopyStr(GetUserFullName(), 1, MaxStrLen(User."Full Name"));
        if LowerCase(User."Full Name") <> LowerCase(TempString) then begin
            User."Full Name" := CopyStr(TempString, 1, MaxStrLen(User."Full Name"));
            ModifyUser := true;
        end;

        TempString := CopyStr(GetEmail(), 1, MaxStrLen(User."Contact Email"));
        if LowerCase(User."Contact Email") <> LowerCase(TempString) then begin
            User."Contact Email" := CopyStr(TempString, 1, MaxStrLen(User."Contact Email"));
            ModifyUser := true;
        end;

        TempString := CopyStr(GetUserPrincipalName(), 1, MaxStrLen(User."Authentication Email"));
        if LowerCase(User."Authentication Email") <> LowerCase(TempString) then begin
            // Clear current authentication mail
            User."Authentication Email" := '';
            User.Modify();
            IsUserModified := true;

            EnsureAuthenticationEmailIsNotInUse(TempString);
            UpdateAuthenticationEmail(User);
        end;

        if IsUserModified then
            User.Modify();

        Commit();
        exit(ModifyUser or IsUserModified);
    end;

    local procedure CheckUpdateUserRequired(var User: Record User): Boolean
    var
        TempString: Text;
    begin
        if IsGraphUserNull() then
            exit;

        if not User.Get(User."User Security ID") then
            exit(false);

        if IsAccountEnabled() and (User.State = User.State::Disabled) then
            exit(true);

        if IsAccountDisabled() and (User.State = User.State::Enabled) then
            exit(true);

        TempString := CopyStr(GetUserFullName(), 1, MaxStrLen(User."Full Name"));
        if LowerCase(User."Full Name") <> LowerCase(TempString) then
            exit(true);

        TempString := CopyStr(GetEmail(), 1, MaxStrLen(User."Contact Email"));
        if LowerCase(User."Contact Email") <> LowerCase(TempString) then
            exit(true);

        TempString := CopyStr(GetUserPrincipalName(), 1, MaxStrLen(User."Authentication Email"));
        if LowerCase(User."Authentication Email") <> LowerCase(TempString) then
            exit(true);

        exit(false);
    end;

    procedure EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail: Text)
    var
        User: Record User;
        ModifiedUser: Record User;
        UserSecurityId: Guid;
    begin
        if IsGraphUserNull() then
            exit;

        // Clear all duplicate authentication email.
        User.SetRange("Authentication Email", CopyStr(AuthenticationEmail, 1, MaxStrLen(User."Authentication Email")));
        if not User.FindSet() then
            exit;
        repeat
            UserSecurityId := User."User Security ID";
            // Modifying the user authentication email breaks the connection to AD by clearing the Authentication Object Id
            User."Authentication Email" := '';
            User.Modify();

            // Cascade changes to authentication email, terminates at the first time an authentication email is not found.
            if SetGraphUser(UserSecurityId) then begin
                EnsureAuthenticationEmailIsNotInUse(GetUserPrincipalName());
                if ModifiedUser.Get(UserSecurityId) then
                    UpdateAuthenticationEmail(ModifiedUser);
            end;
        until User.Next() <> 0;
    end;

    local procedure UpdateAuthenticationEmail(var User: Record User)
    var
        NavUserAuthenticationHelper: DotNet NavUserAccountHelper;
    begin
        if IsGraphUserNull() then
            exit;

        User."Authentication Email" := CopyStr(GetUserPrincipalName(), 1, MaxStrLen(User."Authentication Email"));
        User.Modify();
        NavUserAuthenticationHelper.SetAuthenticationObjectId(User."User Security ID", GetObjectId());
    end;

    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADGraph.SetTestInProgress(TestInProgress);
    end;
}

