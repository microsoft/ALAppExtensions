// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Advanced settings exposes integration events raised at Advance Settings Page open.</summary>
codeunit 9202 "Advanced Settings"
{
    Access = Public;

    /// <summary>Notifies that the Open General Setup Experience has been invoked.</summary>
    /// <param name="PageID">The Page ID of the page been invoked.</param>
    /// <param name="Handled">The flag which if set, would stop executing the OpenGeneralSetupExperience of the assisted setup guide.</param> 
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenGeneralSetupExperience(var PageID: Integer; var Handled: Boolean)
    begin
    end;
}