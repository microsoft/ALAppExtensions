permissionsetextension 31255 "D365 READ - Banking Documents Localization for Czech" extends "D365 READ"
{
    Permissions = tabledata "Bank Statement Header CZB" = RIMD,
                  tabledata "Bank Statement Line CZB" = RIMD,
                  tabledata "Iss. Bank Statement Header CZB" = RIMD,
                  tabledata "Iss. Bank Statement Line CZB" = RIMD,
                  tabledata "Iss. Payment Order Header CZB" = RIMD,
                  tabledata "Iss. Payment Order Line CZB" = RIMD,
                  tabledata "Payment Order Header CZB" = RIMD,
                  tabledata "Payment Order Line CZB" = RIMD,
                  tabledata "Search Rule CZB" = RIMD,
                  tabledata "Search Rule Line CZB" = RIMD;
}
