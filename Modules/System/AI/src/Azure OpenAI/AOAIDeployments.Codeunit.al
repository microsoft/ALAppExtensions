// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// This codeunit is used to get the AOAI deployment names.
/// </summary>
codeunit 7768 "AOAI Deployments"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AOAIDeploymentsImpl: Codeunit "AOAI Deployments Impl";

    /// <summary>
    /// Returns the name of the AOAI deployment model Turbo 0301.
    /// </summary>
    /// <returns>The deployment name.</returns>
    [NonDebuggable]
    procedure GetTurbo0301(): Text
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AOAIDeploymentsImpl.GetTurbo0301(CallerModuleInfo));
    end;

    /// <summary>
    /// Returns the name of the AOAI deployment model GPT4 0613.
    /// </summary>
    /// <returns>The deployment name.</returns>
    [NonDebuggable]
    procedure GetGPT40613(): Text
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AOAIDeploymentsImpl.GetGPT40613(CallerModuleInfo));
    end;

    /// <summary>
    /// Returns the name of the AOAI deployment model Turbo 0613.
    /// </summary>
    /// <returns>The deployment name.</returns>
    [NonDebuggable]
    procedure GetTurbo0613(): Text
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AOAIDeploymentsImpl.GetTurbo0613(CallerModuleInfo));
    end;
}