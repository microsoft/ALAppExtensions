codeunit 5107 "Create Svc Demo Orders"
{

    Permissions = tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rim;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        AdjustSvcDemoData: Codeunit "Adjust Svc Demo Data";

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        CreateSalesOrders();
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