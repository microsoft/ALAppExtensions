// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.TestLibraries.AI;

using System.AI;

codeunit 132932 "Copilot Test Library"
{

    Permissions = tabledata "Copilot Settings" = rm;

    var
        CopilotCapability: Codeunit "Copilot Capability";

    procedure RegisterCopilotCapability(Capability: Enum "Copilot Capability")
    begin
        CopilotCapability.RegisterCapability(Capability, '');
    end;

    procedure RegisterCopilotCapability(Capability: Enum "Copilot Capability"; var CurrentModule: Guid)
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        CurrentModule := ModuleInfo.Id();

        CopilotCapability.RegisterCapability(Capability, '');
    end;

    procedure UnregisterCopilotCapability(Capability: Enum "Copilot Capability")
    begin
        CopilotCapability.UnregisterCapability(Capability);
    end;

    procedure SetCopilotStatus(Capability: Enum "Copilot Capability"; PackageId: Guid; Status: Enum "Copilot Status")
    var
        CopilotSettings: Record "Copilot Settings";
    begin
        CopilotSettings.Get(Capability, PackageId);
        CopilotSettings.Status := Status;
        CopilotSettings.Modify();
    end;

}