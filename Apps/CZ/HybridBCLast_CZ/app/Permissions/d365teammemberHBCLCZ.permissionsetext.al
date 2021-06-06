permissionsetextension 11702 "D365 TEAM MEMBER - HBCLCZ" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Stg VAT Control Report Line" = RIMD,
                  tabledata "Stg VAT Posting Setup" = RIMD,
                  tabledata "Stg Intrastat Jnl. Line" = RIMD,
                  tabledata "Stg Item Journal Line" = RIMD,
                  tabledata "Stg Item Ledger Entry" = RIMD;
}