// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132915 "Azure AD User Test Library"
{
    EventSubscriberInstance = Manual;

    /// <summary>
    /// Mocks the behavior of IsUserDelegatedAdmin.
    /// </summary>
    /// <param name="Value">The value to set.</param>
    procedure SetIsUserDelegatedtAdmin("Value": Boolean)
    begin
        IsUserAdmin := "Value";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Graph User Impl.", 'OnIsUserDelegatedAdmin', '', false, false)]
    local procedure OverrideIsUserTenantAdmin(var IsUserDelegatedAdmin: Boolean; var Handled: Boolean)
    begin
        IsUserDelegatedAdmin := IsUserAdmin;
        Handled := true;
    end;

    var
        IsUserAdmin: Boolean;

}