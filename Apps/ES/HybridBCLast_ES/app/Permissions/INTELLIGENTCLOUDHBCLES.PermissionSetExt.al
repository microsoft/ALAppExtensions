#if not CLEAN17
permissionsetextension 4036 "INTELLIGENT CLOUD - HBCLES" extends "INTELLIGENT CLOUD"
{
#pragma warning disable AL0432
    Permissions = tabledata "Stg SII Setup" = RIMD,
                  tabledata "Stg Report Selections" = RIMD;
#pragma warning restore AL0432
}
#endif