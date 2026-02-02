// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Security.AccessControl;

permissionsetextension 47202 "SLD365 Team Member Ext. - HSLUS" extends "D365 Team Member"
{
    Permissions = tabledata "SL Supported Tax Year" = RIMD,
                  tabledata "SL 1099 Box Mapping" = RIMD,
                  tabledata "SL 1099 Migration Log" = RIMD;
}