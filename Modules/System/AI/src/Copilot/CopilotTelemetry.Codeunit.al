// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

using System.Globalization;
using System.Telemetry;

codeunit 7775 "Copilot Telemetry"
{
    Access = Internal;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CopilotCapability: Enum "Copilot Capability";
        AppId: Guid;
        TelemetryFeedbackOnCopilotCapabilityLbl: Label 'Feedback on Copilot Capability.', Locked = true;
        TelemetryActionInvokedOnCopilotCapabilityLbl: Label 'Action invoked on Copilot Capability.', Locked = true;

    procedure SetCopilotCapability(NewCopilotCapability: Enum "Copilot Capability"; NewAppId: Guid)
    begin
        CopilotCapability := NewCopilotCapability;
        AppId := NewAppId;
    end;

    procedure SendCopilotFeedbackTelemetry(CustomDimensions: Dictionary of [Text, Text])
    var
        CopilotCapabilitiesImpl: Codeunit "Copilot Capability Impl";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Language: Codeunit Language;
        SavedGlobalLanguageId: Integer;
    begin
        CopilotCapabilitiesImpl.AddTelemetryDimensions(CopilotCapability, AppId, CustomDimensions);

        SavedGlobalLanguageId := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        FeatureTelemetry.LogUsage('0000LFO', CopilotCapabilitiesImpl.GetCopilotCategory(), TelemetryFeedbackOnCopilotCapabilityLbl, CustomDimensions);

        GlobalLanguage(SavedGlobalLanguageId);
    end;

    procedure SendCopilotActionInvokedTelemetry(CustomDimensions: Dictionary of [Text, Text])
    var
        CopilotCapabilitiesImpl: Codeunit "Copilot Capability Impl";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Language: Codeunit Language;
        SavedGlobalLanguageId: Integer;
    begin
        CopilotCapabilitiesImpl.AddTelemetryDimensions(CopilotCapability, AppId, CustomDimensions);

        SavedGlobalLanguageId := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        FeatureTelemetry.LogUsage('0000LLW', CopilotCapabilitiesImpl.GetCopilotCategory(), TelemetryActionInvokedOnCopilotCapabilityLbl, CustomDimensions);

        GlobalLanguage(SavedGlobalLanguageId);
    end;
}