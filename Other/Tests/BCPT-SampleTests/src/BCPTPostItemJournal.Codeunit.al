codeunit 149120 "BCPT Post Item Journal"
{
    SingleInstance = true;

    trigger OnRun();
    var
    begin
        PostItemJournal();
    end;

    procedure PostItemJournal()
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        // Setup: Create Item Journal with Entry Type Positive Adjustment.
        CreateItemJournal(ItemJournalLine);

        // Exercise: Post Item Journal.
        PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    local procedure CreateItemJournal(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        if not Item.get('70000') then
            Item.FindSet();

        CreateItemJournalLine(ItemJournalLine, Item."No.");
    end;

    local procedure CreateItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; ItemNo: Code[20])
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        SelectItemJournal(ItemJournalBatch);
        CreateItemJournalLine(
          ItemJournalLine, ItemJournalBatch."Journal Template Name",
          ItemJournalBatch.Name, ItemJournalLine."Entry Type"::"Positive Adjmt.", ItemNo, 10);
    end;

    procedure CreateItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; EntryType: Enum "Item Ledger Entry Type"; ItemNo: Text[20]; NewQuantity: Decimal)
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        if not ItemJournalBatch.Get(JournalTemplateName, JournalBatchName) then begin
            ItemJournalBatch.Init();
            ItemJournalBatch.Validate("Journal Template Name", JournalTemplateName);
            ItemJournalBatch.SetupNewBatch();
            ItemJournalBatch.Validate(Name, JournalBatchName);
            ItemJournalBatch.Validate(Description, JournalBatchName + ' journal');
            ItemJournalBatch.Insert(true);
        end;
        CreateItemJnlLineWithNoItem(ItemJournalLine, ItemJournalBatch, JournalTemplateName, JournalBatchName, EntryType);
        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Validate(Quantity, NewQuantity);
        ItemJournalLine.Modify(true);
    end;

    procedure CreateItemJnlLineWithNoItem(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; EntryType: Enum "Item Ledger Entry Type")
    var
        NoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        RecRef: RecordRef;
        DocumentNo: Code[20];
    begin
        Clear(ItemJournalLine);
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", JournalTemplateName);
        ItemJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(ItemJournalLine);
        ItemJournalLine.Validate("Line No.", 10000);
        ItemJournalLine.Insert(true);
        ItemJournalLine.Validate("Posting Date", WorkDate());
        ItemJournalLine.Validate("Entry Type", EntryType);
        if NoSeries.Get(ItemJournalBatch."No. Series") then
            DocumentNo := NoSeriesManagement.GetNextNo(ItemJournalBatch."No. Series", ItemJournalLine."Posting Date", false);
        ItemJournalLine.Validate("Document No.", DocumentNo);
        ItemJournalLine.Modify(true);
    end;

    local procedure SelectItemJournal(var ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type::Item, ItemJournalTemplate.Name);
    end;

    procedure PostItemJournalLine(JournalTemplateName: Text[10]; JournalBatchName: Text[10])
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", JournalTemplateName);
        ItemJournalLine.Validate("Journal Batch Name", JournalBatchName);
        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
    end;

    procedure SelectItemJournalTemplateName(var ItemJournalTemplate: Record "Item Journal Template"; ItemJournalTemplateType: Enum "Item Journal Template Type")
    begin
        // Find Item Journal Template for the given Template Type.
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplateType);
        ItemJournalTemplate.SetRange(Recurring, false);
        if ItemJournalTemplate.FindFirst() then;
    end;

    procedure SelectItemJournalBatchName(var ItemJournalBatch: Record "Item Journal Batch"; ItemJournalBatchTemplateType: Enum "Item Journal Template Type"; ItemJournalTemplateName: Code[10])
    begin
        // Find Name for Batch Name.
        ItemJournalBatch.SetRange("Template Type", ItemJournalBatchTemplateType);
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplateName);

        // If Item Journal Batch not found then create it.
        if ItemJournalBatch.FindFirst() then;
    end;
}