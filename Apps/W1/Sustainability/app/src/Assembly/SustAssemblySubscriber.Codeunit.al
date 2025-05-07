namespace Microsoft.Sustainability.Assembly;

using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Assembly.Posting;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

codeunit 6255 "Sust. Assembly Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterCopyFromItem', '', false, false)]
    local procedure OnAfterCopyFromItem(var AssemblyLine: Record "Assembly Line"; Item: Record Item)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then begin
            AssemblyLine.SuspendUpdateCO2eInAssemblyHeader(true);
            AssemblyLine.Validate("Sust. Account No.", Item."Default Sust. Account");
            AssemblyLine.SuspendUpdateCO2eInAssemblyHeader(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnAfterValidateEvent', "Item No.", false, false)]
    local procedure OnAfterValidateNoEventOnAssemblyHeader(var Rec: Record "Assembly Header")
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            UpdateDefaultSustAccOnAssemblyHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterCopyFromResource', '', false, false)]
    local procedure OnAfterCopyFromResource(var AssemblyLine: Record "Assembly Line"; Resource: Record Resource)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then begin
            AssemblyLine.SuspendUpdateCO2eInAssemblyHeader(true);
            AssemblyLine.Validate("Sust. Account No.", Resource."Default Sust. Account");
            AssemblyLine.SuspendUpdateCO2eInAssemblyHeader(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterValidateEvent', "No.", false, false)]
    local procedure OnAfterValidateNoEvent(var Rec: Record "Assembly Line"; var xRec: Record "Assembly Line")
    begin
        if Rec."No." = '' then
            if (Rec."Sust. Account No." <> '') or (xRec."Sust. Account No." <> '') then
                Rec.Validate("Sust. Account No.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnAfterUpdateAssemblyLines', '', false, false)]
    local procedure OnAfterUpdateAssemblyLines(var AsmHeader: Record "Assembly Header")
    begin
        AsmHeader.UpdateCO2eInformation(AsmHeader, 0, 0, false, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterInitQtyToConsume', '', false, false)]
    local procedure OnAfterInitQtyToConsume(var AssemblyLine: Record "Assembly Line"; CurrentFieldNo: Integer)
    begin
        AssemblyLine.UpdateSustainabilityEmission(AssemblyLine);
        if CurrentFieldNo = AssemblyLine.FieldNo("Quantity per") then
            AssemblyLine.UpdateCO2ePerUnitOnAssemblyHeader(AssemblyLine, AssemblyLine."Line No.", AssemblyLine."Total CO2e", true, (AssemblyLine."Sust. Account No." <> ''), true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterValidateEvent', "Total CO2e", false, false)]
    local procedure OnAfterValidateEvent(var Rec: Record "Assembly Line"; var xRec: Record "Assembly Line")
    begin
        Rec.UpdateCO2ePerUnitOnAssemblyHeader(Rec, Rec."Line No.", Rec."Total CO2e", true, (Rec."Sust. Account No." <> ''), true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteEvent(var Rec: Record "Assembly Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary() then
            exit;

        if not Rec.GetSuspendDeletionCheck() then
            Rec.UpdateCO2ePerUnitOnAssemblyHeader(Rec, 0, 0, false, false, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterCreateItemJnlLineFromAssemblyHeader', '', false, false)]
    local procedure OnAfterCreateItemJnlLineFromAssemblyHeader(var ItemJournalLine: Record "Item Journal Line"; AssemblyHeader: Record "Assembly Header")
    begin
        if (ItemJournalLine.Quantity <> 0) then
            UpdateSustainabilityItemJournalLineForOutput(ItemJournalLine, AssemblyHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnBeforePostItemConsumption', '', false, false)]
    local procedure OnBeforePostItemConsumption(var ItemJournalLine: Record "Item Journal Line"; var AssemblyHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line")
    begin
        if (ItemJournalLine.Quantity <> 0) then
            UpdateSustainabilityItemJournalLineForConsumption(ItemJournalLine, AssemblyLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterCreateItemJnlLineFromAssemblyLine', '', false, false)]
    local procedure OnAfterCreateItemJnlLineFromAssemblyLine(var ItemJournalLine: Record "Item Journal Line"; AssemblyLine: Record "Assembly Line")
    begin
        if (ItemJournalLine.Quantity <> 0) then
            UpdateSustainabilityItemJournalLineForConsumption(ItemJournalLine, AssemblyLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnPostHeaderOnAfterPostItemOutput', '', false, false)]
    local procedure OnPostHeaderOnAfterPostItemOutput(var AssemblyHeader: Record "Assembly Header"; var HeaderQtyBase: Decimal)
    begin
        UpdatePostedSustainabilityTotalCO2eOnAssemblyHeader(AssemblyHeader, HeaderQtyBase);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnBeforeAssemblyLineModify', '', false, false)]
    local procedure OnBeforeAssemblyLineModify(var AssemblyLine: Record "Assembly Line"; QtyToConsumeBase: Decimal)
    begin
        UpdatePostedSustainabilityTotalCO2eOnAssemblyLine(AssemblyLine, QtyToConsumeBase);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnUndoPostHeaderOnAfterTransferFields', '', false, false)]
    local procedure OnUndoPostHeaderOnAfterTransferFields(PostedAssemblyHeader: Record "Posted Assembly Header"; var AssemblyHeader: Record "Assembly Header")
    begin
        UpdatePostedSustainabilityTotalCO2eOnAssemblyHeader(AssemblyHeader, -AssemblyHeader."Quantity (Base)");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnUndoPostLinesOnAfterTransferFields', '', false, false)]
    local procedure OnUndoPostLinesOnAfterTransferFields(var AssemblyLine: Record "Assembly Line"; PostedAssemblyHeader: Record "Posted Assembly Header")
    begin
        UpdatePostedSustainabilityTotalCO2eOnAssemblyLine(AssemblyLine, -AssemblyLine."Quantity (Base)");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterPostedAssemblyHeaderModify', '', false, false)]
    local procedure OnAfterPostedAssemblyHeaderModify(var PostedAssemblyHeader: Record "Posted Assembly Header"; AssemblyHeader: Record "Assembly Header")
    begin
        UpdatePostedSustainabilityEmission(AssemblyHeader."CO2e per Unit", AssemblyHeader."Qty. per Unit of Measure", PostedAssemblyHeader.Quantity, 1, PostedAssemblyHeader."Total CO2e");
        PostedAssemblyHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnBeforePostedAssemblyLineInsert', '', false, false)]
    local procedure OnAfterPostedAssemblyLineInsert(AssemblyLine: Record "Assembly Line"; var PostedAssemblyLine: Record "Posted Assembly Line")
    begin
        UpdatePostedSustainabilityEmission(AssemblyLine."CO2e per Unit", AssemblyLine."Qty. per Unit of Measure", PostedAssemblyLine.Quantity, 1, PostedAssemblyLine."Total CO2e");
    end;

    local procedure UpdateDefaultSustAccOnAssemblyHeader(var AssemblyHeader: Record "Assembly Header")
    var
        Item: Record Item;
    begin
        if AssemblyHeader."Item No." = '' then
            AssemblyHeader.Validate("Sust. Account No.", '')
        else begin
            Item.Get(AssemblyHeader."Item No.");

            AssemblyHeader.Validate("Sust. Account No.", Item."Default Sust. Account");
        end;
    end;

    local procedure UpdateSustainabilityItemJournalLineForOutput(var ItemJournalLine: Record "Item Journal Line"; var AssemblyHeader: Record "Assembly Header")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        GHGCredit := IsGHGCreditLine(AssemblyHeader."Item No.");
        Sign := GetPostingSign(ItemJournalLine.Quantity, 0, GHGCredit);

        CO2eToPost := AssemblyHeader."CO2e per Unit" * ItemJournalLine.Quantity * AssemblyHeader."Qty. per Unit of Measure" * Sign;
        if not CanPostSustainabilityJnlLine(AssemblyHeader."Sust. Account No.", AssemblyHeader."Sust. Account Category", AssemblyHeader."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := AssemblyHeader."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := AssemblyHeader."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := AssemblyHeader."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := AssemblyHeader."Sust. Account Subcategory";
        ItemJournalLine."CO2e per Unit" := AssemblyHeader."CO2e per Unit";
        ItemJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdateSustainabilityItemJournalLineForConsumption(var ItemJournalLine: Record "Item Journal Line"; var AssemblyLine: Record "Assembly Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        if AssemblyLine.Type = AssemblyLine.Type::Item then
            GHGCredit := IsGHGCreditLine(AssemblyLine."No.");

        Sign := GetPostingSign(0, ItemJournalLine.Quantity, GHGCredit);

        CO2eToPost := AssemblyLine."CO2e per Unit" * ItemJournalLine.Quantity * AssemblyLine."Qty. per Unit of Measure" * Sign;
        if not CanPostSustainabilityJnlLine(AssemblyLine."Sust. Account No.", AssemblyLine."Sust. Account Category", AssemblyLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := AssemblyLine."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := AssemblyLine."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := AssemblyLine."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := AssemblyLine."Sust. Account Subcategory";
        ItemJournalLine."CO2e per Unit" := AssemblyLine."CO2e per Unit";
        ItemJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdatePostedSustainabilityEmission(CO2ePerUnit: Decimal; QtyPerUnitOfMeasure: Decimal; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2e: Decimal)
    begin
        PostedEmissionCO2e := (CO2ePerUnit * Abs(Quantity) * QtyPerUnitOfMeasure) * Sign;
    end;

    local procedure UpdatePostedSustainabilityTotalCO2eOnAssemblyHeader(var AssemblyHeader: Record "Assembly Header"; QtyToOutputBase: Decimal)
    var
        GHGCredit: Boolean;
        CO2eToPost: Decimal;
        Sign: Integer;
    begin
        if (QtyToOutputBase = 0) then
            exit;

        GHGCredit := IsGHGCreditLine(AssemblyHeader."Item No.");

        Sign := GetPostingSign(QtyToOutputBase, 0, GHGCredit);
        CO2eToPost := AssemblyHeader."CO2e per Unit" * QtyToOutputBase * AssemblyHeader."Qty. per Unit of Measure" * Sign;

        AssemblyHeader."Posted Total CO2e" += CO2eToPost;
    end;

    local procedure UpdatePostedSustainabilityTotalCO2eOnAssemblyLine(var AssemblyLine: Record "Assembly Line"; QtyToConsumeBase: Decimal)
    var
        GHGCredit: Boolean;
        CO2eToPost: Decimal;
        Sign: Integer;
    begin
        if (QtyToConsumeBase = 0) then
            exit;

        if AssemblyLine.Type = AssemblyLine.Type::Item then
            GHGCredit := IsGHGCreditLine(AssemblyLine."No.");

        Sign := GetPostingSign(0, QtyToConsumeBase, GHGCredit);
        CO2eToPost := AssemblyLine."CO2e per Unit" * QtyToConsumeBase * AssemblyLine."Qty. per Unit of Measure" * Sign;
        AssemblyLine."Posted Total CO2e" += CO2eToPost;
    end;

    local procedure GetPostingSign(QtyToOutPut: Decimal; QtyToConsume: Decimal; GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        if QtyToConsume <> 0 then
            if not GHGCredit then
                Sign := -1;

        if QtyToOutPut <> 0 then
            if GHGCredit then
                Sign := -1;

        exit(Sign);
    end;

    local procedure IsGHGCreditLine(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if ItemNo = '' then
            exit(false);

        Item.Get(ItemNo);

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
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in Assembly document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}