codeunit 5128 "Create Common No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Sales & Receivables Setup" = r,
        tabledata "Purchases & Payables Setup" = r,
        tabledata "Inventory Setup" = r;

    trigger OnRun()
    var
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        InventorySetup: Record "Inventory Setup";
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        SalesReceivablesSetup.Get();

        if SalesReceivablesSetup."Customer Nos." = '' then
            ContosoNoSeries.InsertNoSeries(Customer(), CustomerLbl, 'C10', 'C99990', '', '', 1, true, true);

        if SalesReceivablesSetup."Order Nos." = '' then
            ContosoNoSeries.InsertNoSeries(SalesOrder(), SalesOrderLbl, '101001', '102999', '', '', 1, false, false);


        InventorySetup.Get();
        if InventorySetup."Item Nos." = '' then
            ContosoNoSeries.InsertNoSeries(Item(), ItemsLbl, '1000', '9999', '', '', 1, true, true);

        PurchasePayablesSetup.Get();
        if PurchasePayablesSetup."Order Nos." = '' then
            ContosoNoSeries.InsertNoSeries(PurchaseOrder(), PurchaseOrderLbl, '106001', '107999', '', '', 1, false, false);
    end;

    var
        CustomerTok: Label 'CUST', MaxLength = 20;
        CustomerLbl: Label 'Customer', MaxLength = 100;
        ItemTok: Label 'ITEM', MaxLength = 20;
        ItemsLbl: Label 'Items', MaxLength = 100;
        SalesOrderTok: Label 'S-ORD', MaxLength = 20;
        SalesOrderLbl: Label 'Sales Order', MaxLength = 100;
        PurchaseOrderTok: Label 'P-ORD', MaxLength = 20;
        PurchaseOrderLbl: Label 'Purchase Order', MaxLength = 100;

    procedure Customer(): Code[20]
    begin
        exit(CustomerTok);
    end;

    procedure Item(): Code[20]
    begin
        exit(ItemTok);
    end;

    procedure SalesOrder(): Code[20]
    begin
        exit(SalesOrderTok);
    end;

    procedure PurchaseOrder(): Code[20]
    begin
        exit(PurchaseOrderTok);
    end;
}
