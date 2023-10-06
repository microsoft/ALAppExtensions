#if not CLEAN21
permissionsetextension 4041 "D365 BASIC ISV - HBCLUS" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Stg Data Exch Def US" = RIMD;
}
#endif