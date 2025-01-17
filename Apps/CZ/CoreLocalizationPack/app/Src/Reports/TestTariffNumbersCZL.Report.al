// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;
using System.Utilities;

report 31105 "Test Tariff Numbers CZL"
{
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/TestTariffNumbers.rdl';
    Caption = 'Test Tariff Numbers';
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = where("Tariff No." = filter(<> ''));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed() then begin
                    CurrentRecord += 1;
                    WindowDialog.Update(1, "No.");
                    WindowDialog.Update(2, Round(CurrentRecord / RecordCount * 10000, 1));
                end;

                if MissingTariffNoDictionary.Get("Tariff No.", NoOfItems) then
                    MissingTariffNoDictionary.Set("Tariff No.", NoOfItems + 1)
                else
                    if not TariffNumber.Get("Tariff No.") then begin
                        MissingTariffNoDictionary.Add("Tariff No.", 1);
                        TempTariffNumber."No." := "Tariff No.";
                        TempTariffNumber.Insert();
                    end;
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed() then
                    WindowDialog.Close();
            end;

            trigger OnPreDataItem()
            begin
                if GuiAllowed() then begin
                    RecordCount := Count();
                    WindowDialog.Open(ProcessingItemsTxt);
                end;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number);
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ReportFilter; GetItemFilters())
            {
            }
            column(TariffNo_fld; TempTariffNumber."No.")
            {
            }
            column(NoOfItems_var; NoOfItems)
            {
            }
            column(Result; NotExistTxt)
            {
            }
            column(Sequence_Number; Number)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempTariffNumber.FindSet()
                else
                    TempTariffNumber.Next();

                if not MissingTariffNoDictionary.Get(TempTariffNumber."No.", NoOfItems) then
                    NoOfItems := 0;
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, MissingTariffNoDictionary.Count());
            end;
        }
    }

    labels
    {
        ReportCaptionLbl = 'Test Tariff Numbers';
        PageCaptionLbl = 'Page';
        TariffNo_CaptionLbl = 'Tariff Number';
        Result_CaptionLbl = 'Description';
        NoOfItems_CaptionLbl = 'No. of Items';
    }

    var
        TariffNumber: Record "Tariff Number";
        TempTariffNumber: Record "Tariff Number" temporary;
        MissingTariffNoDictionary: Dictionary of [Code[20], Integer];
        WindowDialog: Dialog;
        NoOfItems: Integer;
        CurrentRecord: Integer;
        RecordCount: Integer;
        ProcessingItemsTxt: Label 'Checking item #1############\@2@@@@@@@@@@@@@@@@@@@@@@@@@@', Comment = '#1 = item no., @2 = progress';
        NotExistTxt: Label 'Does not exist in tariff numbers';
        FilterTemplateTxt: Label '%1: %2', Comment = '%1 = tablecaption, %2 = table filters.', Locked = true;

    local procedure GetItemFilters() Filters: Text;
    begin
        Filters := Item.GetFilters();
        if Filters <> '' then
            Filters := StrSubstNo(FilterTemplateTxt, Item.TableCaption(), Filters);
    end;
}
