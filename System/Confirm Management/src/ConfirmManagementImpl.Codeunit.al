// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 26 "Confirm Management Impl."
{
    Access = Internal;
    SingleInstance = true;

    procedure GetResponseOrDefault(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
    begin
        if not IsGuiAllowed() then
            exit(DefaultButton);
        exit(Confirm(ConfirmQuestion, DefaultButton));
    end;

    procedure GetResponse(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
    begin
        if not IsGuiAllowed() then
            exit(false);
        exit(Confirm(ConfirmQuestion, DefaultButton));
    end;

    local procedure IsGuiAllowed() GuiIsAllowed: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeGuiAllowed(GuiIsAllowed, Handled);
        if Handled then
            exit;
        exit(GuiAllowed());
    end;

    /// <summary>
    /// Raises an event to be able to change the return of IsGuiAllowed function. Used for testing.
    /// </summary>
    [InternalEvent(false)]
    procedure OnBeforeGuiAllowed(var Result: Boolean; var Handled: Boolean)
    begin
    end;
}

