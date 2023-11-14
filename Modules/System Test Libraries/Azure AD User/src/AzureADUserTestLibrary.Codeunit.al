// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Azure.ActiveDirectory;

using System.Azure.Identity;

codeunit 132915 "Azure AD User Test Library"
{
    EventSubscriberInstance = Manual;

    /// <summary>
    /// Mocks the behavior of IsUserDelegatedAdmin.
    /// </summary>
    /// <param name="NewValue">The value to set.</param>
    procedure SetIsUserDelegatedAdmin(NewValue: Boolean)
    begin
        IsUserDelegatedAdminValue := NewValue;
    end;

    /// <summary>
    /// Mocks the behavior of IsUserDelegatedHelpdesk.
    /// </summary>
    /// <param name="NewValue">The value to set.</param>
    procedure SetIsUserDelegatedHelpdesk(NewValue: Boolean)
    begin
        IsUserDelegatedHelpdeskValue := NewValue;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Graph User Impl.", 'OnIsUserDelegatedAdmin', '', false, false)]
    local procedure OverrideIsUserDelegatedAdmin(var IsUserDelegatedAdmin: Boolean; var Handled: Boolean)
    begin
        IsUserDelegatedAdmin := IsUserDelegatedAdminValue;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Graph User Impl.", 'OnIsUserDelegatedHelpdesk', '', false, false)]
    local procedure OverrideIsUserDelegatedHelpdesk(var IsUserDelegatedHelpdesk: Boolean; var Handled: Boolean)
    begin
        IsUserDelegatedHelpdesk := IsUserDelegatedHelpdeskValue;
        Handled := true;
    end;

    var
        IsUserDelegatedAdminValue, IsUserDelegatedHelpdeskValue : Boolean;
}