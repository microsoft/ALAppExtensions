#if not CLEAN21
permissionsetextension 4042 "D365 TEAM MEMBER - HBCLUS" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Stg Data Exch Def US" = RIMD;
}
#endif