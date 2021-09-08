//------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1817 "Advanced Settings Impl."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Navigation Bar Subscribers", 'OnBeforeDefaultOpenGeneralSetupExperience', '', false, false)]
    local procedure OpenGeneralSetupExperience(var Handled: Boolean)
    var
        AdvancedSettings: Codeunit "Advanced Settings";
        GeneralSetupID: Integer;
    begin
        GeneralSetupID := Page::"Advanced Settings";
        AdvancedSettings.OnBeforeOpenGeneralSetupExperience(GeneralSetupID, Handled);
        if not Handled then
            PAGE.Run(GeneralSetupID);
        Handled := true;
    end;
}