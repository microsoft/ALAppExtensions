#if not CLEAN21
permissionsetextension 4048 "D365 TEAM MEMBER - HBCLCA" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Stg Data Exch Def CA" = RIMD;
}
#endif