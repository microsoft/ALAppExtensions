codeunit 5110 "Create Svc Demo Item Stock"
{

    Permissions = tabledata "Item Journal Line" = rim,
        tabledata "Item Journal template" = r,
        tabledata "Item Journal Batch" = rim;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        AdjustSvcDemoData: Codeunit "Adjust Svc Demo Data";
        LineNumber: Integer;
        STARTSVCTok: Label 'START-SVC', MaxLength = 10;

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        CreateItemJournals();
    end;

    local procedure CreateItemJournals()
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlTemplateName: Code[10];
    begin
        CreateItemJournalBatch(ItemJnlTemplateName, STARTSVCTok);

        CreateItemJournalLine(ItemJournalLine, ItemJnlTemplateName, STARTSVCTok, SvcDemoDataSetup."Item 1 No.");
        CreateItemJournalLine(ItemJournalLine, ItemJnlTemplateName, STARTSVCTok, SvcDemoDataSetup."Item 2 No.");
    end;

    local procedure CreateItemJournalBatch(var ItemJnlTemplateName: Code[10]; ItemJnlBatchName: Code[10])
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalTemplate.SetRange("Page ID", PAGE::"Item Journal");
        ItemJournalTemplate.SetRange(Recurring, false);
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Item);

        if ItemJournalTemplate.FindFirst() then
            if not ItemJournalBatch.Get(ItemJournalTemplate.Name, ItemJnlBatchName) then begin
                ItemJournalBatch.Init();
                ItemJournalBatch."Journal Template Name" := ItemJournalTemplate.Name;
                ItemJournalBatch.SetupNewBatch();
                ItemJournalBatch.Name := ItemJnlBatchName;
                ItemJournalBatch.Description := ItemJnlBatchName;
                ItemJournalBatch.Insert(true);
            end;
        ItemJnlTemplateName := ItemJournalTemplate.Name;
    end;

    local procedure CreateItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; ItemNo: Code[20])
    var
        LastItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", JournalTemplateName);
        ItemJournalLine.Validate("Journal Batch Name", JournalBatchName);

        LastItemJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        LastItemJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if LastItemJournalLine.FindLast() then
            LineNumber := LastItemJournalLine."Line No." + 10000
        else
            LineNumber := 10000;
        ItemJournalLine.Validate("Line No.", LineNumber);

        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Validate("Posting Date", AdjustSvcDemoData.AdjustDate(19020601D));
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", STARTSVCTok);
        ItemJournalLine.Validate(Quantity, 10);
        ItemJournalLine.Insert(true);
    end;
}