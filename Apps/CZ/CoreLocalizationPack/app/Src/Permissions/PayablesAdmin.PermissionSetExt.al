permissionsetextension 11744 "Payables - Admin CZL" extends "Payables - Admin"
{
#if not CLEAN22
#pragma warning disable AL0432
    Permissions = tabledata "Subst. Vend. Posting Group CZL" = RIMD,
                  tabledata "Document Footer CZL" = RIMD;
#pragma warning restore AL0432
#else
    Permissions = tabledata "Document Footer CZL" = RIMD;
#endif
}
