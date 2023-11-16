// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.TestLibraries.AI;

using System.AI;

codeunit 132934 "Copilot Settings Test Library"
{
    Permissions = tabledata "Copilot Settings" = rimd;

    var
        CopilotSettings: Record "Copilot Settings";

    procedure FindFirst(): Boolean
    begin
        exit(CopilotSettings.FindFirst());
    end;

    procedure GetCapability(): Enum "Copilot Capability"
    begin
        exit(CopilotSettings."Capability");
    end;

    procedure GetAppId(): Guid
    begin
        exit(CopilotSettings."App ID");
    end;

    procedure GetAvailability(): Enum "Copilot Availability"
    begin
        exit(CopilotSettings."Availability");
    end;

    procedure GetStatus(): Enum "Copilot Status"
    begin
        exit(CopilotSettings."Status");
    end;

    procedure GetLearnMoreUrl(): Text
    begin
        exit(CopilotSettings."Learn More URL");
    end;

    procedure IsEmpty(): Boolean
    begin
        exit(CopilotSettings.IsEmpty());
    end;

    procedure Reset()
    begin
        CopilotSettings.Reset();
    end;

    procedure DeleteAll()
    begin
        CopilotSettings.DeleteAll();
    end;
}