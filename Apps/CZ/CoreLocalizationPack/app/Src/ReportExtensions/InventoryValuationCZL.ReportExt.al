#pragma warning disable AA0247
reportextension 11704 "Inventory Valuation CZL" extends "Inventory Valuation"
{
    rendering
    {
        layout("InventoryValuationCZL.xlsx_CZL")
        {
            Type = Excel;
            LayoutFile = './Src/ReportExtensions/InventoryValuationCZL.xlsx';
            Caption = 'Inventory Valuation (Excel)';
            Summary = 'The Inventory Valuation (Excel) provides a detailed layout.';
        }
    }
}
