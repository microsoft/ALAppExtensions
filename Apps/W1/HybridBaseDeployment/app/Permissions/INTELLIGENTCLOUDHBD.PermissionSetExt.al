// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

using System.Security.AccessControl;

permissionsetextension 4003 "INTELLIGENT CLOUD - HBD" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "Hybrid Product Type" = RIMD,
                  tabledata "Hybrid Replication Detail" = RIMD,
                  tabledata "Hybrid Replication Summary" = RIMD,
                  tabledata "Intelligent Cloud Setup" = RIMD,
                  tabledata "Hybrid Company" = RIMD,
                  tabledata "User Mapping Source" = RIMD,
                  tabledata "Post Migration Checklist" = RIMD,
                  tabledata "Migration Table Mapping" = RIMD,
                  tabledata "Migration Setup Table Mapping" = RIMD,
                  tabledata "Replication Table Mapping" = RIMD,
                  tabledata "Intelligent Cloud Not Migrated" = RIMD,
                  tabledata "User Mapping Work" = RIMD,
                  tabledata "Replication Run Completed Arg" = RIMD,
                  tabledata "Hybrid DA Approval" = rmi,
                  tabledata "Replication Record Link Buffer" = RIMD,
                  tabledata "Record Link Mapping" = RIMD,
                  tabledata "Cloud Migration Warning" = RIMD;
}