namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Inventory.Analysis;

query 37004 "Item Budget Entries - Sales"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Item Budget Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'salesItemBudgetEntry';
    EntitySetName = 'salesItemBudgetEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ItemBudgetEntry; "Item Budget Entry")
        {
            DataItemTableFilter = "Analysis Area" = const(Sales);
            column(entryNo; "Entry No.")
            {

            }
            column(budgetName; "Budget Name")
            {
            }
            column(entryDate; Date)
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(sourceType; "Source Type")
            {
            }
            column(sourceNo; "Source No.")
            {
            }
            column(quantity; Quantity)
            {

            }
            column(salesAmount; "Sales Amount")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Sales Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateItemSalesReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(entryDate, DateFilterText);
    end;
}