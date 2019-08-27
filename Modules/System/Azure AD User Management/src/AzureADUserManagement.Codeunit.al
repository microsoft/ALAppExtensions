// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to manage the Azure AD Graph API users.
/// </summary>
codeunit 9010 "Azure AD User Management"
{
    Access = Public;

    var
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Azure AD User Mgmt. Impl.");
    end;

    /// <summary>    
    /// Retrieves all the users from the Azure AD Graph API. If the users already exist in the database, 
    /// they are updated to match the ones from the API; otherwise new users are inserted in the database.
    /// </summary>
    [Scope('OnPrem')]
    procedure CreateNewUsersFromAzureAD()
    begin
        AzureADUserMgmtImpl.CreateNewUsersFromAzureAD();
    end;

    /// <summary>    
    /// Creates a new user from an Azure AD Graph API user.
    /// </summary>
    /// <param name="GraphUser">The Azure AD Graph API user.</param>
    [Scope('OnPrem')]
    procedure CreateNewUserFromGraphUser(GraphUser: DotNet UserInfo)
    begin
        AzureADUserMgmtImpl.CreateNewUserFromGraphUser(GraphUser);
    end;

    /// <summary>    
    /// Synchronizes a user with the Azure AD Graph API user corresponding to the authentication 
    /// email that is passed as a parameter. If the user record does not exist, it gets created.
    /// </summary>
    /// <param name="AuthenticationEmail">The user's authentication email.</param>
    /// <returns>True if there is a user in the Azure AD Graph API corresponding to the authentication email; otherwise false.</returns>
    procedure SynchronizeLicensedUserFromDirectory(AuthenticationEmail: Text): Boolean
    begin
        AzureADUserMgmtImpl.SynchronizeLicensedUserFromDirectory(AuthenticationEmail);
    end;

    /// <summary>    
    /// Synchronizes all the users from the database with the ones from the Azure AD Graph API. If 
    /// the users do not exist in the database, they get created.
    /// </summary>
    procedure SynchronizeAllLicensedUsersFromDirectory()
    begin
        AzureADUserMgmtImpl.SynchronizeAllLicensedUsersFromDirectory();
    end;

    /// <summary>    
    /// Checks if the user is a tenant admin.
    /// </summary>
    /// <returns>True if the user is a tenant admin; otherwise false.</returns>
    procedure IsUserTenantAdmin(): Boolean
    begin
        exit(AzureADUserMgmtImpl.IsUserTenantAdmin());
    end;

    /// <summary>
    /// Sets a flag that is used to determine whether a test is in progress or not.
    /// </summary>
    [Scope('OnPrem')]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADUserMgmtImpl.SetTestInProgress(TestInProgress);
    end;
}

