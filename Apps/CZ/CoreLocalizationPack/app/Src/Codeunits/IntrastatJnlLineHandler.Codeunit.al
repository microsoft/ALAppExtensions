codeunit 31025 "Intrastat Jnl.Line Handler CZL"
{
    var
        Item: Record Item;
        TariffNumber: Record "Tariff Number";
        UnitOfMeasureManagement: Codeunit "Unit of Measure Management";

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
#if not CLEAN18
            TariffNumber.CalcFields("Supplementary Units");
#endif
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
}