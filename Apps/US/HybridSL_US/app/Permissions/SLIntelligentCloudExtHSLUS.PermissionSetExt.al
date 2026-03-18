// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Security.AccessControl;

permissionsetextension 47203 "SL Intelligent Cloud Ext. - HSLUS" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "SL Supported Tax Year" = RIMD,
                  tabledata "SL 1099 Box Mapping" = RIMD,
                  tabledata "SL 1099 Migration Log" = RIMD;
}