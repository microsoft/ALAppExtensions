// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 457 "Environment Information"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        EnvironmentInformationImpl: Codeunit "Environment Information Impl.";

    procedure IsProduction(): Boolean
    begin
        // <summary>
        // Checks if environment type of tenant is Production.
        // </summary>
        // <returns>True if the environment type is Production, False otherwise.</returns>
        exit(EnvironmentInformationImpl.IsProduction);
    end;

    procedure IsSandbox(): Boolean
    begin
        // <summary>
        // Checks if environment type of tenant is Sandbox.
        // </summary>
        // <returns>True if the environment type is a Sandbox, False otherwise.</returns>
        exit(EnvironmentInformationImpl.IsSandbox);
    end;

    procedure IsSaaS(): Boolean
    begin
        // <summary>
        // Checks if the deployment type is SaaS (Software as a Service).
        // </summary>
        // <returns>True if the deployment type is a SaaS, false otherwise.</returns>
        exit(EnvironmentInformationImpl.IsSaaS);
    end;

    procedure IsOnPrem(): Boolean
    begin
        // <summary>
        // Checks the deployment type is OnPremises.
        // </summary>
        // <returns>True if the deployment type is OnPremises, false otherwise.</returns>
        exit(EnvironmentInformationImpl.IsOnPrem);
    end;

    procedure IsInvoicing(): Boolean
    begin
        // <summary>
        // Checks the application family is Invoicing.
        // </summary>
        // <returns>True if the application family is Invoicing, false otherwise.</returns>
        exit(EnvironmentInformationImpl.IsInvoicing);
    end;

    procedure IsFinancials(): Boolean
    begin
        // <summary>
        // Checks the application family is Financials.
        // </summary>
        // <returns>True if the application family is Financials, false otherwise.</returns>
        exit(EnvironmentInformationImpl.IsFinancials);
    end;

    [Scope('OnPrem')]
    procedure SetTestabilitySandbox(EnableSandboxForTest: Boolean)
    begin
        // <summary>
        // Sets the testibility sandbox flag.
        // </summary>
        // <remarks>
        // This functions should only be used for testing purposes.
        // </remarks>
        // <param name="EnableSandboxForTest">The value to be set to the testibility sandbox flag.</param>
        EnvironmentInformationImpl.SetTestabilitySandbox(EnableSandboxForTest);
    end;

    [Scope('OnPrem')]
    procedure SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest: Boolean)
    begin
        // <summary>
        // Sets the testibility SaaS flag.
        // </summary>
        // <remarks>
        // This functions should only be used for testing purposes.
        // </remarks>
        // <param name="EnableSoftwareAsAServiceForTest">The value to be set to the testibility SaaS flag.</param>
        EnvironmentInformationImpl.SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest);
    end;

    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    procedure OnBeforeGetApplicationIdentifier(var AppId: Text)
    begin
        // <summary>
        // An event which asks for the AppId to be filled in by the subscriber.
        // </summary>
        // <remarks>This should be subscribed to only in tests.</remarks>
    end;
}

