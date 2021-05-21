permissionsetextension 11700 "D365 BASIC - HBCLCZ" extends "D365 BASIC"
{
    Permissions = tabledata "Stg VAT Control Report Line" = RIMD,
                  tabledata "Stg VAT Posting Setup" = RIMD,
                  tabledata "Stg Intrastat Jnl. Line" = RIMD,
                  tabledata "Stg Item Journal Line" = RIMD,
                  tabledata "Stg Item Ledger Entry" = RIMD;
}