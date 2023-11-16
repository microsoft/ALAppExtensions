// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// The Copilot Capability codeunit is used to register, modify, and delete Copilot capabilities.
/// </summary>
codeunit 7773 "Copilot Capability"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CopilotCapabilityImpl: Codeunit "Copilot Capability Impl";

    /// <summary>
    /// Register a capability.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    /// <param name="LearnMoreUrl">The learn more url.</param>
    procedure RegisterCapability(CopilotCapability: Enum "Copilot Capability"; LearnMoreUrl: Text[2048])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        CopilotCapabilityImpl.RegisterCapability(CopilotCapability, LearnMoreUrl, CallerModuleInfo);
    end;

    /// <summary>
    /// Register a capability.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    /// <param name="CopilotAvailability">The availability.</param>
    /// <param name="LearnMoreUrl">The learn more url.</param>
    procedure RegisterCapability(CopilotCapability: Enum "Copilot Capability"; CopilotAvailability: Enum "Copilot Availability"; LearnMoreUrl: Text[2048])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        CopilotCapabilityImpl.RegisterCapability(CopilotCapability, CopilotAvailability, LearnMoreUrl, CallerModuleInfo);
    end;

    /// <summary>
    /// Modify an existing capability.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    /// <param name="CopilotAvailability">The availability.</param>
    /// <param name="LearnMoreUrl">The learn more url.</param>
    procedure ModifyCapability(CopilotCapability: Enum "Copilot Capability"; CopilotAvailability: Enum "Copilot Availability"; LearnMoreUrl: Text[2048])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        CopilotCapabilityImpl.ModifyCapability(CopilotCapability, CopilotAvailability, LearnMoreUrl, CallerModuleInfo);
    end;

    /// <summary>
    /// Unregister a capability.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    procedure UnregisterCapability(CopilotCapability: Enum "Copilot Capability")
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        CopilotCapabilityImpl.UnregisterCapability(CopilotCapability, CallerModuleInfo);
    end;

    /// <summary>
    /// Check if your capability has been registered.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    /// <returns>True if the capability has been registered.</returns>
    /// <remarks>Capabilities are tied to the module registering it. Checking for a capability will check if the enum and app id of your module exists.</remarks>
    procedure IsCapabilityRegistered(CopilotCapability: Enum "Copilot Capability"): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(CopilotCapabilityImpl.IsCapabilityRegistered(CopilotCapability, CallerModuleInfo));
    end;

    /// <summary>
    /// Check if a specific capability has been registered.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    /// <param name="AppId">The app id associated with the capability.</param>
    /// <returns>True if the capability has been registered.</returns>
    /// <remarks>Capabilities are tied to the module registering it. Checking for a capability will check if the enum and app id of the module exists.</remarks>
    procedure IsCapabilityRegistered(CopilotCapability: Enum "Copilot Capability"; AppId: Guid): Boolean
    begin
        exit(CopilotCapabilityImpl.IsCapabilityRegistered(CopilotCapability, AppId));
    end;

    /// <summary>
    /// Check if your capability is active.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    /// <returns>True if the capability is active.</returns>
    procedure IsCapabilityActive(CopilotCapability: Enum "Copilot Capability"): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(CopilotCapabilityImpl.IsCapabilityActive(CopilotCapability, CallerModuleInfo));
    end;

    /// <summary>
    /// Check if the capability is active.
    /// </summary>
    /// <param name="CopilotCapability">The capability.</param>
    /// <param name="AppId">The app id associated with the capability.</param>
    /// <returns>True if the capability is active.</returns>
    procedure IsCapabilityActive(CopilotCapability: Enum "Copilot Capability"; AppId: Guid): Boolean
    begin
        exit(CopilotCapabilityImpl.IsCapabilityActive(CopilotCapability, AppId));
    end;
}