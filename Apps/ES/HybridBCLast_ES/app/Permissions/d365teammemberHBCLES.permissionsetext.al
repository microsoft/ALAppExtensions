#if not CLEAN17
permissionsetextension 4035 "D365 TEAM MEMBER - HBCLES" extends "D365 TEAM MEMBER"
{    
    Permissions = tabledata "Stg SII Setup" = RIMD,
                  tabledata "Stg Report Selections" = RIMD;
}
#endif