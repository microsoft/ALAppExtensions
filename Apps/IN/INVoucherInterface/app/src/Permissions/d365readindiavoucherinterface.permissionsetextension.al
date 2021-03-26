permissionsetextension 18934 "D365 READ - India Voucher Interface" extends "D365 READ"
{
    Permissions = tabledata "Journal Voucher Posting Setup" = R,
                  tabledata "Posted Narration" = R,
                  tabledata "Voucher Posting Credit Account" = R,
                  tabledata "Voucher Posting Debit Account" = R;
}
