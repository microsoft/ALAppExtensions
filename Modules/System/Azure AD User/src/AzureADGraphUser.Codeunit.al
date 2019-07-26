// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to query, get and set the Azure AD Graph User.
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
    /// Gets the Azure AD Graph API user for the codeunit.
    /// </summary>
    /// <param name="GraphUserOut">The codeunit's Azure AD Graph API user.</param>
    [Scope('OnPrem')]
    procedure GetGraphUser(var GraphUserOut: DotNet UserInfo)
    begin
        AzureADGraphUserImpl.GetGraphUser(GraphUserOut);
    end;

    /// <summary>    
    /// Sets the .NET user for the codeunit, so that it can query the Azure AD Graph API.
    /// </summary>
    /// <param name="GraphUser">The .NET variable that will become the codeunit’s user for the Azure AD Graph API.</param>
    [Scope('OnPrem')]
    procedure SetGraphUser(var GraphUser: DotNet UserInfo)
    begin
        AzureADGraphUserImpl.SetGraphUser(GraphUser);
    end;

    /// <summary>
    /// Sets the .NET user for the codeunit, so that it can query the Azure AD Graph API.
    /// </summary>
    /// <param name="UserSecurityID">The security ID of the user.</param>
    [Scope('OnPrem')]
    [TryFunction]
    procedure SetGraphUser(UserSecurityID: Guid)
    begin
        AzureADGraphUserImpl.SetGraphUser(UserSecurityID);
    end;

    /// <summary>
    /// Checks whether the user for the Azure AD Graph API is set to null in the codeunit.
    /// </summary>
    /// <returns>True if the user for the Azure AD Graph API is set to null in the codeunit. Otherwise, false.</returns>
    [Scope('OnPrem')]
    procedure IsGraphUserNull(): Boolean
    begin
        exit(AzureADGraphUserImpl.IsGraphUserNull());
    end;

    /// <summary>
    /// Retrieves the user’s unique identifier, which is its object ID, from Azure AD.
    /// </summary>
    /// <returns>
    /// The object ID of the user for the Azure AD Graph API that is stored in the codeunit, or an empty string if the user is set to null.
    /// </returns>
    [Scope('OnPrem')]
    procedure GetObjectId(): Text
    begin
        exit(AzureADGraphUserImpl.GetObjectId());
    end;

    /// <summary>    
    /// Checks whether the user account for the Azure AD Graph API is disabled.
    /// </summary>
    /// <returns>True if user account for the Azure AD Graph API is disabled. Otherwise, false.</returns>
    [Scope('OnPrem')]
    procedure IsAccountDisabled(): Boolean
    begin
        exit(AzureADGraphUserImpl.IsAccountDisabled());
    end;

    /// <summary>    
    /// Checks whether the user account for the Azure AD Graph API is enabled.
    /// </summary>
    /// <returns>True if the user account for the Azure AD Graph API is enabled. Otherwise, false.</returns>
    [Scope('OnPrem')]
    procedure IsAccountEnabled(): Boolean
    begin
        exit(AzureADGraphUserImpl.IsAccountEnabled());
    end;

    /// <summary>    
    /// Gets the surname of the user for the Azure AD Graph API.
    /// </summary>
    /// <returns>The user’s surname or an empty string if the user is set to null.</returns>
    [Scope('OnPrem')]
    procedure GetSurname(): Text
    begin
        exit(AzureADGraphUserImpl.GetSurname());
    end;

    /// <summary>    
    /// Gets the display name of the user for the Azure AD Graph API.
    /// </summary>
    /// <returns>The user's display name or an empty string if the user is set to null.</returns>
    [Scope('OnPrem')]
    procedure GetDisplayName(): Text
    begin
        exit(AzureADGraphUserImpl.GetDisplayName());
    end;

    /// <summary>    
    /// Gets the email address of the user for the Azure AD Graph API.
    /// </summary>
    /// <returns>The user's email address or an empty string if the user is set to null.</returns>
    [Scope('OnPrem')]
    procedure GetEmail(): Text
    begin
        exit(AzureADGraphUserImpl.GetEmail());
    end;

    /// <summary>    
    /// Gets the user principal name of the user for the Azure AD Graph API.
    /// </summary>
    /// <returns>The user principal name of the user or an empty string if the user is set to null.</returns>
    [Scope('OnPrem')]
    procedure GetUserPrincipalName(): Text
    begin
        exit(AzureADGraphUserImpl.GetUserPrincipalName());
    end;

    /// <summary>    
    /// Gets the given name of the user for the Azure AD Graph API.
    /// </summary>
    /// <returns>The user's given name or an empty string if the user is set to null.</returns>
    [Scope('OnPrem')]
    procedure GetGivenName(): Text
    begin
        exit(AzureADGraphUserImpl.GetGivenName());
    end;

    /// <summary>    
    /// Gets the preferred language of the user for the Azure AD Graph API.
    /// </summary>
    /// <returns>The user's preferred language or an empty string if the user is set to null.</returns>
    [Scope('OnPrem')]
    procedure GetPreferredLanguage(): Text
    begin
        exit(AzureADGraphUserImpl.GetPreferredLanguage());
    end;

    /// <summary>    
    /// Gets the full name of the user for the Azure AD Graph API.
    /// </summary>
    /// <returns>The user's full name or an empty string if the user is set to null.</returns>
    [Scope('OnPrem')]
    procedure GetUserFullName(): Text
    begin
        exit(AzureADGraphUserImpl.GetUserFullName());
    end;

    /// <summary>    
    /// Updates the user record with information from the Azure AD Graph API.
    /// </summary>
    /// <param name="User">The user record to update.</param>
    /// <returns>True if the user record has been updated. Otherwise, false.</returns>
    [Scope('OnPrem')]
    procedure UpdateUserFromAzureGraph(var User: Record User): Boolean
    begin
        exit(AzureADGraphUserImpl.UpdateUserFromAzureGraph(User));
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
    /// Ensures that an email address specified for authorization is not already in use by another user object.
    /// If it is, the user’s authentication email address is updated to the email address that is specified in the Azure AD Graph API.
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

