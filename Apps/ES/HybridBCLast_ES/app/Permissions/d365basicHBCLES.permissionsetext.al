#if not CLEAN20
permissionsetextension 4033 "D365 BASIC - HBCLES" extends "D365 BASIC"
{
#pragma warning disable AL0432
    Permissions = tabledata "Stg SII Setup" = RIMD,
                  tabledata "Stg Report Selections" = RIMD;
}
#pragma warning restore AL0432
#endif