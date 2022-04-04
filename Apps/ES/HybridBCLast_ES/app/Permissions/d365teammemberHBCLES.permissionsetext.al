#if not CLEAN17
permissionsetextension 4035 "D365 TEAM MEMBER - HBCLES" extends "D365 TEAM MEMBER"
{
#pragma warning disable AL0432
    Permissions = tabledata "Stg SII Setup" = RIMD,
                  tabledata "Stg Report Selections" = RIMD;
#pragma warning restore AL0432
}
#endif