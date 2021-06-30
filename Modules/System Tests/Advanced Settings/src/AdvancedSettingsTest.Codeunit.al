// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132589 "Advanced Settings Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        AdvancedSettingsTest: Codeunit "Advanced Settings Test";

    [Test]
    procedure TestAdvancedSettingsShowsUpOnOpenRoleBasedSetupExperience()
    var
        SystemActionTriggers: Codeunit "System Action Triggers";
        PermissionsMock: Codeunit "Permissions Mock";
        AdvancedSettings: TestPage "Advanced Settings";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Adv. Settings View');

        // [GIVEN] Subscribers are not registered
        // [WHEN] System action OpenGeneralSetupExperience is triggered
        AdvancedSettings.Trap();
        SystemActionTriggers.OpenGeneralSetupExperience();

        // [THEN] Advanced settings is opened
        AdvancedSettings.Close();
    end;

    [Test]
    procedure TestAdvancedSettingsNotShownIfHandledOnBeforeOpenRoleBasedSetupExperience()
    var
        PermissionsMock: Codeunit "Permissions Mock";
        SystemActionTriggers: Codeunit "System Action Triggers";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Adv. Settings View');

        // [GIVEN] Subscribers are registered
        BindSubscription(AdvancedSettingsTest);

        // [WHEN] System action OpenGeneralSetupExperience is triggered
        SystemActionTriggers.OpenGeneralSetupExperience();

        // [THEN] Advanced settings is not opened
        UnbindSubscription(AdvancedSettingsTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Advanced Settings", 'OnBeforeOpenGeneralSetupExperience', '', true, true)]
    [Normal]
    local procedure OnBeforeOpenGeneralSetupExperience(var PageID: Integer; var Handled: Boolean)
    begin
        Handled := true;
    end;
}
