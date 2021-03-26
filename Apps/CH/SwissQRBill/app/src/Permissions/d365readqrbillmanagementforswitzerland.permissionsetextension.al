permissionsetextension 11506 "D365 READ - QR-Bill Management for Switzerland" extends "D365 READ"
{
    Permissions = tabledata "Swiss QR-Bill Billing Detail" = R,
                  tabledata "Swiss QR-Bill Billing Info" = R,
                  tabledata "Swiss QR-Bill Buffer" = R,
                  tabledata "Swiss QR-Bill Layout" = R,
                  tabledata "Swiss QR-Bill Reports" = R,
                  tabledata "Swiss QR-Bill Setup" = R;
}
