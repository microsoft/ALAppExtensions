namespace Microsoft.Sustainability.Assembly;

using Microsoft.Assembly.Document;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Inventory.Journal;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Assembly.Posting;
using Microsoft.Assembly.History;

codeunit 6255 "Sust. Assembly Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterCopyFromItem', '', false, false)]
    local procedure OnAfterCopyFromItem(var AssemblyLine: Record "Assembly Line"; Item: Record Item)
    begin
        AssemblyLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnAfterValidateEvent', "Item No.", false, false)]
    local procedure OnAfterValidateNoEventOnAssemblyHeader(var Rec: Record "Assembly Header")
    begin
        UpdateDefaultSustAccOnAssemblyHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterCopyFromResource', '', false, false)]
    local procedure OnAfterCopyFromResource(var AssemblyLine: Record "Assembly Line"; Resource: Record Resource)
    begin
        AssemblyLine.Validate("Sust. Account No.", Resource."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterValidateEvent', "No.", false, false)]
    local procedure OnAfterValidateNoEvent(var Rec: Record "Assembly Line")
    begin
        if Rec."No." = '' then
            if Rec."Sust. Account No." <> '' then
                Rec.Validate("Sust. Account No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnValiateQuantityOnAfterCalcBaseQty', '', false, false)]
    local procedure OnValiateQuantityOnAfterCalcBaseQty(var AssemblyHeader: Record "Assembly Header")
    begin
        AssemblyHeader.UpdateSustainabilityEmission(AssemblyHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterInitQtyToConsume', '', false, false)]
    local procedure OnAfterInitQtyToConsume(var AssemblyLine: Record "Assembly Line")
    begin
        AssemblyLine.UpdateSustainabilityEmission(AssemblyLine);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnPostHeaderOnAfterPostItemOutput', '', false, false)]
    local procedure OnPostHeaderOnAfterPostItemOutput(var AssemblyHeader: Record "Assembly Header"; var HeaderQtyBase: Decimal)
    var
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        if PostedAssemblyHeader.Get(AssemblyHeader."Posting No.") then
            PostSustainabilityLineForOutput(AssemblyHeader, PostedAssemblyHeader."Posting Date", HeaderQtyBase, PostedAssemblyHeader."Source Code", AssemblyHeader."Posting No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnBeforeAssemblyLineModify', '', false, false)]
    local procedure OnBeforeAssemblyLineModify(var AssemblyLine: Record "Assembly Line"; QtyToConsumeBase: Decimal)
    var
        AssemblyHeader: Record "Assembly Header";
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        if AssemblyHeader.Get(AssemblyLine."Document Type", AssemblyLine."Document No.") and PostedAssemblyHeader.Get(AssemblyHeader."Posting No.") then
            PostSustainabilityLineForConsumption(AssemblyLine, PostedAssemblyHeader."Posting Date", QtyToConsumeBase, PostedAssemblyHeader."Source Code", AssemblyHeader."Posting No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnUndoPostHeaderOnAfterTransferFields', '', false, false)]
    local procedure OnUndoPostHeaderOnAfterTransferFields(PostedAssemblyHeader: Record "Posted Assembly Header"; var AssemblyHeader: Record "Assembly Header")
    begin
        if AssemblyHeader."Quantity (Base)" <> 0 then
            PostSustainabilityLineForOutput(AssemblyHeader, PostedAssemblyHeader."Posting Date", -AssemblyHeader."Quantity (Base)", PostedAssemblyHeader."Source Code", PostedAssemblyHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnUndoPostLinesOnAfterTransferFields', '', false, false)]
    local procedure OnUndoPostLinesOnAfterTransferFields(var AssemblyLine: Record "Assembly Line"; PostedAssemblyHeader: Record "Posted Assembly Header")
    begin
        if AssemblyLine."Quantity (Base)" <> 0 then
            PostSustainabilityLineForConsumption(AssemblyLine, PostedAssemblyHeader."Posting Date", -AssemblyLine."Quantity (Base)", PostedAssemblyHeader."Source Code", PostedAssemblyHeader."No.");
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

    local procedure UpdatePostedSustainabilityEmission(CO2ePerUnit: Decimal; QtyperUnitofMeasure: Decimal; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2e: Decimal)
    begin
        PostedEmissionCO2e := (CO2ePerUnit * Abs(Quantity) * QtyperUnitofMeasure) * Sign;
    end;

    local procedure PostSustainabilityLineForOutput(var AssemblyHeader: Record "Assembly Header"; PostingDate: Date; QtyToOutputBase: Decimal; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        GHGCredit: Boolean;
        CO2eToPost: Decimal;
        Sign: Integer;
    begin
        if (QtyToOutputBase = 0) then
            exit;

        GHGCredit := IsGHGCreditLine(AssemblyHeader."Item No.");

        Sign := GetPostingSign(QtyToOutputBase, 0, GHGCredit);
        CO2eToPost := AssemblyHeader."CO2e per Unit" * QtyToOutputBase * AssemblyHeader."Qty. per Unit of Measure" * Sign;
        if not CanPostSustainabilityJnlLine(AssemblyHeader."Sust. Account No.", AssemblyHeader."Sust. Account Category", AssemblyHeader."Sust. Account Subcategory", CO2eToPost) then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Source Code" := SrcCode;
        SustainabilityJnlLine.Validate("Posting Date", PostingDate);
        if GHGCredit then
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"GHG Credit")
        else
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);

        SustainabilityJnlLine.Validate("Document No.", GenJnlLineDocNo);
        SustainabilityJnlLine.Validate("Account No.", AssemblyHeader."Sust. Account No.");
        SustainabilityJnlLine.Validate("Account Category", AssemblyHeader."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", AssemblyHeader."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", AssemblyHeader."Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := AssemblyHeader."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := AssemblyHeader."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := AssemblyHeader."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", CO2eToPost);
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine, AssemblyHeader);

        AssemblyHeader."Posted Total CO2e" += CO2eToPost;
    end;

    local procedure PostSustainabilityLineForConsumption(var AssemblyLine: Record "Assembly Line"; PostingDate: Date; QtyToConsumeBase: Decimal; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
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
        if not CanPostSustainabilityJnlLine(AssemblyLine."Sust. Account No.", AssemblyLine."Sust. Account Category", AssemblyLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := '';
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := SrcCode;
        SustainabilityJnlLine.Validate("Posting Date", PostingDate);
        if GHGCredit then
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"GHG Credit")
        else
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);

        SustainabilityJnlLine.Validate("Document No.", GenJnlLineDocNo);
        SustainabilityJnlLine.Validate("Account No.", AssemblyLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Account Category", AssemblyLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", AssemblyLine."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", AssemblyLine."Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := AssemblyLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := AssemblyLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := AssemblyLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", CO2eToPost);
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine, AssemblyLine);

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

        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustLedEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2eToPost = 0) then
                    Error(EmissionMustNotBeZeroErr);

        if (CO2eToPost <> 0) then
            exit(true);
    end;

    var
        EmissionMustNotBeZeroErr: Label 'The Emission fields must have a value that is not 0.';
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in Assembly document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}