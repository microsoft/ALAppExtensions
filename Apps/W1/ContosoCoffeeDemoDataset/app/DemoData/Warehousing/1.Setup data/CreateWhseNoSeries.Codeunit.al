codeunit 4797 "Create Whse No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(TransferOrder(), TransferOrderLbl, '1001', '9999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(TransferShipment(), TransferShipmentLbl, '108001', '108999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(TransferReceipt(), TransferReceiptLbl, '109000', '109999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(InventoryPick(), InventoryPickLbl, 'IPI000001', 'IPI999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(PostedInventoryPick(), PostedInventoryPickLbl, 'PPI000001', 'PPI999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(InventoryPutAway(), InventoryPutAwayLbl, 'IPU000001', 'IPU999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(PostedInventoryPutAway(), PostedInventoryPutAwayLbl, 'PPU000001', 'PPU999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(InventoryMovement(), InventoryMovementLbl, 'IM000001', 'IM999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(RegisteredInventoryMovement(), RegisteredInventoryMomentLbl, 'RIM000001', 'RIM999999', '', '', 1, true, false);

        ContosoNoSeries.InsertNoSeries(WarehouseReceipt(), WarehouseReceiptLbl, 'RE000001', 'RE999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(PostedWarehouseReceipt(), PostedWarehouseReceiptLbl, 'R_000001', 'R_999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(WarehouseShipment(), WarehouseShipmentLbl, 'SH000001', 'SH999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(PostedWarehouseShipment(), PostedWarehouseShipmentLbl, 'S_000001', 'S_999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(WarehousePutAway(), WarehousePutAwayLbl, 'PU000001', 'PU999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(RegisteredWarehousePutAway(), RegisteredWarehousePutAwayLbl, 'PU_000001', 'PU_999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(WarehousePick(), WarehousePickLbl, 'PI000001', 'PI999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(RegisteredWarehousePick(), RegisteredWarehousePickLbl, 'P_000001', 'P_999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(WarehouseMovement(), WarehouseMovementLbl, 'WM000001', 'WM999999', '', '', 1, true, false);
        ContosoNoSeries.InsertNoSeries(RegisteredWarehouseMovement(), RegisteredWarehouseMovementLbl, 'WM_000001', 'WM_999999', '', '', 1, true, false);
    end;

    var
        TransferOrderTok: Label 'T-ORD', MaxLength = 20;
        TransferOrderLbl: Label 'Transfer Order', MaxLength = 100;
        TransferShipmentTok: Label 'T-SHIP', MaxLength = 20;
        TransferShipmentLbl: Label 'Transfer Shipment', MaxLength = 100;
        TransferReceiptTok: Label 'T-RCPT', MaxLength = 20;
        TransferReceiptLbl: Label 'Transfer Receipt', MaxLength = 100;
        InventoryPickLbl: Label 'Inventory Pick', MaxLength = 100;
        InventoryPickTok: Label 'I-PICK', MaxLength = 20;
        PostedInventoryPickLbl: Label 'Posted Inventory Pick', MaxLength = 100;
        PostedInventoryPickTok: Label 'I-PICK+', MaxLength = 20;
        InventoryPutAwayLbl: Label 'Inventory Put-Away', MaxLength = 100;
        InventoryPutAwayTok: Label 'I-PUT', MaxLength = 20;
        PostedInventoryPutAwayLbl: Label 'Posted Invt. Put-Away', MaxLength = 100;
        PostedInventoryPutAwayTok: Label 'I-PUT+', MaxLength = 20;
        InventoryMovementLbl: Label 'Inventory Movement', MaxLength = 100;
        InventoryMovementTok: Label 'I-MOVE', MaxLength = 20;
        RegisteredInventoryMomentLbl: Label 'Registered Inventory Movement', MaxLength = 100;
        RegisteredInventoryMovementTok: Label 'I-MOVE+', MaxLength = 20;
        WarehouseReceiptTok: Label 'WMS-RCPT', MaxLength = 20;
        WarehouseReceiptLbl: Label 'Warehouse Receipt', MaxLength = 100;
        PostedWarehouseReceiptLbl: Label 'Posted Warehouse Receipt', MaxLength = 100;
        PostedWarehouseReceiptTok: Label 'WMS-RCPT+', MaxLength = 20;
        WarehouseShipmentLbl: Label 'Warehouse Shipment', MaxLength = 100;
        WarehouseShipmentTok: Label 'WMS-SHIP', MaxLength = 20;
        PostedWarehouseShipmentLbl: Label 'Posted Warehouse Shipment', MaxLength = 100;
        PostedWarehouseShipmentTok: Label 'WMS-SHIP+', MaxLength = 20;
        WarehousePutAwayLbl: Label 'Warehouse Put-away', MaxLength = 100;
        WarehousePutAwayTok: Label 'WMS-PUT', MaxLength = 20;
        RegisteredWarehousePutAwayLbl: Label 'Registered Warehouse Put-away', MaxLength = 100;
        RegisteredWarehousePutAwayTok: Label 'WMS-PUT-+', MaxLength = 20;
        WarehousePickLbl: Label 'Warehouse Pick', MaxLength = 100;
        WarehousePickTok: Label 'WMS-PICK', MaxLength = 20;
        RegisteredWarehousePickLbl: Label 'Registered Warehouse Pick', MaxLength = 100;
        RegisteredWarehousePickTok: Label 'WMS-PICK+', MaxLength = 20;
        WarehouseMovementLbl: Label 'Warehouse Movement', MaxLength = 100;
        WarehouseMovementTok: Label 'WMS-MOV', MaxLength = 20;
        RegisteredWarehouseMovementLbl: Label 'Registered Whse. Movement', MaxLength = 100;
        RegisteredWarehouseMovementTok: Label 'WMS-MOVE+', MaxLength = 20;

    procedure TransferOrder(): Code[20]
    begin
        exit(TransferOrderTok);
    end;

    procedure TransferShipment(): Text[20]
    begin
        exit(TransferShipmentTok);
    end;

    procedure TransferReceipt(): Text[20]
    begin
        exit(TransferReceiptTok);
    end;

    procedure InventoryPick(): Code[20]
    begin
        exit(InventoryPickTok);
    end;

    procedure PostedInventoryPick(): Code[20]
    begin
        exit(PostedInventoryPickTok);
    end;

    procedure InventoryPutAway(): Code[20]
    begin
        exit(InventoryPutAwayTok);
    end;

    procedure PostedInventoryPutAway(): Code[20]
    begin
        exit(PostedInventoryPutAwayTok);
    end;

    procedure InventoryMovement(): Code[20]
    begin
        exit(InventoryMovementTok);
    end;

    procedure RegisteredInventoryMovement(): Code[20]
    begin
        exit(RegisteredInventoryMovementTok);
    end;

    procedure WarehouseReceipt(): Code[20]
    begin
        exit(WarehouseReceiptTok);
    end;

    procedure PostedWarehouseReceipt(): Code[20]
    begin
        exit(PostedWarehouseReceiptTok);
    end;

    procedure WarehouseShipment(): Code[20]
    begin
        exit(WarehouseShipmentTok);
    end;

    procedure PostedWarehouseShipment(): Code[20]
    begin
        exit(PostedWarehouseShipmentTok);
    end;

    procedure WarehousePutAway(): Code[20]
    begin
        exit(WarehousePutAwayTok);
    end;

    procedure RegisteredWarehousePutAway(): Code[20]
    begin
        exit(RegisteredWarehousePutAwayTok);
    end;

    procedure WarehousePick(): Code[20]
    begin
        exit(WarehousePickTok);
    end;

    procedure RegisteredWarehousePick(): Code[20]
    begin
        exit(RegisteredWarehousePickTok);
    end;

    procedure WarehouseMovement(): Code[20]
    begin
        exit(WarehouseMovementTok);
    end;

    procedure RegisteredWarehouseMovement(): Code[20]
    begin
        exit(RegisteredWarehouseMovementTok);
    end;
}