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
        XSTARTSVCTok: Label 'START-SVC', MaxLength = 10;
        XLOANER1Tok: Label 'LOANER1', MaxLength = 10;
        XLOANER2Tok: Label 'LOANER2', MaxLength = 10;

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        // Create Item Journals
        CreateItemJournals();
        OnAfterCreateItemJournals();

        // Create Loaners
        CreateLoaners();
        OnAfterCreateLoaners();

        // Create Sales Orders
        CreateSalesOrders();
        OnAfterCreateSalesOrders();
    end;

    local procedure CreateItemJournals()
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlTemplateName: Code[10];
    begin
        CreateItemJournalBatch(ItemJnlTemplateName, XSTARTSVCTok);
        InitItemJnlLine(ItemJournalLine, ItemJnlTemplateName, XSTARTSVCTok);
        ItemJournalLine.Validate("Item No.", SvcDemoDataSetup."Item 1 No.");
        ItemJournalLine.Validate("Posting Date", AdjustSvcDemoData.AdjustDate(19020601D));
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", XSTARTSVCTok);
        ItemJournalLine.Validate(Quantity, 10);
        OnBeforeItemJournalLineInsert(ItemJournalLine);
        ItemJournalLine.Insert(true);
        InitItemJnlLine(ItemJournalLine, ItemJnlTemplateName, XSTARTSVCTok);
        ItemJournalLine.Validate("Item No.", SvcDemoDataSetup."Item 2 No.");
        ItemJournalLine.Validate("Posting Date", AdjustSvcDemoData.AdjustDate(19020601D));
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", XSTARTSVCTok);
        ItemJournalLine.Validate(Quantity, 10);
        OnBeforeItemJournalLineInsert(ItemJournalLine);
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
                Commit();
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

        LastItemJournalLine.Reset();
        LastItemJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        LastItemJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if LastItemJournalLine.FindLast() then
            LineNumber := LastItemJournalLine."Line No." + 10000
        else
            LineNumber := 10000;
        ItemJournalLine.Validate("Line No.", LineNumber);
    end;

    local procedure CreateLoaners()
    var
        Loaner: Record "Loaner";
    begin
        if not Loaner.Get(XLOANER1Tok) then begin
            Loaner.Init();
            Loaner.Validate("No.", XLOANER1Tok);
            Loaner.Validate("Description", XLOANER1Tok);
            Loaner.Validate("Item No.", SvcDemoDataSetup."Item 1 No.");
            OnBeforeLoanerInsert(Loaner);
            Loaner.Insert(true);
        end;
        if not Loaner.Get(XLOANER2Tok) then begin
            Loaner.Init();
            Loaner.Validate("No.", XLOANER2Tok);
            Loaner.Validate("Description", XLOANER2Tok);
            Loaner.Validate("Item No.", SvcDemoDataSetup."Item 2 No.");
            OnBeforeLoanerInsert(Loaner);
            Loaner.Insert(true);
        end;
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
        OnBeforeSalesHeaderFinalize(SalesHeader);
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
        OnBeforeSalesLineFinalize(SalesLine);
        SalesLine.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemJournalLineInsert(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItemJournals()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLoanerInsert(var Loaner: Record Loaner)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateLoaners()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesHeaderFinalize(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesLineFinalize(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesOrders()
    begin
    end;
}