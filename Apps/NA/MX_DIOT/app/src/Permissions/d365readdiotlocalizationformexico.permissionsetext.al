// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.AccessControl;

permissionsetextension 23717 "D365 READ - DIOT - Localization for Mexico" extends "D365 READ"
{
    Permissions = tabledata "DIOT Concept" = R,
                  tabledata "DIOT Concept Link" = R,
                  tabledata "DIOT Country/Region Data" = R,
                  tabledata "DIOT Report Buffer" = R,
                  tabledata "DIOT Report Vendor Buffer" = R;
}
