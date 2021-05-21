// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to work with email scenarios.
/// </summary>
codeunit 8893 "Email Scenario"
{
    /// <summary>
    /// Gets the default email account.
    /// </summary>
    /// <param name="EmailAccount">Out parameter holding information about the default email account.</param>
    /// <returns>True if an account for the the default scenario was found; otherwise - false.</returns>
    procedure GetDefaultEmailAccount(var EmailAccount: Record "Email Account"): Boolean
    begin
        exit(EmailScenarioImpl.GetEmailAccount(Enum::"Email Scenario"::Default, EmailAccount));
    end;

    /// <summary>
    /// Gets the email account used by the given email scenario.
    /// If the no account is defined for the provided scenario, the default account (if defined) will be returned.
    /// </summary>
    /// <param name="Scenario">The scenario to look for.</param>
    /// <param name="EmailAccount">Out parameter holding information about the email account.</param>
    /// <returns>True if an account for the specified scenario was found; otherwise - false.</returns>
    procedure GetEmailAccount(Scenario: Enum "Email Scenario"; var EmailAccount: Record "Email Account"): Boolean
    begin
        exit(EmailScenarioImpl.GetEmailAccount(Scenario, EmailAccount));
    end;

    /// <summary>
    /// Sets a default email account.
    /// </summary>
    /// <param name="EmailAccount">The email account to use.</param>
    procedure SetDefaultEmailAccount(EmailAccount: Record "Email Account")
    begin
        EmailScenarioImpl.SetEmailAccount(Enum::"Email Scenario"::Default, EmailAccount);
    end;

    /// <summary>
    /// Sets an email account to be used by the given email scenario.
    /// </summary>
    /// <param name="Scenario">The scenario for which to set an email account.</param>
    /// <param name="EmailAccount">The email account to use.</param>
    procedure SetEmailAccount(Scenario: Enum "Email Scenario"; EmailAccount: Record "Email Account")
    begin
        EmailScenarioImpl.SetEmailAccount(Scenario, EmailAccount);
    end;

    /// <summary>
    /// Unassign an email scenario. The scenario will then use the default email account.
    /// </summary>
    /// <param name="Scenario">The scenario to unassign.</param>
    procedure UnassignScenario(Scenario: Enum "Email Scenario")
    begin
        EmailScenarioImpl.UnassignScenario(Scenario);
    end;

    var
        EmailScenarioImpl: Codeunit "Email Scenario Impl.";
}