#if not CLEAN17
permissionsetextension 4034 "D365 BASIC ISV - HBCLES" extends "D365 BASIC ISV"
{
#pragma warning disable AL0432
    Permissions = tabledata "Stg SII Setup" = RIMD,
                  tabledata "Stg Report Selections" = RIMD;
}
#pragma warning restore AL0432
#endif