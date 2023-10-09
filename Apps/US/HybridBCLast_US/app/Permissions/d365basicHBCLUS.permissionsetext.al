#if not CLEAN21
permissionsetextension 4040 "D365 BASIC - HBCLUS" extends "D365 BASIC"
{
    Permissions = tabledata "Stg Data Exch Def US" = RIMD;
}
#endif