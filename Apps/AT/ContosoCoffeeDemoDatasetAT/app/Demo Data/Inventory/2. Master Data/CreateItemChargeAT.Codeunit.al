codeunit 11165 "Create Item Charge AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItemCharge(var Rec: Record "Item Charge")
    var
        CreateVatPostingGrpAT: Codeunit "Create VAT Posting Group AT";
        CreateItemCharge: Codeunit "Create Item Charge";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight(), CreateItemCharge.PurchAllowance(), CreateItemCharge.PurchFreight(), CreateItemCharge.PurchRestock(), CreateItemCharge.SaleAllowance(), CreateItemCharge.SaleFreight(), CreateItemCharge.SaleRestock():
                Rec.Validate("VAT Prod. Posting Group", CreateVatPostingGrpAT.VAT20());
        end;
    end;
}