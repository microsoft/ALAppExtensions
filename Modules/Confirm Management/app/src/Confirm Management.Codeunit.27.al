// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 27 "Confirm Management"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        ConfirmManagementImpl: Codeunit "Confirm Management Impl.";

    procedure GetResponseOrDefault(ConfirmQuestion: Text;DefaultButton: Boolean): Boolean
    begin
        // <summary>
        // Raises a confirm dialog with a question and the default response on which the cursor is shown.
        // If UI is not allowed, the default response is returned.
        // </summary>
        // <param name="ConfirmQuestion">The question to be asked to the user.</param>
        // <param name="DefaultButton">The default response expected.</param>
        // <returns>The response of the user or the default response passed if no UI is allowed.</returns>
        exit(ConfirmManagementImpl.GetResponseOrDefault(ConfirmQuestion,DefaultButton));
    end;

    procedure GetResponse(ConfirmQuestion: Text;DefaultButton: Boolean): Boolean
    begin
        // <summary>
        // Raises a confirm dialog with a question and the default response on which the cursor is shown.
        // If UI is not allowed, the function returns FALSE.
        // <summary>
        // <param name="ConfirmQuestion">The question to be asked to the user.</param>
        // <param name="DefaultButton">The default response expected.</param>
        // <returns>The response of the user or FALSE if no UI is allowed.</returns>
        exit(ConfirmManagementImpl.GetResponse(ConfirmQuestion,DefaultButton));
    end;

    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    procedure OnBeforeGuiAllowed(var Result: Boolean;var Handled: Boolean)
    begin
        // <summary>
        // Raises an event to be able to change the return of IsGuiAllowed function. Used for testing.
        // </summary>
    end;
}

