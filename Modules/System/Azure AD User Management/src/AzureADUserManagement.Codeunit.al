// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to manage Azure AD users.
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
    /// Retrieves all the users from Azure AD. If the users already exist in the database, 
    /// they are updated to match the ones from Azure AD; otherwise new users are inserted in the database.
    /// </summary>
    [Scope('OnPrem')]
    procedure CreateNewUsersFromAzureAD()
    begin
        AzureADUserMgmtImpl.CreateNewUsersFromAzureAD();
    end;

    /// <summary>    
    /// Creates a new user from an Azure AD user.
    /// </summary>
    /// <param name="GraphUser">The Azure AD user.</param>
    [Scope('OnPrem')]
    procedure CreateNewUserFromGraphUser(GraphUser: DotNet UserInfo)
    begin
        AzureADUserMgmtImpl.CreateNewUserFromGraphUser(GraphUser);
    end;

    /// <summary>
    /// Updates details about the user with information from Office 365.
    /// </summary>
    /// <param name="User">The user whose information will be updated.</param>
    [Scope('OnPrem')]
    procedure UpdateUserFromGraph(var User: Record User)
    begin
        AzureADUserMgmtImpl.UpdateUserFromGraph(User);
    end;

    /// <summary>    
    /// Synchronizes a user with the Azure AD user corresponding to the authentication 
    /// email that is passed as a parameter. If the user record does not exist, it gets created.
    /// </summary>
    /// <param name="AuthenticationEmail">The user's authentication email.</param>
    /// <returns>True if there is a user in Azure AD corresponding to the authentication email; otherwise false.</returns>
    procedure SynchronizeLicensedUserFromDirectory(AuthenticationEmail: Text): Boolean
    begin
        AzureADUserMgmtImpl.SynchronizeLicensedUserFromDirectory(AuthenticationEmail);
    end;

    /// <summary>    
    /// Synchronizes all the users from the database with the ones from Azure AD. If 
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
    /// <param name="TestInProgress">The value to be set to the flag.</param>
    [Scope('OnPrem')]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADUserMgmtImpl.SetTestInProgress(TestInProgress);
    end;
}

