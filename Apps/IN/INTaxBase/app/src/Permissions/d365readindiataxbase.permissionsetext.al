permissionsetextension 18548 "D365 READ - India Tax Base" extends "D365 READ"
{
    Permissions = tabledata "Assessee Code" = R,
                  tabledata "Concessional Code" = R,
                  tabledata "Deductor Category" = R,
                  tabledata "Gen. Journal Narration" = R,
                  tabledata Ministry = R,
                  tabledata Party = R,
                  tabledata "Posting No. Series" = RIMD,
                  tabledata State = R,
                  tabledata "TAN Nos." = R,
                  tabledata "Tax Accounting Period" = R;
}
