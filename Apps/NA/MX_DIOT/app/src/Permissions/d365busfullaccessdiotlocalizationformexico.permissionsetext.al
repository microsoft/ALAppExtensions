// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.AccessControl;

permissionsetextension 11037 "D365 BUS FULL ACCESS - DIOT - Localization for Mexico" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "DIOT Concept" = RIMD,
                  tabledata "DIOT Concept Link" = RIMD,
                  tabledata "DIOT Country/Region Data" = RIMD,
                  tabledata "DIOT Report Buffer" = RIMD,
                  tabledata "DIOT Report Vendor Buffer" = RIMD;
}
