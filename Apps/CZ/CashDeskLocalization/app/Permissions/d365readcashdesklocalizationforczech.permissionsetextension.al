permissionsetextension 30571 "D365 READ - Cash Desk Localization for Czech" extends "D365 READ"
{
    Permissions = tabledata "Cash Desk Cue CZP" = R,
                  tabledata "Cash Desk CZP" = R,
                  tabledata "Cash Desk Event CZP" = R,
                  tabledata "Cash Desk Rep. Selections CZP" = R,
                  tabledata "Cash Desk User CZP" = R,
                  tabledata "Cash Document Header CZP" = R,
                  tabledata "Cash Document Line CZP" = R,
                  tabledata "Currency Nominal Value CZP" = R,
                  tabledata "Posted Cash Document Hdr. CZP" = R,
                  tabledata "Posted Cash Document Line CZP" = R;
}
