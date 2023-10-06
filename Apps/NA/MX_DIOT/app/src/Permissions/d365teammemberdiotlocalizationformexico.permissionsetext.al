// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.AccessControl;

permissionsetextension 9987 "D365 TEAM MEMBER - DIOT - Localization for Mexico" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "DIOT Concept" = RIMD,
                  tabledata "DIOT Concept Link" = RIMD,
                  tabledata "DIOT Country/Region Data" = RIMD,
                  tabledata "DIOT Report Buffer" = RIMD,
                  tabledata "DIOT Report Vendor Buffer" = RIMD;
}
