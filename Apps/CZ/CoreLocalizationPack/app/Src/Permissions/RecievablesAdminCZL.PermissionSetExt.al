permissionsetextension 11745 "Recievables - Admin CZL" extends "Recievables - Admin"
{
#if not CLEAN22
#pragma warning disable AL0432
    Permissions = tabledata "Subst. Cust. Posting Group CZL" = RIMD,
                  tabledata "Document Footer CZL" = RIMD;
#pragma warning restore AL0432
#else
    Permissions = tabledata "Document Footer CZL" = RIMD;
#endif
}
