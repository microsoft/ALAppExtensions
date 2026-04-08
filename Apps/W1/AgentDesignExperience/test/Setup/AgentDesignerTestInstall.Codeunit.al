// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer;

using System.AI;
using System.TestLibraries.AI;

codeunit 133750 "Agent Designer Test Install"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    var
        LibraryCopilotCapability: Codeunit "Library - Copilot Capability";
    begin
        LibraryCopilotCapability.ActivateCopilotCapability(Enum::"Copilot Capability"::"Custom Agent", '00155c68-8cdd-4d60-a451-2034ad094223');
    end;
}