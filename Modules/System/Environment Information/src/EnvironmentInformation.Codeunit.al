// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to fetch attributes concerning the environment of the service on which the tenant is hosted.
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
    /// Gets the name of the environment.
    /// </summary>
    /// <returns>The name of the environment.</returns>
    procedure GetEnvironmentName(): Text
    begin
        exit(EnvironmentInformationImpl.GetEnvironmentName());
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
    /// Checks the application family is Financials.
    /// </summary>
    /// <returns>True if the application family is Financials, false otherwise.</returns>
    procedure IsFinancials(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsFinancials());
    end;

    /// <summary>
    /// Checks if the deployment infrastucture is SaaS (Software as a Service). 
    /// Note: This function will return false in a Docker container.
    /// </summary>
    /// <returns>True if the deployment infrastructure type is a SaaS, false otherwise.</returns>
    procedure IsSaaSInfrastructure(): Boolean
    begin
        exit(EnvironmentInformationImpl.IsSaaSInfrastructure());
    end;

    /// <summary>
    /// Gets the application family.
    /// </summary>
    /// <returns>The application family.</returns>
    procedure GetApplicationFamily(): Text
    begin
        exit(EnvironmentInformationImpl.GetApplicationFamily());
    end;

    /// <summary>
    /// Gets the version which a given app was installed in.
    /// </summary>
    /// <param name="AppID">The module ID of the app.</param>
    /// <returns>The major version number when the app was installed.</returns>
    procedure VersionInstalled(AppID: Guid): Integer
    begin
        exit(EnvironmentInformationImpl.VersionInstalled(AppID));
    end;
}
