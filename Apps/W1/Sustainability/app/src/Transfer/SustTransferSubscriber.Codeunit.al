namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Transfer;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;

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
            PostSustainabilityLine(TransferLine, ItemJournalLine.Quantity, true, false, ItemJournalLine."Source Code", ItemJournalLine."Document No.");
            UpdatePostedSustainabilityEmissionOrderLine(TransferLine, ItemJournalLine.Quantity, true, false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure OnPostItemJnlLineOnAfterPrepareReceiptItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        if (ItemJournalLine.Quantity <> 0) then begin
            UpdateSustainabilityItemJournalLine(ItemJournalLine, TransferLine);
            PostSustainabilityLine(TransferLine, ItemJournalLine.Quantity, false, true, ItemJournalLine."Source Code", ItemJournalLine."Document No.");
            UpdatePostedSustainabilityEmissionOrderLine(TransferLine, ItemJournalLine.Quantity, false, true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptLine', '', false, false)]
    local procedure OnBeforeInsertTransShptLine(TransShptHeader: Record "Transfer Shipment Header"; TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    begin
        CopyTransShiplineFromTransLine(TransLine, TransShptLine);
        UpdatePostedSustainabilityEmission(TransLine, TransShptLine.Quantity, 1, TransShptLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeInsertTransRcptLine', '', false, false)]
    local procedure OnBeforeInsertTransRcptLine(TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")
    begin
        CopyTransReceiptlineFromTransLine(TransLine, TransRcptLine);
        UpdatePostedSustainabilityEmission(TransLine, TransRcptLine.Quantity, 1, TransRcptLine."Total CO2e");
    end;

    local procedure CopyTransShiplineFromTransLine(TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    begin
        TransShptLine."Sust. Account No." := TransLine."Sust. Account No.";
        TransShptLine."Sust. Account Name" := TransLine."Sust. Account Name";
        TransShptLine."Sust. Account Category" := TransLine."Sust. Account Category";
        TransShptLine."Sust. Account Subcategory" := TransLine."Sust. Account Subcategory";
        TransShptLine."CO2e per Unit" := TransLine."CO2e per Unit";
    end;

    local procedure CopyTransReceiptlineFromTransLine(TransLine: Record "Transfer Line"; var TransReceiptLine: Record "Transfer Receipt Line")
    begin
        TransReceiptLine."Sust. Account No." := TransLine."Sust. Account No.";
        TransReceiptLine."Sust. Account Name" := TransLine."Sust. Account Name";
        TransReceiptLine."Sust. Account Category" := TransLine."Sust. Account Category";
        TransReceiptLine."Sust. Account Subcategory" := TransLine."Sust. Account Subcategory";
        TransReceiptLine."CO2e per Unit" := TransLine."CO2e per Unit";
    end;

    local procedure UpdateSustainabilityItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; var TransferLine: Record "Transfer Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        GHGCredit := IsGHGCreditLine(TransferLine);

        Sign := GetPostingSign(ItemJournalLine."Document Type" = ItemJournalLine."Document Type"::"Transfer Shipment", ItemJournalLine."Document Type" = ItemJournalLine."Document Type"::"Transfer Receipt", GHGCredit);

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

    local procedure UpdatePostedSustainabilityEmissionOrderLine(var TransferLine: Record "Transfer Line"; Qty: Decimal; Ship: Boolean; Receive: Boolean)
    var
        PostedEmissionCO2e: Decimal;
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        GHGCredit := IsGHGCreditLine(TransferLine);
        Sign := GetPostingSign(Ship, Receive, GHGCredit);

        UpdatePostedSustainabilityEmission(TransferLine, Qty, Sign, PostedEmissionCO2e);

        if Ship then
            TransferLine."Posted Shipped Total CO2e" += PostedEmissionCO2e;

        if Receive then
            TransferLine."Posted Received Total CO2e" += PostedEmissionCO2e;

        TransferLine.Modify();
    end;

    local procedure UpdatePostedSustainabilityEmission(TransferLine: Record "Transfer Line"; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2e: Decimal)
    begin
        PostedEmissionCO2e := (TransferLine."CO2e per Unit" * Abs(Quantity) * TransferLine."Qty. per Unit of Measure") * Sign;
    end;

    local procedure PostSustainabilityLine(TransferLine: Record "Transfer Line"; Qty: Decimal; Ship: Boolean; Receive: Boolean; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        GHGCredit: Boolean;
        CO2eToPost: Decimal;
        Sign: Integer;
    begin
        GHGCredit := IsGHGCreditLine(TransferLine);

        Sign := GetPostingSign(Ship, Receive, GHGCredit);

        CO2eToPost := TransferLine."CO2e per Unit" * Abs(Qty) * TransferLine."Qty. per Unit of Measure" * Sign;

        TransferHeader.Get(TransferLine."Document No.");
        if not CanPostSustainabilityJnlLine(TransferLine."Sust. Account No.", TransferLine."Sust. Account Category", TransferLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := '';
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := SrcCode;
        SustainabilityJnlLine.Validate("Posting Date", TransferHeader."Posting Date");

        if GHGCredit then
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"GHG Credit")
        else
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);

        SustainabilityJnlLine.Validate("Document No.", GenJnlLineDocNo);
        SustainabilityJnlLine.Validate("Account No.", TransferLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Account Category", TransferLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", TransferLine."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", TransferLine."Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := TransferLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := TransferLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := TransferLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", CO2eToPost);
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine, TransferLine);
    end;

    local procedure GetPostingSign(Ship: Boolean; Receive: Boolean; GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        if Ship then
            if not GHGCredit then
                Sign := -1;

        if Receive then
            if GHGCredit then
                Sign := -1;

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
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in sales document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}