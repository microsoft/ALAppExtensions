permissionset 11716 "SALES-ADVANCE, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Sales Advance Post';

    Permissions = tabledata "Adv. Letter Line Rel. Buffer" = RIMD,
                  tabledata "Advance Link" = RIMD,
                  tabledata "Advance Link Buffer - Entry" = RIMD,
                  tabledata "Advance Link Buffer" = RIMD,
                  tabledata "Sales Adv. Payment Template" = RIMD,
                  tabledata "Sales Advance Letter Entry" = Rimd,
                  tabledata "Sales Advance Letter Header" = RIMD,
                  tabledata "Sales Advance Letter Line" = RIMD,
                  tabledata "VAT Amount Line Adv. Payment" = RIMD;
}
