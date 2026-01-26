// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Calculation;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Ledger;

report 6221 "Sust. Adjust Emissions"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Adjust Emissions';
    Permissions = TableData Item = rm,
                  TableData "Sustainability Value Entry" = r;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FilterItemNo; ItemNoFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Item No. Filter';
                        Editable = FilterItemNoEditable;
                        ToolTip = 'Specifies a filter to run the Adjust Emissions batch job for only certain items. You can leave this field blank to run the batch job for all items.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ItemList: Page "Item List";
                        begin
                            ItemList.LookupMode := true;
                            if ItemList.RunModal() = Action::LookupOK then
                                Text := ItemList.GetSelectionFilter()
                            else
                                exit(false);

                            exit(true);
                        end;
                    }
                    field(FilterItemCategory; ItemCategoryFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Item Category Filter';
                        Editable = FilterItemCategoryEditable;
                        TableRelation = "Item Category";
                        ToolTip = 'Specifies a filter to run the Adjust Emissions batch job for only certain item categories. You can leave this field blank to run the batch job for all item categories.';
                    }
                }
            }
        }

        trigger OnInit()
        begin
            FilterItemCategoryEditable := true;
            FilterItemNoEditable := true;
        end;
    }

    trigger OnPreReport()
    var
        Item: Record Item;
    begin
        if not LockTables() then
            CurrReport.Quit();

        if (ItemNoFilter <> '') and (ItemCategoryFilter <> '') then
            Error(ItemOrCategoryFilterErr);

        if ItemNoFilter <> '' then
            Item.SetFilter("No.", ItemNoFilter);
        if ItemCategoryFilter <> '' then
            Item.SetFilter("Item Category Code", ItemCategoryFilter);

        RunEmissionAdjustment(Item);
    end;

    var
        FilterItemNoEditable: Boolean;
        FilterItemCategoryEditable: Boolean;
        ItemOrCategoryFilterErr: Label 'You must not use Item No. Filter and Item Category Filter at the same time.';

    protected var
        ItemNoFilter: Text[250];
        ItemCategoryFilter: Text[250];

    local procedure LockTables(): Boolean
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.LockTable();
        if SustainabilityValueEntry.GetLastEntryNo() = 0 then
            exit(false);

        exit(true);
    end;

    procedure InitializeRequest(NewItemNoFilter: Text[250]; NewItemCategoryFilter: Text[250])
    begin
        ItemNoFilter := NewItemNoFilter;
        ItemCategoryFilter := NewItemCategoryFilter;
    end;

    local procedure RunEmissionAdjustment(var NewItem: Record Item)
    var
        Item: Record Item;
    begin
        Item.CopyFilters(NewItem);
        Item.SetLoadFields("CO2e per Unit", "CO2e Last Date Modified");
        if Item.FindSet() then
            repeat
                UpdateCO2ePerUnit(Item);
            until Item.Next() = 0;
    end;

    local procedure UpdateCO2ePerUnit(var Item: Record Item)
    var
        SustCostManagement: Codeunit SustCostManagement;
        CO2eEmission: Decimal;
    begin
        if not ExistSustainabilityValueEntry(Item) then
            exit;

        if not SustCostManagement.CalculateAverageCost(Item, CO2eEmission) then
            exit;

        Item.Validate("CO2e per Unit", CO2eEmission);
        Item.Validate("CO2e Last Date Modified", Today());
        Item.Modify(true);
    end;

    local procedure ExistSustainabilityValueEntry(Item: Record Item): Boolean
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.SetRange("Item No.", Item."No.");
        if not SustainabilityValueEntry.IsEmpty() then
            exit(true);
    end;
}