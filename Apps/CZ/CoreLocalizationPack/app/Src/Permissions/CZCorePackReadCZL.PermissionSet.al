permissionset 11730 "CZ Core Pack - Read CZL"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Core Pack - Read';

    IncludedPermissionSets = "CZ Core Pack - Objects CZL";

    Permissions = tabledata "Acc. Sched. Expr. Buffer CZL" = R,
                  tabledata "Acc. Schedule Extension CZL" = R,
                  tabledata "Acc. Schedule File Mapping CZL" = R,
                  tabledata "Acc. Schedule Result Col. CZL" = R,
                  tabledata "Acc. Schedule Result Hdr. CZL" = R,
                  tabledata "Acc. Schedule Result Hist. CZL" = R,
                  tabledata "Acc. Schedule Result Line CZL" = R,
                  tabledata "Acc. Schedule Result Value CZL" = R,
                  tabledata "Adj. Exchange Rate Buffer CZL" = R,
                  tabledata "Bank Acc. Adjust. Buffer CZL" = R,
                  tabledata "Certificate Code CZL" = R,
                  tabledata "Commodity CZL" = R,
                  tabledata "Commodity Setup CZL" = R,
                  tabledata "Company Official CZL" = R,
                  tabledata "Constant Symbol CZL" = R,
                  tabledata "Cross Application Buffer CZL" = R,
                  tabledata "Document Footer CZL" = R,
                  tabledata "EET Business Premises CZL" = R,
                  tabledata "EET Cash Register CZL" = R,
                  tabledata "EET Entry CZL" = R,
                  tabledata "EET Entry Status Log CZL" = R,
                  tabledata "EET Service Setup CZL" = R,
                  tabledata "Enhanced Currency Buffer CZL" = R,
                  tabledata "Excel Template CZL" = R,
                  tabledata "G/L Account Adjust. Buffer CZL" = R,
#if not CLEAN22
#pragma warning disable AL0432
                  tabledata "Intrastat Delivery Group CZL" = R,
#pragma warning restore AL0432
#endif
                  tabledata "Invt. Movement Template CZL" = R,
                  tabledata "Reg. No. Service Config CZL" = R,
                  tabledata "Registration Log CZL" = R,
                  tabledata "Registration Log Detail CZL" = R,
#if not CLEAN22
#pragma warning disable AL0432
                  tabledata "Specific Movement CZL" = R,
                  tabledata "Statistic Indication CZL" = R,
#pragma warning restore AL0432
#endif
                  tabledata "Statutory Reporting Setup CZL" = R,
                  tabledata "Stockkeeping Unit Template CZL" = R,
#if not CLEAN22
#pragma warning disable AL0432
                  tabledata "Subst. Cust. Posting Group CZL" = R,
                  tabledata "Subst. Vend. Posting Group CZL" = R,
#pragma warning restore AL0432
#endif
                  tabledata "Unrel. Payer Service Setup CZL" = R,
                  tabledata "Unreliable Payer Entry CZL" = R,
                  tabledata "User Setup Line CZL" = R,
                  tabledata "VAT Attribute Code CZL" = R,
                  tabledata "VAT Ctrl. Report Buffer CZL" = R,
                  tabledata "VAT Ctrl. Report Ent. Link CZL" = R,
                  tabledata "VAT Ctrl. Report Header CZL" = R,
                  tabledata "VAT Ctrl. Report Line CZL" = R,
                  tabledata "VAT Ctrl. Report Section CZL" = R,
                  tabledata "VAT LCY Correction Buffer CZL" = R,
                  tabledata "VAT Period CZL" = R,
                  tabledata "VAT Statement Attachment CZL" = R,
                  tabledata "VAT Statement Comment Line CZL" = R,
                  tabledata "VIES Declaration Header CZL" = R,
                  tabledata "VIES Declaration Line CZL" = R;
}
