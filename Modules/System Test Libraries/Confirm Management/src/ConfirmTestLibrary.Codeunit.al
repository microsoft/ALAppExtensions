// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132513 "Confirm Test Library"
{
    EventSubscriberInstance = Manual;

    var
        GuiAllowed: Boolean;

    /// <summary>
    /// Sets the value of GUI allowed. This value will be used to determine if the confirm dialog should be shown in 
    /// GetResponse and GetResponseOrDefault functions when the subscription is bound.
    /// Uses <see cref="OnBeforeGuiAllowed"/> event.
    /// </summary>
    /// <param name="IsGuiAllowed">The desired value of GUI allowed.</param>
    [Scope('OnPrem')]
    procedure SetGuiAllowed(IsGuiAllowed: Boolean)
    begin
        GuiAllowed := IsGuiAllowed;
    end;

    /// <summary>
    /// Overwrite the value of whether GUI is allowed or not.
    /// </summary>
    /// <param name="Result">Out parameter for whether GUI is allowed or not.</param>
    /// <param name="Handled">Out parameter that indicates whether or not the original value will be overwritten or not.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Confirm Management Impl.", 'OnBeforeGuiAllowed', '', false, false)]
    local procedure OnBeforeGuiAllowed(var Result: Boolean; var Handled: Boolean)
    begin
        Result := GuiAllowed;
        Handled := true;
    end;
}

