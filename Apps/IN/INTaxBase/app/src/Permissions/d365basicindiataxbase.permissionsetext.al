permissionsetextension 18543 "D365 BASIC - India Tax Base" extends "D365 BASIC"
{
    Permissions = tabledata "Assessee Code" = RIMD,
                  tabledata "Concessional Code" = RIMD,
                  tabledata "Deductor Category" = RIMD,
                  tabledata "Gen. Journal Narration" = RIMD,
                  tabledata Ministry = RIMD,
                  tabledata Party = RIMD,
                  tabledata State = RIMD,
                  tabledata "Posting No. Series" = RIMD,
                  tabledata "TAN Nos." = RIMD,
                  tabledata "Tax Accounting Period" = RIMD;
}
