// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 149020 "BCPT Install"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() and (not EnvironmentInformation.IsSandbox()) then
            Error(CannotInstallErr);
    end;

    var
        CannotInstallErr: Label 'Cannot install on environment that is not a Sandbox or OnPrem.//Please contact your administrator.';
}