// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to retrieve and update Azure AD users.
/// </summary>
codeunit 9024 "Azure AD Graph User"
{
    Access = Public;

    trigger OnRun()
    begin
    end;

    var
        AzureADGraphUserImpl: Codeunit "Azure AD Graph User Impl.";

    /// <summary>    
    /// Gets the Azure AD user with the given security ID.
    /// </summary>
    /// <param name="UserSecurityId">The user's security ID.</param>
    /// <param name="User">The Azure AD user.</param>
    [Scope('OnPrem')]
    [TryFunction]
    procedure GetGraphUser(UserSecurityId: Guid; var User: DotNet UserInfo)
    begin
        AzureADGraphUserImpl.GetGraphUser(UserSecurityId, User);
    end;

    /// <summary>
    /// Retrieves the user’s unique identifier, which is its object ID, from Azure AD.
    /// </summary>
    /// <param name="UserSecurityId">The user's security ID.</param>
    /// <returns>
    /// The object ID of the Azure AD user, or an empty string if the user cannot be found.
    /// </returns>
    [Scope('OnPrem')]
    procedure GetObjectId(UserSecurityId: Guid): Text
    begin
        exit(AzureADGraphUserImpl.GetObjectId(UserSecurityId));
    end;

    /// <summary>    
    /// Gets the user's authentication object ID.
    /// </summary>
    /// <param name="UserSecurityId">The user's security ID.</param>
    /// <returns>The user's authentication object ID.</returns>
    [Scope('OnPrem')]
    procedure GetUserAuthenticationObjectId(UserSecurityId: Guid): Text
    begin
        exit(AzureADGraphUserImpl.GetUserAuthenticationObjectId(UserSecurityId));
    end;

    /// <summary>    
    /// Updates the user record with information from Azure AD.
    /// </summary>
    /// <param name="User">The user record to update.</param>
    /// <param name="AzureADUser">The Azure AD user.</param>
    /// <returns>True if the user record has been updated. Otherwise, false.</returns>
    [Scope('OnPrem')]
    procedure UpdateUserFromAzureGraph(var User: Record User; var AzureADUser: DotNet UserInfo): Boolean
    begin
        exit(AzureADGraphUserImpl.UpdateUserFromAzureGraph(User, AzureADUser));
    end;

    /// <summary>    
    /// Ensures that an email address specified for authorization is not already in use by another database user.
    /// If it is, all the database users with this authentication email address are updated and their email 
    /// addresses are updated the ones that are specified in Azure AD.
    /// </summary>
    /// <param name="AuthenticationEmail">The authentication email address.</param>
    [Scope('OnPrem')]
    procedure EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail: Text)
    begin
        AzureADGraphUserImpl.EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail);
    end;

    /// <summary>
    /// Sets a flag that is used to determine whether a test is in progress or not.
    /// </summary>
    [Scope('OnPrem')]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADGraphUserImpl.SetTestInProgress(TestInProgress);
    end;
}