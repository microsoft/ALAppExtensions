#if not CLEAN17
permissionsetextension 4034 "D365 BASIC ISV - HBCLES" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Stg SII Setup" = RIMD,
                  tabledata "Stg Report Selections" = RIMD;
}
#endif