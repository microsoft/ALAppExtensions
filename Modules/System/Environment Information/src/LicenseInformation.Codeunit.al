// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to fetch details from the license uploaded to an OnPrem instance.
/// </summary>
codeunit 50000 "License Information"
{
    Access = Public;

    var
        LicenseInformationImpl: Codeunit "License Information Impl.";

    /// <summary>
    /// Gets the OnPrem license details from License Information table.
    /// </summary>
    /// <returns>If Environment is not OnPrem, an error is returned. Otherwise a text with the license details is returned.</returns>
    procedure GetLicenseDetails(): Text
    begin
        exit(LicenseInformationImpl.GetLicenseDetails());
    end;
}

