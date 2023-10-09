// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Provides functionality to work with file scenarios.
/// </summary>
codeunit 70002 "File Scenario"
{
    /// <summary>
    /// Gets the default file account.
    /// </summary>
    /// <param name="FileAccount">Out parameter holding information about the default file account.</param>
    /// <returns>True if an account for the the default scenario was found; otherwise - false.</returns>
    procedure GetDefaultFileAccount(var FileAccount: Record "File Account"): Boolean
    begin
        exit(FileScenarioImpl.GetFileAccount(Enum::"File Scenario"::Default, FileAccount));
    end;

    /// <summary>
    /// Gets the file account used by the given file scenario.
    /// If the no account is defined for the provided scenario, the default account (if defined) will be returned.
    /// </summary>
    /// <param name="Scenario">The scenario to look for.</param>
    /// <param name="FileAccount">Out parameter holding information about the file account.</param>
    /// <returns>True if an account for the specified scenario was found; otherwise - false.</returns>
    procedure GetFileAccount(Scenario: Enum "File Scenario"; var FileAccount: Record "File Account"): Boolean
    begin
        exit(FileScenarioImpl.GetFileAccount(Scenario, FileAccount));
    end;

    /// <summary>
    /// Sets a default file account.
    /// </summary>
    /// <param name="FileAccount">The file account to use.</param>
    procedure SetDefaultFileAccount(FileAccount: Record "File Account")
    begin
        FileScenarioImpl.SetFileAccount(Enum::"File Scenario"::Default, FileAccount);
    end;

    /// <summary>
    /// Sets an file account to be used by the given file scenario.
    /// </summary>
    /// <param name="Scenario">The scenario for which to set an file account.</param>
    /// <param name="FileAccount">The file account to use.</param>
    procedure SetFileAccount(Scenario: Enum "File Scenario"; FileAccount: Record "File Account")
    begin
        FileScenarioImpl.SetFileAccount(Scenario, FileAccount);
    end;

    /// <summary>
    /// Unassign an file scenario. The scenario will then use the default file account.
    /// </summary>
    /// <param name="Scenario">The scenario to unassign.</param>
    procedure UnassignScenario(Scenario: Enum "File Scenario")
    begin
        FileScenarioImpl.UnassignScenario(Scenario);
    end;

    /// <summary>
    /// Event for changing whether an file scenario should be added to the list of assignable scenarios.
    /// If the scenario has already been assigned or is the default scenario, this event won't be published.
    /// </summary>
    /// <param name="Scenario">The scenario that is going to be added to the list of assignable scenarios.</param>
    /// <param name="IsAvailable">The return for whether this scenario should be listed in the assignable scenarios list.</param>
    [IntegrationEvent(false, false, true)]
    internal procedure OnBeforeInsertAvailableFileScenario(Scenario: Enum "File Scenario"; var IsAvailable: Boolean)
    begin
    end;

    var
        FileScenarioImpl: Codeunit "File Scenario Impl.";
}