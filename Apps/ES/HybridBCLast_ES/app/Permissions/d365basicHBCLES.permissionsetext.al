#if not CLEAN17
permissionsetextension 4033 "D365 BASIC - HBCLES" extends "D365 BASIC"
{
    Permissions = tabledata "Stg SII Setup" = RIMD,
                  tabledata "Stg Report Selections" = RIMD;
}
#endif