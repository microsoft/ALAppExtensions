// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Collection of the default subscribers to system events and corresponding overridable integration events.</summary>
codeunit 154 "Navigation Bar Subscribers"
{
    Access = Public;

    /// <summary>Notifies that the Default Open Company Settings has been invoked.</summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param> 
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDefaultOpenCompanySettings(var Handled: Boolean)
    begin
    end;

    /// <summary>Notifies that the Default Open Role Based Setup Experience has been invoked.</summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param> 
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDefaultOpenRoleBasedSetupExperience(var Handled: Boolean)
    begin
    end;

    /// <summary>Notifies that the Default Open General Setup Experience has been invoked.</summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param> 
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDefaultOpenGeneralSetupExperience(var Handled: Boolean)
    begin
    end;
}