permissionsetextension 18930 "D365 BASIC ISV - India Voucher Interface" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Journal Voucher Posting Setup" = RIMD,
                  tabledata "Posted Narration" = RIMD,
                  tabledata "Voucher Posting Credit Account" = RIMD,
                  tabledata "Voucher Posting Debit Account" = RIMD;
}
