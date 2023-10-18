// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Azure.ActiveDirectory;

using System.Azure.Identity;
using System.Security.AccessControl;
using System;

codeunit 132914 "Azure AD User Mgt Test Library"
{
    EventSubscriberInstance = Manual;

    var
        IsUserAdmin: Boolean;
        InvalidObjectIDErr: Label 'Invalid user object is provided';

    /// <summary>
    /// Calls the Run function of the Azure AD User Mgmt. Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="ForUserSecurityId">The user security ID that the function is run for.</param>
    procedure Run(ForUserSecurityId: Guid)
    var
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";
    begin
        AzureADUserMgmtImpl.Run(ForUserSecurityId);
    end;

    /// <summary>
    /// Mocks the behavior of IsUserTenantAdmin.
    /// </summary>
    /// <param name="Value">The value to set.</param>
    procedure SetIsUserTenantAdmin("Value": Boolean)
    begin
        IsUserAdmin := "Value";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD User Mgmt. Impl.", 'OnIsUserTenantAdmin', '', false, false)]
    local procedure OverrideIsUserTenantAdmin(var IsUserTenantAdmin: Boolean; var Handled: Boolean)
    begin
        IsUserTenantAdmin := IsUserAdmin;
        Handled := true;
    end;

    // Partially replicate platform behavior for creating users (function UserManagement.CreateUserFromAzureADObjectId), but with the possibility of using MockGraphQuery.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD User Mgmt. Impl.", 'OnBeforeCreateUserFromAzureADObjectId', '', false, false)]
    local procedure OnBeforeCreateUserFromAzureADObjectId(AADObjectID: Text; var NewUserSecurityId: Guid; var Handled: Boolean);
    var
        UserProperty: Record "User Property";
        AzureADGraph: Codeunit "Azure AD Graph";
        UserInfo: DotNet UserInfo;
    begin
        Handled := true;

        AzureADGraph.GetUserByObjectId(AADObjectID, UserInfo);
        if (IsNull(UserInfo)) then
            Error(InvalidObjectIDErr);

        UserProperty.SetRange("Authentication Object ID", AADObjectID);
        if not UserProperty.IsEmpty() then
            exit;

        NewUserSecurityId := CreateUser(UserInfo);
    end;

    procedure CreateUser(UserInfo: DotNet UserInfo): Guid
    var
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        NewUserSecurityId: Guid;
    begin
        NewUserSecurityId := InsertUser(UserInfo);
        NavUserAccountHelper.SetAuthenticationObjectId(NewUserSecurityId, UserInfo.ObjectId);
        exit(NewUserSecurityId)
    end;

    local procedure InsertUser(UserInfo: DotNet UserInfo): Guid
    var
        User: Record User;
    begin
        User."User Security ID" := CreateGuid();
        User.State := User.State::Enabled;
        User."Authentication Email" := UserInfo.UserPrincipalName;
        User."User Name" := GetUserName(UserInfo);
        User."Full Name" := GetFullName(UserInfo);
        User."Contact Email" := UserInfo.Mail;
        User."License Type" := User."License Type"::"Full User";
        User.Insert();

        exit(User."User Security ID");
    end;

    local procedure GetUserName(UserInfo: DotNet UserInfo): Text[50]
    var
        DesiredUserName: Text;
        PreferredUserName: Text;
    begin
        DesiredUserName := UserInfo.UserPrincipalName;
        if (not DesiredUserName.Contains('@')) then begin
            PreferredUserName := UserInfo.Mail;
            if PreferredUserName = '' then
                PreferredUserName := GetFullName(UserInfo);
            if PreferredUserName <> '' then
                DesiredUserName := PreferredUserName;
        end;

        DesiredUserName := DesiredUserName.Split('@').Get(1).Trim();
        exit(CopyStr(DesiredUserName, 1, 50));
    end;

    local procedure GetFullName(UserInfo: DotNet UserInfo): Text[80]
    begin
        exit(CopyStr(UserInfo.DisplayName, 1, 80));
    end;
}

