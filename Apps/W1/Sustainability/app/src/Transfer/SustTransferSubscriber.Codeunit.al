namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Transfer;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

codeunit 6258 "Sust. Transfer Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnValidateItemNoOnCopyFromTempTransLine', '', false, false)]
    local procedure OnValidateItemNoOnCopyFromTempTransLine(var TransferLine: Record "Transfer Line")
    begin
        if TransferLine."Item No." = '' then
            TransferLine.Validate("Sust. Account No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValues(var TransferLine: Record "Transfer Line"; Item: Record Item)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            TransferLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnValidateQuantityOnAfterCalcQuantityBase', '', false, false)]
    local procedure OnValidateQuantityOnAfterCalcQuantityBase(var TransferLine: Record "Transfer Line")
    begin
        TransferLine.UpdateSustainabilityEmission(TransferLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure OnPostItemJnlLineOnAfterPrepareShipmentItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        if (ItemJournalLine.Quantity <> 0) then begin
            UpdateSustainabilityItemJournalLine(ItemJournalLine, TransferLine);
            UpdatePostedSustainabilityEmissionOrderLine(TransferLine, ItemJournalLine.Quantity, true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptLine', '', false, false)]
    local procedure OnBeforeInsertTransShptLine(TransShptHeader: Record "Transfer Shipment Header"; TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    begin
        CopyTransShipmentLineFromTransLine(TransLine, TransShptLine);
        UpdatePostedSustainabilityEmission(TransLine, TransShptLine.Quantity, 1, TransShptLine."Total CO2e");
    end;

    local procedure CopyTransShipmentLineFromTransLine(TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    begin
        TransShptLine."Sust. Account No." := TransLine."Sust. Account No.";
        TransShptLine."Sust. Account Name" := TransLine."Sust. Account Name";
        TransShptLine."Sust. Account Category" := TransLine."Sust. Account Category";
        TransShptLine."Sust. Account Subcategory" := TransLine."Sust. Account Subcategory";
        TransShptLine."CO2e per Unit" := TransLine."CO2e per Unit";
    end;

    local procedure UpdateSustainabilityItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; var TransferLine: Record "Transfer Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        GHGCredit := IsGHGCreditLine(TransferLine);

        Sign := GetPostingSign(ItemJournalLine."Document Type" = ItemJournalLine."Document Type"::"Transfer Shipment", GHGCredit);

        CO2eToPost := TransferLine."CO2e per Unit" * Abs(ItemJournalLine.Quantity) * TransferLine."Qty. per Unit of Measure";

        CO2eToPost := CO2eToPost * Sign;

        if not CanPostSustainabilityJnlLine(TransferLine."Sust. Account No.", TransferLine."Sust. Account Category", TransferLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := TransferLine."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := TransferLine."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := TransferLine."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := TransferLine."Sust. Account Subcategory";
        ItemJournalLine."CO2e per Unit" := TransferLine."CO2e per Unit";
        ItemJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdatePostedSustainabilityEmissionOrderLine(var TransferLine: Record "Transfer Line"; Qty: Decimal; Ship: Boolean)
    var
        PostedEmissionCO2e: Decimal;
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        GHGCredit := IsGHGCreditLine(TransferLine);
        Sign := GetPostingSign(Ship, GHGCredit);

        UpdatePostedSustainabilityEmission(TransferLine, Qty, Sign, PostedEmissionCO2e);

        if Ship then
            TransferLine."Posted Shipped Total CO2e" += PostedEmissionCO2e;

        if ((Qty + TransferLine."Quantity Shipped") = TransferLine.Quantity) then
            TransferLine."Total CO2e" := 0;

        TransferLine.Modify();
    end;

    local procedure UpdatePostedSustainabilityEmission(TransferLine: Record "Transfer Line"; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2e: Decimal)
    begin
        PostedEmissionCO2e := (TransferLine."CO2e per Unit" * Abs(Quantity) * TransferLine."Qty. per Unit of Measure") * Sign;
    end;

    local procedure GetPostingSign(Ship: Boolean; GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        if Ship then
            if not GHGCredit then
                Sign := 1;

        exit(Sign);
    end;

    local procedure IsGHGCreditLine(TransLine: Record "Transfer Line"): Boolean
    var
        Item: Record Item;
    begin
        if TransLine."Item No." = '' then
            exit(false);

        Item.Get(TransLine."Item No.");

        exit(Item."GHG Credit");
    end;

    local procedure CanPostSustainabilityJnlLine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; CO2eToPost: Decimal): Boolean
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if AccountNo = '' then
            exit(false);

        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit(false);

        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustLedEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2eToPost = 0) then
                    Error(CO2eMustNotBeZeroErr);

        if (CO2eToPost <> 0) then
            exit(true);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in sales document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}