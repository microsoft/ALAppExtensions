// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to raise a confirm dialog with a question that is to be asked to the user.
/// </summary>
codeunit 27 "Confirm Management"
{
    Access = Public;
    SingleInstance = true;

    var
        ConfirmManagementImpl: Codeunit "Confirm Management Impl.";

    /// <summary>
    /// Raises a confirm dialog with a question and the default response on which the cursor is shown.
    /// If UI is not allowed, the default response is returned.
    /// </summary>
    /// <param name="ConfirmQuestion">The question to be asked to the user.</param>
    /// <param name="DefaultButton">The default response expected.</param>
    /// <returns>The response of the user or the default response passed if no UI is allowed.</returns>
    procedure GetResponseOrDefault(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
    begin
        exit(ConfirmManagementImpl.GetResponseOrDefault(ConfirmQuestion, DefaultButton));
    end;

    /// <summary>
    /// Raises a confirm dialog with a question and the default response on which the cursor is shown.
    /// If UI is not allowed, the function returns FALSE.
    /// </summary>
    /// <param name="ConfirmQuestion">The question to be asked to the user.</param>
    /// <param name="DefaultButton">The default response expected.</param>
    /// <returns>The response of the user or FALSE if no UI is allowed.</returns>
    procedure GetResponse(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
    begin
        exit(ConfirmManagementImpl.GetResponse(ConfirmQuestion, DefaultButton));
    end;
}

