namespace Microsoft.DataMigration;

using System.Security.AccessControl;

permissionsetextension 4001 "D365 BASIC ISV - HBD" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Hybrid Product Type" = RIMD,
                  tabledata "Hybrid Replication Detail" = RIMD,
                  tabledata "Hybrid Replication Summary" = RIMD,
                  tabledata "Intelligent Cloud Setup" = RIMD,
                  tabledata "Hybrid Company" = RIMD,
                  tabledata "User Mapping Source" = RIMD,
                  tabledata "Post Migration Checklist" = RIMD,
                  tabledata "Migration Table Mapping" = RIMD,
                  tabledata "Intelligent Cloud Not Migrated" = RIMD,
                  tabledata "User Mapping Work" = RIMD,
                  tabledata "Replication Run Completed Arg" = RIMD,
                  tabledata "Cloud Migration Override Log" = RIMD,
                  tabledata "Hybrid DA Approval" = rmi;
}