// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

codeunit 31441 "Application Area Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetBasicExperienceAppAreas', '', false, false)]
    local procedure SetCZOnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup")
    begin
        TempApplicationAreaSetup."Basic CZ" := true;
    end;
}
