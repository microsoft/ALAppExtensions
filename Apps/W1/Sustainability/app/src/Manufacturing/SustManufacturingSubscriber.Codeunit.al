namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Posting;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Journal;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Sustainability.Setup;

codeunit 6254 "Sust. Manufacturing Subscriber"
{

    [EventSubscriber(ObjectType::Table, Database::"Routing Line", 'OnAfterWorkCenterTransferFields', '', false, false)]
    local procedure OnAfterWorkCenterTransferFields(var RoutingLine: Record "Routing Line"; WorkCenter: Record "Work Center")
    begin
        RoutingLine.Validate("CO2e per Unit", WorkCenter."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Routing Line", 'OnAfterMachineCtrTransferFields', '', false, false)]
    local procedure OnAfterMachineCtrTransferFields(var RoutingLine: Record "Routing Line"; MachineCenter: Record "Machine Center")
    begin
        RoutingLine.Validate("CO2e per Unit", MachineCenter."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Line", 'OnValidateNoOnAfterAssignItemFields', '', false, false)]
    local procedure OnValidateNoOnAfterAssignItemFields(var ProductionBOMLine: Record "Production BOM Line"; Item: Record Item)
    begin
        ProductionBOMLine.Validate("CO2e per Unit", Item."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnValidateItemNoOnAfterAssignItemValues', '', false, false)]
    local procedure OnValidateItemNoOnAfterAssignItemValues(Item: Record Item; var ProdOrderLine: Record "Prod. Order Line")
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            ProdOrderLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Component", 'OnValidateItemNoOnAfterUpdateUOMFromItem', '', false, false)]
    local procedure OnValidateItemNoOnAfterUpdateUOMFromItem(var ProdOrderComponent: Record "Prod. Order Component"; Item: Record Item)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            ProdOrderComponent.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnAfterWorkCenterTransferFields', '', false, false)]
    local procedure OnAfterWorkCenterTransferProdOrderRoutingLineFields(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; WorkCenter: Record "Work Center")
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            ProdOrderRoutingLine.Validate("Sust. Account No.", WorkCenter."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnAfterMachineCtrTransferFields', '', false, false)]
    local procedure OnAfterMachineCtrTransferProdOrderRoutingLineFields(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; MachineCenter: Record "Machine Center")
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            ProdOrderRoutingLine.Validate("Sust. Account No.", MachineCenter."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnAfterValidateEvent', "No.", false, false)]
    local procedure OnAfterSetRecalcStatus(var Rec: Record "Prod. Order Routing Line")
    begin
        if Rec."No." = '' then
            Rec.Validate("Sust. Account No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Component", 'OnAfterValidateEvent', "Item No.", false, false)]
    local procedure OnAfterValidateNoEventOnProdOrderComponent(var Rec: Record "Prod. Order Component")
    begin
        if (Rec."Item No." = '') and (Rec."Sust. Account No." <> '') then
            Rec.Validate("Sust. Account No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnValidateQuantityOnAfterCalcBaseQty', '', false, false)]
    local procedure OnValidateQuantityOnAfterCalcBaseQty(var ProdOrderLine: Record "Prod. Order Line")
    begin
        ProdOrderLine.UpdateSustainabilityEmission(ProdOrderLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Component", 'OnValidateExpectedQuantityOnAfterCalcActConsumptionQty', '', false, false)]
    local procedure OnValidateExpectedQuantityOnAfterCalcActConsumptionQty(var ProdOrderComp: Record "Prod. Order Component")
    begin
        ProdOrderComp.UpdateSustainabilityEmission(ProdOrderComp);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Routing Line", 'OnBeforeCalcExpectedCost', '', false, false)]
    local procedure OnBeforeCalcExpectedCost(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
        ProdOrderRoutingLine.UpdateSustainabilityEmission(ProdOrderRoutingLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", 'OnAfterTransferBOMComponent', '', false, false)]
    local procedure OnAfterTransferBOMComponent(var ProdOrderLine: Record "Prod. Order Line"; var ProductionBOMLine: Record "Production BOM Line"; var ProdOrderComponent: Record "Prod. Order Component")
    begin
        if ProdOrderComponent."Sust. Account No." <> '' then
            ProdOrderComponent.Validate("CO2e per Unit", ProductionBOMLine."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", 'OnBeforeProdOrderCompModify', '', false, false)]
    local procedure OnBeforeProdOrderCompModify(var ProdBOMLine: Record "Production BOM Line"; var ProdOrderComp: Record "Prod. Order Component")
    begin
        if ProdOrderComp."Sust. Account No." <> '' then
            ProdOrderComp.Validate("CO2e per Unit", ProdBOMLine."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", 'OnAfterCalculate', '', false, false)]
    local procedure OnAfterCalculate(ProdOrderLine: Record "Prod. Order Line")
    begin
        if ProdOrderLine."Sust. Account No." <> '' then begin
            ProdOrderLine.CalcFields("Expected Operation Total CO2e", "Expected Component Total CO2e");
            ProdOrderLine.Validate(
                "CO2e per Unit",
                (ProdOrderLine."Expected Operation Total CO2e" + ProdOrderLine."Expected Component Total CO2e") / ProdOrderLine.Quantity);
            ProdOrderLine.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Production Journal Mgt", 'OnBeforeInsertOutputJnlLine', '', false, false)]
    local procedure OnBeforeInsertOutputJnlLine(var ItemJournalLine: Record "Item Journal Line"; ProdOrderRtngLine: Record "Prod. Order Routing Line")
    begin
        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit;

        ItemJournalLine.Validate("Sust. Account No.", ProdOrderRtngLine."Sust. Account No.");
        ItemJournalLine.Validate("Sust. Account Name", ProdOrderRtngLine."Sust. Account Name");
        ItemJournalLine.Validate("Sust. Account Category", ProdOrderRtngLine."Sust. Account Category");
        ItemJournalLine.Validate("Sust. Account Subcategory", ProdOrderRtngLine."Sust. Account Subcategory");
        ItemJournalLine.Validate("CO2e per Unit", ProdOrderRtngLine."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", 'OnAfterTransferRoutingLine', '', false, false)]
    local procedure OnAfterTransferRoutingLine(var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var RoutingLine: Record "Routing Line")
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            UpdateEmissionOnProdOrderRoutingLineFromRoutingLine(ProdOrderRoutingLine, RoutingLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Production Journal Mgt", 'OnBeforeInsertConsumptionJnlLine', '', false, false)]
    local procedure OnBeforeInsertConsumptionJnlLine(var ItemJournalLine: Record "Item Journal Line"; ProdOrderComp: Record "Prod. Order Component")
    begin
        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit;

        ItemJournalLine.Validate("Sust. Account No.", ProdOrderComp."Sust. Account No.");
        ItemJournalLine.Validate("Sust. Account Name", ProdOrderComp."Sust. Account Name");
        ItemJournalLine.Validate("Sust. Account Category", ProdOrderComp."Sust. Account Category");
        ItemJournalLine.Validate("Sust. Account Subcategory", ProdOrderComp."Sust. Account Subcategory");
        ItemJournalLine.Validate("CO2e per Unit", ProdOrderComp."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateQuantityOnBeforeGetUnitAmount', '', false, false)]
    local procedure OnValidateQuantityOnBeforeGetUnitAmount(var ItemJournalLine: Record "Item Journal Line")
    begin
        if ItemJournalLine."Entry Type" in [ItemJournalLine."Entry Type"::Output, ItemJournalLine."Entry Type"::Consumption] then
            ItemJournalLine.UpdateSustainabilityEmission(ItemJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', "Run Time", false, false)]
    local procedure OnAfterValidateRunTimeEvent(var Rec: Record "Item Journal Line")
    begin
        if Rec."Entry Type" in [Rec."Entry Type"::Output] then
            Rec.UpdateSustainabilityEmission(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', "Setup Time", false, false)]
    local procedure OnAfterValidateSetupTimeEvent(var Rec: Record "Item Journal Line")
    begin
        if Rec."Entry Type" in [Rec."Entry Type"::Output] then
            Rec.UpdateSustainabilityEmission(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', "Stop Time", false, false)]
    local procedure OnAfterValidateStopTimeEvent(var Rec: Record "Item Journal Line")
    begin
        if Rec."Entry Type" in [Rec."Entry Type"::Output] then
            Rec.UpdateSustainabilityEmission(Rec);
    end;

#if not CLEAN27
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnPostOutputOnBeforePostItem', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Item Jnl.-Post Line", 'OnPostOutputOnBeforePostItem', '', false, false)]
#endif
    local procedure OnPostOutputOnBeforePostItem(var ItemJournalLine: Record "Item Journal Line"; var ProdOrderLine: Record "Prod. Order Line"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        UpdateEmissionOnItemJournalLineFromProdOrderLine(ItemJournalLine, ProdOrderLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertCapLedgEntry', '', false, false)]
    local procedure OnBeforeInsertCapLedgEntry(ItemJournalLine: Record "Item Journal Line"; var CapLedgEntry: Record "Capacity Ledger Entry")
    begin
        CapLedgEntry."Sust. Account No." := ItemJournalLine."Sust. Account No.";
        CapLedgEntry."Sust. Account Name" := ItemJournalLine."Sust. Account Name";
        CapLedgEntry."Sust. Account Category" := ItemJournalLine."Sust. Account Category";
        CapLedgEntry."Sust. Account Subcategory" := ItemJournalLine."Sust. Account Subcategory";
        CapLedgEntry."CO2e per Unit" := ItemJournalLine."CO2e per Unit";
        CapLedgEntry."Total CO2e" := ItemJournalLine."Total CO2e";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterOnValidateItemNoAssignByEntryType', '', false, false)]
    local procedure OnAfterOnValidateItemNoAssignByEntryType(var ItemJournalLine: Record "Item Journal Line")
    begin
        UpdateEmissionOnItemJournalLineForConsumption(ItemJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateCapUnitofMeasureCodeOnBeforeRoutingCostPerUnit', '', false, false)]
    local procedure OnValidateCapUnitofMeasureCodeOnBeforeRoutingCostPerUnit(var ItemJournalLine: Record "Item Journal Line"; var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit;

        ItemJournalLine.Validate("Sust. Account No.", ProdOrderRoutingLine."Sust. Account No.");
        ItemJournalLine.Validate("Sust. Account Name", ProdOrderRoutingLine."Sust. Account Name");
        ItemJournalLine.Validate("Sust. Account Category", ProdOrderRoutingLine."Sust. Account Category");
        ItemJournalLine.Validate("Sust. Account Subcategory", ProdOrderRoutingLine."Sust. Account Subcategory");
        ItemJournalLine.Validate("CO2e per Unit", ProdOrderRoutingLine."CO2e per Unit");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnAfterCreateDimInitial', '', false, false)]
    local procedure OnValidateItemNoOnAfterCreateDimInitial(var ItemJournalLine: Record "Item Journal Line")
    begin
        if ItemJournalLine."Sust. Account No." <> '' then
            ItemJournalLine.Validate("Sust. Account No.", '');
    end;

#if not CLEAN27
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnPostConsumptionOnBeforeCalcRemainingQuantity', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Item Jnl.-Post Line", 'OnPostConsumptionOnBeforeCalcRemainingQuantity', '', false, false)]
#endif
    local procedure OnPostConsumptionOnBeforeCalcRemainingQuantity(var ProdOrderComp: Record "Prod. Order Component"; var ItemJnlLine: Record "Item Journal Line"; var QtyToPost: Decimal)
    begin
        if (ItemJnlLine."Sust. Account No." <> '') and (QtyToPost <> 0) then
            ProdOrderComp."Posted Total CO2e" += ItemJnlLine.GetPostingSign(ItemJnlLine.IsGHGCreditLine()) * ItemJnlLine."Total CO2e";
    end;

#if not CLEAN27
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnPostOutputOnBeforeProdOrderRtngLineModify', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Item Jnl.-Post Line", 'OnPostOutputOnBeforeProdOrderRtngLineModify', '', false, false)]
#endif
    local procedure OnPostOutputOnBeforeProdOrderRtngLineModify(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var ItemJournalLine: Record "Item Journal Line")
    begin
        if (ItemJournalLine."Sust. Account No." <> '') then
            ProdOrderRoutingLine."Posted Total CO2e" += ItemJournalLine.GetPostingSign(ItemJournalLine.IsGHGCreditLine()) * ItemJournalLine."Total CO2e";
    end;

#if not CLEAN27
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeProdOrderLineModify', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Item Jnl.-Post Line", 'OnBeforeProdOrderLineModify', '', false, false)]
#endif
    local procedure OnBeforeProdOrderLineModify(var ProdOrderLine: Record "Prod. Order Line"; ItemJournalLine: Record "Item Journal Line")
    begin
        if (ItemJournalLine."Sust. Account No." <> '') then
            ProdOrderLine."Posted Total CO2e" += ItemJournalLine.GetPostingSign(ItemJournalLine.IsGHGCreditLine()) * ItemJournalLine."Total CO2e";
    end;

    local procedure UpdateEmissionOnItemJournalLineFromProdOrderLine(var ItemJournalLine: Record "Item Journal Line"; ProdOrderLine: Record "Prod. Order Line")
    begin
        if not (ItemJournalLine."Entry Type" in [ItemJournalLine."Entry Type"::Output]) then
            exit;

        if (ItemJournalLine."Item No." = '') then
            exit;

        if (ItemJournalLine."Order Type" <> ItemJournalLine."Order Type"::Production) then
            exit;

        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit;

        ItemJournalLine.Validate("Sust. Account No.", '');
        if ProdOrderLine."Sust. Account No." <> '' then begin
            ItemJournalLine.Validate("Sust. Account No.", ProdOrderLine."Sust. Account No.");
            ItemJournalLine.Validate("Sust. Account Name", ProdOrderLine."Sust. Account Name");
            ItemJournalLine.Validate("Sust. Account Category", ProdOrderLine."Sust. Account Category");
            ItemJournalLine.Validate("Sust. Account Subcategory", ProdOrderLine."Sust. Account Subcategory");
            ItemJournalLine.Validate("CO2e per Unit", ProdOrderLine."CO2e per Unit");
            ItemJournalLine."Total CO2e" := ProdOrderLine."CO2e per Unit" * ItemJournalLine."Qty. per Unit of Measure" * ItemJournalLine.Quantity;
        end;
    end;

    local procedure UpdateEmissionOnItemJournalLineForConsumption(var ItemJournalLine: Record "Item Journal Line")
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        if (ItemJournalLine."Order Type" <> ItemJournalLine."Order Type"::Production) then
            exit;

        if not (ItemJournalLine."Entry Type" in [ItemJournalLine."Entry Type"::Consumption]) then
            exit;

        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit;

        if ProdOrderComponent.Get(ProdOrderComponent.Status::Released, ItemJournalLine."Order No.", ItemJournalLine."Order Line No.", ItemJournalLine."Prod. Order Comp. Line No.") then
            if ProdOrderComponent."Sust. Account No." <> '' then begin
                ItemJournalLine.Validate("Sust. Account No.", ProdOrderComponent."Sust. Account No.");
                ItemJournalLine.Validate("Sust. Account Name", ProdOrderComponent."Sust. Account Name");
                ItemJournalLine.Validate("Sust. Account Category", ProdOrderComponent."Sust. Account Category");
                ItemJournalLine.Validate("Sust. Account Subcategory", ProdOrderComponent."Sust. Account Subcategory");
                ItemJournalLine.Validate("CO2e per Unit", ProdOrderComponent."CO2e per Unit");
            end
    end;

    local procedure UpdateEmissionOnProdOrderRoutingLineFromRoutingLine(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; RoutingLine: Record "Routing Line")
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
    begin
        case ProdOrderRoutingLine.Type of
            ProdOrderRoutingLine.Type::"Machine Center":
                begin
                    MachineCenter.Get(ProdOrderRoutingLine."No.");
                    if MachineCenter."Default Sust. Account" = '' then
                        exit;

                    ProdOrderRoutingLine.Validate("Sust. Account No.", MachineCenter."Default Sust. Account");
                    ProdOrderRoutingLine.Validate("CO2e per Unit", RoutingLine."CO2e per Unit");
                end;
            ProdOrderRoutingLine.Type::"Work Center":
                begin
                    WorkCenter.Get(ProdOrderRoutingLine."No.");
                    if WorkCenter."Default Sust. Account" = '' then
                        exit;

                    ProdOrderRoutingLine.Validate("Sust. Account No.", WorkCenter."Default Sust. Account");
                    ProdOrderRoutingLine.Validate("CO2e per Unit", RoutingLine."CO2e per Unit");
                end;
        end;
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
}