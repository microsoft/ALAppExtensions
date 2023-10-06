#if not CLEAN21
permissionsetextension 4046 "D365 BASIC - HBCLCA" extends "D365 BASIC"
{
    Permissions = tabledata "Stg Data Exch Def CA" = RIMD;
}
#endif