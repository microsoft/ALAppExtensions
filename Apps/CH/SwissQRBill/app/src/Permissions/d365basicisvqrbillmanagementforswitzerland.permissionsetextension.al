permissionsetextension 11501 "D365 BASIC ISV - QR-Bill Management for Switzerland" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Swiss QR-Bill Billing Detail" = RIMD,
                  tabledata "Swiss QR-Bill Billing Info" = RIMD,
                  tabledata "Swiss QR-Bill Buffer" = RIMD,
                  tabledata "Swiss QR-Bill Layout" = RIMD,
                  tabledata "Swiss QR-Bill Reports" = RIMD,
                  tabledata "Swiss QR-Bill Setup" = RIMD;
}
