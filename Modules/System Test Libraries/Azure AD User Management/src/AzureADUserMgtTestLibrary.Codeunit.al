// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132914 "Azure AD User Mgt Test Library"
{
    EventSubscriberInstance = Manual;

    /// <summary>
    /// Calls the Run function of the Azure AD User Mgmt. Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="ForUserSecurityId">The user security ID that the function is run for.</param>
    procedure Run(ForUserSecurityId: Guid)
    var
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";
    begin
        AzureADUserMgmtImpl.SetTestInProgress(true);
        AzureADUserMgmtImpl.Run(ForUserSecurityId);
    end;

    /// <summary>
    /// Mocks the behavior of IsUserTenantAdmin.
    /// </summary>
    /// <param name="Value">The value to set.</param>
    procedure SetIsUserTenantAdmin("Value": Boolean)
    begin
        IsUserAdmin := "Value";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD User Mgmt. Impl.", 'OnIsUserTenantAdmin', '', false, false)]
    local procedure OverrideIsUserTenantAdmin(var IsUserTenantAdmin: Boolean; var Handled: Boolean)
    begin
        IsUserTenantAdmin := IsUserAdmin;
        Handled := true;
    end;

    var
        IsUserAdmin: Boolean;

}