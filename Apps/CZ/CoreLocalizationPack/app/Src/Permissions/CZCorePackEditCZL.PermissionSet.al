﻿permissionset 11731 "CZ Core Pack - Edit CZL"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Core Pack - Edit';

    IncludedPermissionSets = "CZ Core Pack - Read CZL";

    Permissions = tabledata "Acc. Sched. Expr. Buffer CZL" = IMD,
                  tabledata "Acc. Schedule Extension CZL" = IMD,
                  tabledata "Acc. Schedule File Mapping CZL" = IMD,
                  tabledata "Acc. Schedule Result Col. CZL" = IMD,
                  tabledata "Acc. Schedule Result Hdr. CZL" = IMD,
                  tabledata "Acc. Schedule Result Hist. CZL" = IMD,
                  tabledata "Acc. Schedule Result Line CZL" = IMD,
                  tabledata "Acc. Schedule Result Value CZL" = IMD,
                  tabledata "Adj. Exchange Rate Buffer CZL" = IMD,
                  tabledata "Bank Acc. Adjust. Buffer CZL" = IMD,
                  tabledata "Certificate Code CZL" = IMD,
                  tabledata "Commodity CZL" = IMD,
                  tabledata "Commodity Setup CZL" = IMD,
                  tabledata "Company Official CZL" = IMD,
                  tabledata "Constant Symbol CZL" = IMD,
                  tabledata "Cross Application Buffer CZL" = IMD,
                  tabledata "Document Footer CZL" = IMD,
                  tabledata "EET Business Premises CZL" = IMD,
                  tabledata "EET Cash Register CZL" = IMD,
                  tabledata "EET Entry CZL" = IMD,
                  tabledata "EET Entry Status Log CZL" = IMD,
                  tabledata "EET Service Setup CZL" = IMD,
                  tabledata "Enhanced Currency Buffer CZL" = IMD,
                  tabledata "Excel Template CZL" = IMD,
                  tabledata "G/L Account Adjust. Buffer CZL" = IMD,
#if not CLEAN22
#pragma warning disable AL0432
                  tabledata "Intrastat Delivery Group CZL" = IMD,
#pragma warning restore AL0432
#endif
                  tabledata "Invt. Movement Template CZL" = IMD,
                  tabledata "Reg. No. Service Config CZL" = IMD,
                  tabledata "Registration Log CZL" = IMD,
                  tabledata "Registration Log Detail CZL" = IMD,
#if not CLEAN22
#pragma warning disable AL0432
                  tabledata "Specific Movement CZL" = IMD,
                  tabledata "Statistic Indication CZL" = IMD,
#pragma warning restore AL0432
#endif
                  tabledata "Statutory Reporting Setup CZL" = IMD,
                  tabledata "Stockkeeping Unit Template CZL" = IMD,
#if not CLEAN22
#pragma warning disable AL0432
                  tabledata "Subst. Cust. Posting Group CZL" = IMD,
                  tabledata "Subst. Vend. Posting Group CZL" = IMD,
#pragma warning restore AL0432
#endif
                  tabledata "Unrel. Payer Service Setup CZL" = IMD,
                  tabledata "Unreliable Payer Entry CZL" = IMD,
                  tabledata "User Setup Line CZL" = IMD,
                  tabledata "VAT Attribute Code CZL" = IMD,
                  tabledata "VAT Ctrl. Report Buffer CZL" = IMD,
                  tabledata "VAT Ctrl. Report Ent. Link CZL" = IMD,
                  tabledata "VAT Ctrl. Report Header CZL" = IMD,
                  tabledata "VAT Ctrl. Report Line CZL" = IMD,
                  tabledata "VAT Ctrl. Report Section CZL" = IMD,
                  tabledata "VAT LCY Correction Buffer CZL" = IMD,
                  tabledata "VAT Period CZL" = IMD,
                  tabledata "VAT Statement Attachment CZL" = IMD,
                  tabledata "VAT Statement Comment Line CZL" = IMD,
                  tabledata "VIES Declaration Header CZL" = IMD,
                  tabledata "VIES Declaration Line CZL" = IMD;
}
