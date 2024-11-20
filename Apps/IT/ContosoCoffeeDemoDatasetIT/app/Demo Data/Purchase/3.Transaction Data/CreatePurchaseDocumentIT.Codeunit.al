codeunit 12221 "Create Purchase Document IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdatePurchaseDocument();
        UpdatePurchDocCheckTotal();
        RecreatePurchaseDocumentsByDateOrder();
    end;

    local procedure UpdatePurchaseDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Resource: Record Resource;
    begin
        if PurchaseHeader.FindSet() then
            repeat
                PurchaseHeader.Validate("Payment Method Code", BankTransfer());
                PurchaseHeader.Modify(true);
            until PurchaseHeader.Next() = 0;

        PurchaseLine.SetRange(Type, PurchaseLine.Type::Resource);
        if PurchaseLine.FindSet() then
            repeat
                Resource.Get(PurchaseLine."No.");
                PurchaseLine.Validate("Direct Unit Cost", Resource."Direct Unit Cost");
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;

    local procedure RecreatePurchaseDocumentsByDateOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TempPurchaseHeader: Record "Purchase Header" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
    begin
        if PurchaseHeader.FindSet() then
            repeat
                TempPurchaseHeader.Init();
                TempPurchaseHeader := PurchaseHeader;
                TempPurchaseHeader.Insert();
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                if PurchaseLine.FindSet() then
                    repeat
                        TempPurchaseLine.Init();
                        TempPurchaseLine := PurchaseLine;
                        TempPurchaseLine.Insert();
                    until PurchaseLine.Next() = 0;
            until PurchaseHeader.Next() = 0;

        PurchaseHeader.Reset();
        PurchaseHeader.DeleteAll();
        PurchaseLine.Reset();
        PurchaseLine.DeleteAll();

        TempPurchaseHeader.SetCurrentKey("Document Type", "Posting Date");
        if TempPurchaseHeader.FindSet() then
            repeat
                PurchaseHeader.Init();
                PurchaseHeader := TempPurchaseHeader;
                PurchaseHeader."No." := '';
                PurchaseHeader.Insert(true);
                TempPurchaseLine.SetRange("Document Type", TempPurchaseHeader."Document Type");
                TempPurchaseLine.SetRange("Document No.", TempPurchaseHeader."No.");
                if TempPurchaseLine.FindSet() then
                    repeat
                        PurchaseLine.Init();
                        PurchaseLine := TempPurchaseLine;
                        PurchaseLine."Document No." := PurchaseHeader."No.";
                        PurchaseLine.Insert();
                    until TempPurchaseLine.Next() = 0;
            until TempPurchaseHeader.Next() = 0;
    end;

    local procedure UpdatePurchDocCheckTotal()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.FindSet() then
            repeat
                PurchaseHeader.CalcFields("Amount Including VAT");
                PurchaseHeader.Validate("Check Total", PurchaseHeader."Amount Including VAT");
                PurchaseHeader.Modify();
            until PurchaseHeader.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertPurchaseDocument(var Rec: Record "Purchase Header")
    begin
        Rec.SetHideValidationDialog(true);
    end;

    procedure BankTransfer(): Code[10]
    begin
        exit(BankTransfTok);
    end;

    var
        BankTransfTok: Label 'BANKTRANSF', MaxLength = 10;
}