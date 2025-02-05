codeunit 10717 "Create Item Charge NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItemCharge(var Rec: Record "Item Charge")
    var
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
        CreateItemCharge: Codeunit "Create Item Charge";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight(), CreateItemCharge.PurchAllowance(), CreateItemCharge.PurchFreight(), CreateItemCharge.PurchRestock(), CreateItemCharge.SaleAllowance(), CreateItemCharge.SaleFreight(), CreateItemCharge.SaleRestock():
                Rec.Validate("VAT Prod. Posting Group", CreateVatPostingGroupsNO.High());
        end;
    end;
}