permissionsetextension 4000 "D365 BASIC - HBD" extends "D365 BASIC"
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
                  tabledata "Replication Run Completed Arg" = RIMD;
}