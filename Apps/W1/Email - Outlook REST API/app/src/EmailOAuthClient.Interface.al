// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

interface "Email - OAuth Client"
{
    /// <summary>
    /// Retrieves the Access token for the current user to connect to Outlook API.
    /// </summary>
    /// <param name="AccessToken">Out parameter with the Access token of the account.</param>
    /// <error>Could not get access token.</error>
    procedure GetAccessToken(var AccessToken: Text);

    /// <summary>
    /// Retrieves the Access token for the current user to connect to Outlook API.
    /// </summary>
    /// <param name="AccessToken">Out parameter with the Access token of the account.</param>
    /// <returns>True, if the access token was acquired successfully, false otherwise.</returns>
    procedure TryGetAccessToken(var AccessToken: Text): Boolean;
}