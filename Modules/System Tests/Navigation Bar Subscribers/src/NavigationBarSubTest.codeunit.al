// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132598 "Navigation Bar Sub. Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;

    [Test]
    procedure TestAdvancedSettingsShowsUpOnOpenRoleBasedSetupExperience()
    var
        SystemActionTriggers: Codeunit "System Action Triggers";
        AdvancedSettings: TestPage "Advanced Settings";
    begin
        // [WHEN] system action OpenGeneralSetupExperience is triggered
        AdvancedSettings.Trap();
        SystemActionTriggers.OpenGeneralSetupExperience();

        // [THEN] Advanced settings is opened
        AdvancedSettings.Close();
    end;

    [Test]
    procedure TestAssistedSetupShowsUpOnOpenRoleBasedSetupExperience()
    var
        SystemActionTriggers: Codeunit "System Action Triggers";
        AssistedSetup: TestPage "Assisted Setup";
    begin
        // [WHEN] system action OpenRoleBasedSetupExperience is triggered
        AssistedSetup.Trap();
        SystemActionTriggers.OpenRoleBasedSetupExperience();

        // [THEN] Assisted setup is opened
        AssistedSetup.Close();
    end;
}
