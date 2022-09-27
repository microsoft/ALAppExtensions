// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50001 "License Information Impl."
{
    Access = Internal;

    var
        LicenseInformation: Record "License Information";
        EnvironmentInformation: Codeunit "Environment Information";
        OnSaaSError: Label 'Only for OnPrem environments. In SaaS environments use Entitlements.';

    procedure GetLicenseDetails(): Text
    var
        LicenseDetailsBuilder: TextBuilder;
    begin
        if EnvironmentInformation.IsSaaS() then
            Error(OnSaaSError);

        LicenseInformation.FindSet();
        repeat
            LicenseDetailsBuilder.AppendLine(LicenseInformation.Text);
        until LicenseInformation.Next() = 0;

        exit(LicenseDetailsBuilder.ToText());
    end;
}

