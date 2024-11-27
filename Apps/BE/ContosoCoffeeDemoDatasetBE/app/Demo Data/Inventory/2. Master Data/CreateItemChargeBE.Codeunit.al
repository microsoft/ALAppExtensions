codeunit 11376 "Create Item Charge BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItemCharge(var Rec: Record "Item Charge")
    var
        CreateVatPostingGrpBE: Codeunit "Create VAT Posting Group BE";
        CreateItemCharge: Codeunit "Create Item Charge";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight(), CreateItemCharge.PurchAllowance(), CreateItemCharge.PurchFreight(), CreateItemCharge.PurchRestock(), CreateItemCharge.SaleAllowance(), CreateItemCharge.SaleFreight(), CreateItemCharge.SaleRestock():
                Rec.Validate("VAT Prod. Posting Group", CreateVatPostingGrpBE.G3());
        end;
    end;
}