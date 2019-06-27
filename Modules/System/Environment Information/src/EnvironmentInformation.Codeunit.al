// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 457 "Environment Information"
{
    Access = Public;
    SingleInstance = true;

    var
        EnvironmentInformationImpl: Codeunit "Environment Information Impl.";

        /// <summary>
        /// Checks if environment type of tenant is Production.
        /// </summary>
        /// <returns>True if the environment type is Production, False otherwise.</returns>
    procedure IsProduction(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsProduction());
    end;

    /// <summary>
    /// Checks if environment type of tenant is Sandbox.
    /// </summary>
    /// <returns>True if the environment type is a Sandbox, False otherwise.</returns>
    procedure IsSandbox(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsSandbox());
    end;

    /// <summary>
    /// Checks if the deployment type is SaaS (Software as a Service).
    /// </summary>
    /// <returns>True if the deployment type is a SaaS, false otherwise.</returns>
    procedure IsSaaS(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsSaaS());
    end;

    /// <summary>
    /// Checks the deployment type is OnPremises.
    /// </summary>
    /// <returns>True if the deployment type is OnPremises, false otherwise.</returns>
    procedure IsOnPrem(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsOnPrem());
    end;

    /// <summary>
    /// Checks the application family is Invoicing.
    /// </summary>
    /// <returns>True if the application family is Invoicing, false otherwise.</returns>
    procedure IsInvoicing(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsInvoicing());
    end;

    /// <summary>
    /// Checks the application family is Financials.
    /// </summary>
    /// <returns>True if the application family is Financials, false otherwise.</returns>
    procedure IsFinancials(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsFinancials());
    end;

    /// <summary>
    /// Sets the testability sandbox flag.
    /// </summary>
    /// <remarks>
    /// This functions should only be used for testing purposes.
    /// </remarks>
    /// <param name="EnableSandboxForTest">The value to be set to the testability sandbox flag.</param>
    [Scope('OnPrem')]
    procedure SetTestabilitySandbox(EnableSandboxForTest: Boolean)
    begin
        EnvironmentInformationImpl.SetTestabilitySandbox(EnableSandboxForTest);
    end;

    /// <summary>
    /// Sets the testability SaaS flag.
    /// </summary>
    /// <remarks>
    /// This functions should only be used for testing purposes.
    /// </remarks>
    /// <param name="EnableSoftwareAsAServiceForTest">The value to be set to the testability SaaS flag.</param>
    [Scope('OnPrem')]
    procedure SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest: Boolean)
    begin
        EnvironmentInformationImpl.SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest);
    end;

    /// <summary>
    /// An event which asks for the AppId to be filled in by the subscriber.
    /// </summary>
    /// <remarks>This should be subscribed to only in tests.</remarks>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnBeforeGetApplicationIdentifier(var AppId: Text)
    begin
    end;
}

