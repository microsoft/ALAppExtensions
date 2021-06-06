permissionsetextension 18545 "D365 BUS FULL ACCESS - India Tax Base" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Assessee Code" = RIMD,
                  tabledata "Concessional Code" = RIMD,
                  tabledata "Deductor Category" = RIMD,
                  tabledata "Gen. Journal Narration" = RIMD,
                  tabledata Ministry = RIMD,
                  tabledata Party = RIMD,
                  tabledata "Posting No. Series" = RIMD,
                  tabledata State = RIMD,
                  tabledata "TAN Nos." = RIMD,
                  tabledata "Tax Accounting Period" = RIMD;
}
