#if not CLEAN21
permissionsetextension 4047 "D365 TEAM MEMBER - HBCLMX" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Stg Data Exch Def MX" = RIMD;
}
#endif