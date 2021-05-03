permissionsetextension 11701 "D365 BASIC ISV - HBCLCZ" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Stg VAT Control Report Line" = RIMD,
                  tabledata "Stg VAT Posting Setup" = RIMD,
                  tabledata "Stg Intrastat Jnl. Line" = RIMD,
                  tabledata "Stg Item Journal Line" = RIMD,
                  tabledata "Stg Item Ledger Entry" = RIMD;
}