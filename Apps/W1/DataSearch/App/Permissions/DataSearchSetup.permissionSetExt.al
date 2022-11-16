permissionsetextension 2680 "Data Search Setup" extends "D365 Bus Full Access"
{
    Permissions =
        table "Data Search Result" = X,
        table "Data Search Setup (Table)" = X,
        table "Data Search Setup (Field)" = X,
        table "Data Search Source Temp" = X,
        tabledata "Data Search Result" = RIMD,
        tabledata "Data Search Setup (Table)" = RIMD,
        tabledata "Data Search Setup (Field)" = RIMD,
        tabledata "Data Search Source Temp" = RIMD,
        codeunit "Data Search Defaults" = X,
        codeunit "Data Search In Table" = X,
        page "Data Search" = X,
        page "Data Search Lines" = X,
        page "Data Search Result Records" = X,
        page "Data Search Setup (Table) List" = X,
        page "Data Search Setup (Field) List" = X,
        page "Data Search Setup (Field) Part" = X;
}