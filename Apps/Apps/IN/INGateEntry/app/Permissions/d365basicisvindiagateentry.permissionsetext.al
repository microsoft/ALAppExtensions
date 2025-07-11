// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using System.Security.AccessControl;

permissionsetextension 18602 "D365 BASIC ISV - India Gate Entry" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Gate Entry Attachment" = RIMD,
                  tabledata "Gate Entry Comment Line" = RIMD,
                  tabledata "Gate Entry Header" = RIMD,
                  tabledata "Gate Entry Line" = RIMD,
                  tabledata "Service Entity Type" = RIMD,
                  tabledata "Posted Gate Entry Line" = RIMD,
                  tabledata "Posted Gate Entry Attachment" = RIMD,
                  tabledata "Posted Gate Entry Header" = RIMD;
}
