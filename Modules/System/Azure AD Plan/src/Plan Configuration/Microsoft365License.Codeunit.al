// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to operate the Microsoft 365 License.
/// </summary>
codeunit 9085 "Microsoft 365 License"
{
    /// <summary>   
    /// Assign D365 Read Permission.
    /// </summary>
    /// <param name="ShowNotification">Show notification about license information regarding users in BC.</param>   
    procedure AssignMicrosoft365ReadPermission(ShowNotification: Boolean)
    begin
        Microsoft365LicenseImpl.AssignMicrosoft365ReadPermission(ShowNotification);
    end;

    /// <summary>
    /// Opens the Business Central admin center.
    /// </summary>
    procedure OpenBCAdminCenter()
    begin
        Microsoft365LicenseImpl.OpenBCAdminCenter();
    end;

    /// <summary>
    /// Opens the M365 admin center.
    /// </summary>
    procedure OpenM365AdminCenter()
    begin
        Microsoft365LicenseImpl.OpenM365AdminCenter();
    end;

    var
        Microsoft365LicenseImpl: Codeunit "Microsoft 365 License Impl.";
}