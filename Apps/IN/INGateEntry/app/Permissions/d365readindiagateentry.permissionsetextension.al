permissionsetextension 18606 "D365 READ - India Gate Entry" extends "D365 READ"
{
    Permissions = tabledata "Gate Entry Attachment" = RIMD,
                  tabledata "Gate Entry Comment Line" = RIMD,
                  tabledata "Gate Entry Header" = RIMD,
                  tabledata "Gate Entry Line" = RIMD,
                  tabledata "Service Entity Type" = RIMD,
                  tabledata "Posted Gate Entry Line" = RIMD,
                  tabledata "Posted Gate Entry Attachment" = RIMD,
                  tabledata "Posted Gate Entry Header" = RIMD;
}
