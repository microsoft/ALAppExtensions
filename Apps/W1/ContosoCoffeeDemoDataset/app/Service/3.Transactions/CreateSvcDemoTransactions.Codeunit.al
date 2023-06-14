codeunit 5107 "Create Svc Demo Transactions"
{

    Permissions = tabledata "Item Journal Line" = rim,
        tabledata "Item Journal template" = r,
        tabledata "Item Journal Batch" = rim,
        tabledata "Loaner" = rim,
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rim;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        AdjustSvcDemoData: Codeunit "Adjust Svc Demo Data";
        LineNumber: Integer;
        STARTSVCTok: Label 'START-SVC', MaxLength = 10;
        LOANER1Tok: Label 'LOANER1', MaxLength = 10;
        LOANER2Tok: Label 'LOANER2', MaxLength = 10;

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        CreateItemJournals();
        CreateLoaners();
        CreateSalesOrders();
    end;

    local procedure CreateItemJournals()
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlTemplateName: Code[10];
    begin
        CreateItemJournalBatch(ItemJnlTemplateName, STARTSVCTok);
        InitItemJnlLine(ItemJournalLine, ItemJnlTemplateName, STARTSVCTok);
        ItemJournalLine.Validate("Item No.", SvcDemoDataSetup."Item 1 No.");
        ItemJournalLine.Validate("Posting Date", AdjustSvcDemoData.AdjustDate(19020601D));
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", STARTSVCTok);
        ItemJournalLine.Validate(Quantity, 10);
        ItemJournalLine.Insert(true);
        InitItemJnlLine(ItemJournalLine, ItemJnlTemplateName, STARTSVCTok);
        ItemJournalLine.Validate("Item No.", SvcDemoDataSetup."Item 2 No.");
        ItemJournalLine.Validate("Posting Date", AdjustSvcDemoData.AdjustDate(19020601D));
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", STARTSVCTok);
        ItemJournalLine.Validate(Quantity, 10);
        ItemJournalLine.Insert(true);
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

    local procedure InitItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
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
    end;

    local procedure CreateLoaners()
    begin
        CreateLoaner(LOANER1Tok, SvcDemoDataSetup."Item 1 No.");
        CreateLoaner(LOANER2Tok, SvcDemoDataSetup."Item 2 No.");
    end;

    local procedure CreateLoaner(LoanerNo: Code[20]; ItemNo: Code[20])
    var
        Loaner: Record "Loaner";
    begin
        if Loaner.Get(LoanerNo) then
            exit;
        Loaner.Init();
        Loaner.Validate("No.", LoanerNo);
        Loaner.Validate("Description", LoanerNo);
        Loaner.Validate("Item No.", ItemNo);
        Loaner.Insert(true);
    end;

    local procedure CreateSalesOrders()
    begin
        CreateSalesOrder(SvcDemoDataSetup."Customer No.", SvcDemoDataSetup."Item 1 No.", 'SVC-1');
        CreateSalesOrder(SvcDemoDataSetup."Customer No.", SvcDemoDataSetup."Item 2 No.", 'SVC-2');
    end;

    local procedure CreateSalesOrder(CustomerNo: Code[20]; ItemNo: Code[20]; ExternalDocumentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("Posting Date", AdjustSvcDemoData.AdjustDate(19020601D));
        SalesHeader."External Document No." := ExternalDocumentNo;
        SalesHeader.Modify(true);
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", 10000);
        SalesLine.Insert(true);
        SalesLine.Validate("Type", SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        SalesLine.Validate("Quantity", 1);
        SalesLine.Modify(true);
    end;
}