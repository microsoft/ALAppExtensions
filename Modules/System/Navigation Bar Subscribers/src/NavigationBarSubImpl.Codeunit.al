// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1818 "Navigation Bar Sub. Impl."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OpenCompanySettings', '', false, false)]
    local procedure DefaultOpenCompanySettings()
    var
        NavigationBarSubscribers: Codeunit "Navigation Bar Subscribers";
        Handled: Boolean;
    begin
        NavigationBarSubscribers.OnBeforeDefaultOpenCompanySettings(Handled);
        if not Handled then
            Error(SettingsNotAvailableErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OpenRoleBasedSetupExperience', '', false, false)]
    local procedure DefaultOpenRoleBasedSetupExperience()
    var
        NavigationBarSubscribers: Codeunit "Navigation Bar Subscribers";
        Handled: Boolean;
    begin
        NavigationBarSubscribers.OnBeforeDefaultOpenRoleBasedSetupExperience(Handled);
        if not Handled then
            Error(SettingsNotAvailableErr);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OpenGeneralSetupExperience', '', false, false)]
    local procedure DefaultOpenGeneralSetupExperience()
    var
        NavigationBarSubscribers: Codeunit "Navigation Bar Subscribers";
        Handled: Boolean;
    begin
        NavigationBarSubscribers.OnBeforeDefaultOpenGeneralSetupExperience(Handled);
        if not Handled then
            Error(SettingsNotAvailableErr);
    end;

    var
        SettingsNotAvailableErr: Label 'There are currently no settings available for this choice.';
}