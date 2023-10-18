#if not CLEAN21
permissionsetextension 4047 "D365 BASIC ISV - HBCLCA" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Stg Data Exch Def CA" = RIMD;
}
#endif