codeunit 18006 "GST Statistics"
{
    Access = Internal;
    procedure GetPurchaseStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var GSTAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(GSTAmount);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                RecordIDList.Add(PurchaseLine.RecordId());
            until PurchaseLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            GSTAmount += GetGSTAmount(RecordIDList.Get(i));
    end;

    procedure GetStatisticsPostedPurchInvAmount(
        PurchInvHeader: Record "Purch. Inv. Header";
        var GSTAmount: Decimal)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(GSTAmount);

        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                RecordIDList.Add(PurchInvLine.RecordId());
            until PurchInvLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            GSTAmount += GetGSTAmount(RecordIDList.Get(i));
    end;

    procedure GetStatisticsPostedPurchCrMemoAmount(
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        var GSTAmount: Decimal)
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(GSTAmount);

        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
        if PurchCrMemoLine.FindSet() then
            repeat
                RecordIDList.Add(PurchCrMemoLine.RecordId());
            until PurchCrMemoLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            GSTAmount += GetGSTAmount(RecordIDList.Get(i));
    end;

    local procedure GetGSTAmount(RecID: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        if GSTSetup."Cess Tax Type" <> '' then
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type")
        else
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    procedure GetSalesStatisticsAmount(
        SalesHeader: Record "Sales Header";
        var GSTAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(GSTAmount);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document no.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                RecordIDList.Add(SalesLine.RecordId());
            until SalesLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            GSTAmount += GetGSTAmount(RecordIDList.Get(i));
    end;

    procedure GetStatisticsPostedSalesInvAmount(
        SalesInvHeader: Record "Sales Invoice Header";
        var GSTAmount: Decimal)
    var
        SalesInvLine: Record "Sales Invoice Line";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(GSTAmount);

        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                RecordIDList.Add(SalesInvLine.RecordId());
            until SalesInvLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            GSTAmount += GetGSTAmount(RecordIDList.Get(i));
    end;

    procedure GetStatisticsPostedSalesCrMemoAmount(
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        var GSTAmount: Decimal)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(GSTAmount);

        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                RecordIDList.Add(SalesCrMemoLine.RecordId());
            until SalesCrMemoLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            GSTAmount += GetGSTAmount(RecordIDList.Get(i));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchaseHeaderGSTAmount', '', false, false)]
    local procedure OnGetPurchaseHeaderGSTAmount(PurchaseHeader: Record "Purchase Header"; var GSTAmount: Decimal)
    begin
        GetPurchaseStatisticsAmount(PurchaseHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchInvHeaderGSTAmount', '', false, false)]
    local procedure OnGetPurchInvHeaderGSTAmount(PurchInvHeader: Record "Purch. Inv. Header"; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedPurchInvAmount(PurchInvHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchCrMemoHeaderGSTAmount', '', false, false)]
    local procedure OnGetPurchCrMemoHeaderGSTAmount(PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedPurchCrMemoAmount(PurchCrMemoHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesHeaderGSTAmount', '', false, false)]
    local procedure OnGetSalesHeaderGSTAmount(SalesHeader: Record "Sales Header"; var GSTAmount: Decimal)
    begin
        GetSalesStatisticsAmount(SalesHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesInvHeaderGSTAmount', '', false, false)]
    local procedure OnGetSalesInvHeaderGSTAmount(SalesInvHeader: Record "Sales Invoice Header"; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedSalesInvAmount(SalesInvHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesCrMemoHeaderGSTAmount', '', false, false)]
    local procedure OnGetSalesCrMemoHeaderGSTAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedSalesCrMemoAmount(SalesCrMemoHeader, GSTAmount);
    end;
}