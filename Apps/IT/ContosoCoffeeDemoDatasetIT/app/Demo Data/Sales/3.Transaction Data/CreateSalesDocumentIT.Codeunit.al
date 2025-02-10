codeunit 12222 "Create Sales Document IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdatePostingDateOnSalesDocument();
        RecreateSalesDocumentsByDateOrder();
    end;

    local procedure UpdatePostingDateOnSalesDocument()
    var
        SalesHeader: Record "Sales Header";
        CreateSourceCodeIT: Codeunit "Create Source Code IT";
        FromDate: Date;
    begin
        FromDate := CalcDate('<-7M>', CalcDate('<-CM>', Today));

        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice);
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader."No." = '101001' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+1D>', FromDate));
                if SalesHeader."No." = '101002' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+1M>', FromDate));
                if SalesHeader."No." = '101003' then begin
                    SalesHeader.Validate("Posting Date", CalcDate('<+3W>', FromDate));
                    SalesHeader.Validate("Payment Method Code", CreateSourceCodeIT.RIBA());
                end;
                if SalesHeader."No." = '101004' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+6W>', FromDate));

                if SalesHeader."No." = '102205' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+1D>', FromDate));
                if SalesHeader."No." = '102199' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+3D>', FromDate));
                if SalesHeader."No." = '102200' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+1M>', FromDate));
                if SalesHeader."No." = '102201' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+2D>', FromDate));
                if SalesHeader."No." = '102202' then begin
                    SalesHeader.Validate("Posting Date", CalcDate('<+4D>', FromDate));
                    SalesHeader.Validate("Payment Method Code", CreateSourceCodeIT.RIBA());
                end;
                if SalesHeader."No." = '102203' then begin
                    SalesHeader.Validate("Posting Date", CalcDate('<+6W>', FromDate));
                    SalesHeader.Validate("Payment Method Code", CreateSourceCodeIT.RIBA());
                end;
                if SalesHeader."No." = '102204' then
                    SalesHeader.Validate("Posting Date", CalcDate('<+1M>', FromDate));
                SalesHeader.Modify(true);
            until SalesHeader.Next() = 0;
    end;

    local procedure RecreateSalesDocumentsByDateOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
    begin
        if SalesHeader.FindSet() then
            repeat
                TempSalesHeader.Init();
                TempSalesHeader := SalesHeader;
                TempSalesHeader.Insert();
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet() then
                    repeat
                        TempSalesLine.Init();
                        TempSalesLine := SalesLine;
                        TempSalesLine.Insert();
                    until SalesLine.Next() = 0;
            until SalesHeader.Next() = 0;

        SalesHeader.Reset();
        SalesHeader.DeleteAll();
        SalesLine.Reset();
        SalesLine.DeleteAll();

        TempSalesHeader.SetCurrentKey("Document Type", "Posting Date");
        if TempSalesHeader.FindSet() then
            repeat
                SalesHeader.Init();
                SalesHeader := TempSalesHeader;
                SalesHeader."No." := '';
                SalesHeader.Insert(true);
                TempSalesLine.SetRange("Document Type", TempSalesHeader."Document Type");
                TempSalesLine.SetRange("Document No.", TempSalesHeader."No.");
                if TempSalesLine.FindSet() then
                    repeat
                        SalesLine.Init();
                        SalesLine := TempSalesLine;
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine.Insert();
                    until TempSalesLine.Next() = 0;
            until TempSalesHeader.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertSalesDocument(var Rec: Record "Sales Header")
    begin
        Rec.SetHideValidationDialog(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidatePostingDateOnAfterCheckNeedUpdateCurrencyFactor', '', false, false)]
    local procedure OnAfterValidatePostingDate(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Validate("Due Date", SalesHeader."Posting Date");
    end;
}