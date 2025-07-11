#pragma warning disable AA0247
codeunit 31471 "Create Posted Adv.Let.Data CZZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        ReleasePurchaseAdvanceLetters();
        PostPurchaseAdvancePayments();
        ReleaseSalesAdvanceLetters();
        PostSalesAdvancePayments();
        PostLinkedDocuments();
    end;

    local procedure ReleasePurchaseAdvanceLetters()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        if PurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                Codeunit.Run(Codeunit::"Rel. Purch.Adv.Letter Doc. CZZ", PurchAdvLetterHeaderCZZ);
            until PurchAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure ReleaseSalesAdvanceLetters()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                Codeunit.Run(Codeunit::"Rel. Sales Adv.Letter Doc. CZZ", SalesAdvLetterHeaderCZZ);
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure PostPurchaseAdvancePayments()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
    begin
        if PurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                GenJournalLine.SetRange("Account No.", PurchAdvLetterHeaderCZZ."Pay-to Vendor No.");
                GenJournalLine.SetRange(Description, PurchAdvLetterHeaderCZZ."No.");
                if GenJournalLine.FindFirst() then begin
                    GenJournalLine.Validate("Document No.", PurchAdvLetterHeaderCZZ."No.");
                    GenJournalLine.Validate("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
                    GenJournalLine.Validate("Bal. Account No.", CreateBankAccountCZ.NBL());
                    Codeunit.Run(Codeunit::"Gen. Jnl.-Post Line", GenJournalLine);
                    GenJournalLine.Delete();
                end;
            until PurchAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure PostSalesAdvancePayments()
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
    begin
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                GenJournalLine.SetRange("Account No.", SalesAdvLetterHeaderCZZ."Bill-to Customer No.");
                GenJournalLine.SetRange(Description, SalesAdvLetterHeaderCZZ."No.");
                if GenJournalLine.FindFirst() then begin
                    GenJournalLine.Validate("Document No.", SalesAdvLetterHeaderCZZ."No.");
                    GenJournalLine.Validate("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
                    GenJournalLine.Validate("Bal. Account No.", CreateBankAccountCZ.NBL());
                    Codeunit.Run(Codeunit::"Gen. Jnl.-Post Line", GenJournalLine);
                    GenJournalLine.Delete();
                end;
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure PostLinkedDocuments()
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        DocumentHeader: Variant;
    begin
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                if GetPurchaseDocument(AdvanceLetterApplicationCZZ, DocumentHeader) then
                    PostDocument(DocumentHeader);
            until AdvanceLetterApplicationCZZ.Next() = 0;
    end;

    local procedure GetPurchaseDocument(AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var DocumentHeader: Variant) IsExist: Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        case AdvanceLetterApplicationCZZ."Document Type" of
            AdvanceLetterApplicationCZZ."Document Type"::"Purchase Invoice":
                begin
                    IsExist := PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, AdvanceLetterApplicationCZZ."Document No.");
                    DocumentHeader := PurchaseHeader;
                end;
            AdvanceLetterApplicationCZZ."Document Type"::"Purchase Order":
                begin
                    IsExist := PurchaseHeader.Get(Enum::"Purchase Document Type"::Order, AdvanceLetterApplicationCZZ."Document No.");
                    DocumentHeader := PurchaseHeader;
                end;
            AdvanceLetterApplicationCZZ."Document Type"::"Sales Invoice":
                begin
                    IsExist := SalesHeader.Get(Enum::"Sales Document Type"::Invoice, AdvanceLetterApplicationCZZ."Document No.");
                    DocumentHeader := SalesHeader;
                end;
            AdvanceLetterApplicationCZZ."Document Type"::"Sales Order":
                begin
                    IsExist := SalesHeader.Get(Enum::"Sales Document Type"::Order, AdvanceLetterApplicationCZZ."Document No.");
                    DocumentHeader := SalesHeader;
                end;
        end;
    end;

    local procedure PostDocument(DocumentHeader: Variant)
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        DocumentRecordRef: RecordRef;
    begin
        if not DocumentHeader.IsRecord() then
            exit;

        DocumentRecordRef.GetTable(DocumentHeader);
        case DocumentRecordRef.Number of
            Database::"Purchase Header":
                begin
                    PurchaseHeader := DocumentHeader;
                    PurchaseHeader.Validate(Invoice, true);
                    PurchaseHeader.Validate(Receive, true);
                    Codeunit.Run(Codeunit::"Purch.-Post", PurchaseHeader);
                end;
            Database::"Sales Header":
                begin
                    SalesHeader := DocumentHeader;
                    SalesHeader.Validate(Invoice, true);
                    SalesHeader.Validate(Ship, true);
                    Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
                end;
        end;
    end;
}