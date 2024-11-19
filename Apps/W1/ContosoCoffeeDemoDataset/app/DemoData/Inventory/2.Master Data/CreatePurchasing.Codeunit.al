codeunit 5379 "Create Purchasing"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
    begin
        ContosoInventory.InsertPurchasing(CallIn(), CallInDescLbl, false, false);
        ContosoInventory.InsertPurchasing(DropShip(), DropShipDescLbl, true, false);
        ContosoInventory.InsertPurchasing(SpecOrder(), SpecOrderDescLbl, false, true);
    end;

    procedure CallIn(): Code[10]
    begin
        exit(CallInTok);
    end;

    procedure DropShip(): Code[10]
    begin
        exit(DropShipTok);
    end;

    procedure SpecOrder(): Code[10]
    begin
        exit(SpecOrderTok);
    end;

    var
        CallInTok: Label 'CALL IN', MaxLength = 10;
        DropShipTok: Label 'DROP SHIP', MaxLength = 10;
        SpecOrderTok: Label 'SPEC ORDER', MaxLength = 10;
        CallInDescLbl: Label 'This order must be called in', MaxLength = 100;
        DropShipDescLbl: Label 'Call in and send to customer', MaxLength = 100;
        SpecOrderDescLbl: Label 'Call in and send to us', MaxLength = 100;
}