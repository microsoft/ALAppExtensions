// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides basic functionality to open a search page and validate user information. 
/// </summary>
codeunit 9843 "User Selection"
{
    Access = Public;

    /// <summary>
    /// Opens the user lookup page and assigns the selected users on the <paramref name="SelectedUser"/> parameter.
    /// </summary>
    /// <param name="SelectedUser">The variable to return the selected users. Any filters on this record will influence the page view.</param>
    /// <returns>Returns true if a user was selected.</returns>
    procedure Open(var SelectedUser: Record User): Boolean
    var
        UserSelectionImpl: Codeunit "User Selection Impl.";
    begin
        exit(UserSelectionImpl.Open(SelectedUser));
    end;

    /// <summary>
    /// Displays an error if there is no user with the given username and the user table is not empty.
    /// </summary>
    /// <param name="UserName">The username to validate.</param>
    procedure ValidateUserName(UserName: Code[50])
    var
        UserSelectionImpl: Codeunit "User Selection Impl.";
    begin
        UserSelectionImpl.ValidateUserName(UserName);
    end;

    /// <summary>
    /// Sets Filter on the given User Record to exclude external users.
    /// </summary>
    /// <param name="User">The User Record to return.</param>
    procedure HideExternalUsers(var User: Record User)
    var
        UserSelectionImpl: Codeunit "User Selection Impl.";
    begin
        UserSelectionImpl.HideExternalUsers(User);
    end;
}

