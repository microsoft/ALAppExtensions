namespace Microsoft.Foundation.DataSearch;

using System.Security.AccessControl;

permissionsetextension 2681 "Data Search" extends "D365 BASIC"
{
    Permissions =
        table "Data Search Result" = X,
        table "Data Search Setup (Table)" = X,
        table "Data Search Setup (Field)" = X,
        tabledata "Data Search Result" = RIMD,
        tabledata "Data Search Setup (Table)" = Rim,
        tabledata "Data Search Setup (Field)" = Ri,
        codeunit "Data Search Defaults" = X,
        codeunit "Data Search In Table" = X,
        codeunit "Data Search Invocation" = X,
        codeunit "Data Search Object Mapping" = X,
        codeunit "Data Search Events" = X,
        codeunit "Data Search Setup Changes" = X,
        page "Data Search" = X,
        page "Data Search Lines" = X,
        page "Data Search Result Records" = X,
        page "Data Search Setup (Lists)" = X,
        page "Data Search Setup (Table) List" = X,
        page "Data Search Setup (Field) List" = X,
        page "Data Search Setup (Field) Part" = X;
}