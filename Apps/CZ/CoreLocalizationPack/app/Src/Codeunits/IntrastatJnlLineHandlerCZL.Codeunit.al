#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using System.Security.User;

codeunit 31025 "Intrastat Jnl.Line Handler CZL"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    var
        Item: Record Item;
        TariffNumber: Record "Tariff Number";
        UnitOfMeasureManagement: Codeunit "Unit of Measure Management";
        DefaultPartnerIdTok: Label 'QV123', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnAfterValidateEvent', 'Tariff No.', false, false)]
    local procedure ClearStatisticIndicationCZLOnAfterTariffNoValidate(var Rec: Record "Intrastat Jnl. Line")
    begin
        Rec."Statistic Indication CZL" := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnAfterValidateEvent', 'Net Weight', false, false)]
    local procedure CalcSupplemUoMNetWeightCZLOnAfterNetWeightValidate(var Rec: Record "Intrastat Jnl. Line")
    begin
        if Item.Get(Rec."Item No.") then
            if Rec."Supplementary Units" then
                Rec."Supplem. UoM Net Weight CZL" :=
                    Rec."Net Weight" * UnitOfMeasureManagement.GetQtyPerUnitOfMeasure(Item, Rec."Supplem. UoM Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure CalcTotalWeightAndSupplemUoMQuantityCZLOnAfterQuantityValidate(var Rec: Record "Intrastat Jnl. Line")
    begin
        Rec."Total Weight" := Rec.RoundValueCZL(Rec."Net Weight" * Rec.Quantity);
        if Item.Get(Rec."Item No.") then
            if Rec."Supplementary Units" then
                Rec."Supplem. UoM Quantity CZL" :=
                    Rec.Quantity / UnitOfMeasureManagement.GetQtyPerUnitOfMeasure(Item, Rec."Supplem. UoM Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnAfterValidateEvent', 'Indirect Cost', false, false)]
    local procedure UpdateStatisticalValueOnAfterIndirectCostValidate(var Rec: Record "Intrastat Jnl. Line")
    begin
        Rec.Validate("Statistical Value", Rec.Amount + Rec."Indirect Cost");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnBeforeValidateEvent', 'Item No.', false, false)]
    local procedure GetItemDetailsOnBeforeItemNoValidate(var Rec: Record "Intrastat Jnl. Line")
    begin
        if Rec."Item No." = '' then
            Clear(Item)
        else
            Item.Get(Rec."Item No.");

        Rec.Validate("Net Weight", Item."Net Weight");
        Rec.Validate("Tariff No.", Item."Tariff No.");
        Rec."Base Unit of Measure CZL" := Item."Base Unit of Measure";
        Rec."Statistic Indication CZL" := Item."Statistic Indication CZL";
        Rec."Specific Movement CZL" := Item."Specific Movement CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnBeforeGetItemDescription', '', false, false)]
    local procedure GetItemDescription(var Sender: Record "Intrastat Jnl. Line"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if Sender."Tariff No." <> '' then begin
            TariffNumber.Get(Sender."Tariff No.");
            if TariffNumber."Supplementary Units" then begin
                TariffNumber.TestField("Suppl. Unit of Meas. Code CZL");
                Sender."Supplem. UoM Code CZL" := TariffNumber."Suppl. Unit of Meas. Code CZL";
            end else
                Sender."Supplem. UoM Code CZL" := '';
            Sender."Item Description" := TariffNumber.Description;
            Sender."Supplementary Units" := TariffNumber."Supplementary Units";
        end else begin
            Sender."Item Description" := '';
            Sender."Supplementary Units" := false;
            Sender."Supplem. UoM Code CZL" := '';
        end;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntraJnlManagement, 'OnBeforeOpenJnl', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJnl(var IntrastatJnlLine: Record "Intrastat Jnl. Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := IntrastatJnlLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"Intrastat Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnAfterGetCountryOfOriginCode', '', false, false)]
    local procedure GetCountryOfOriginCode(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; var CountryOfOriginCode: Code[10])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        if StatutoryReportingSetupCZL."Get Country/Region of Origin" = StatutoryReportingSetupCZL."Get Country/Region of Origin"::"Item Card" then
            exit;
        if not ItemLedgerEntry.Get(IntrastatJnlLine."Source Entry No.") then
            exit;
        CountryOfOriginCode := ItemLedgerEntry."Country/Reg. of Orig. Code CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnBeforeGetPartnerIDForCountry', '', false, false)]
    local procedure GetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    var
        CountryRegion: Record "Country/Region";
    begin
        if IsHandled then
            exit;

        PartnerID := DefaultPartnerIdTok;
        IsHandled := true;

        if IsPrivatePerson then
            exit;

        if IsThirdPartyTrade then
            exit;

        if CountryRegionCode = '' then
            exit;

        if VATRegistrationNo = '' then
            exit;

        if not CountryRegion.Get(CountryRegionCode) then
            exit;

        if not CountryRegion.IsEUCountry(CountryRegionCode) then
            exit;

        PartnerID := '';
        IsHandled := false;
    end;
}
#endif
