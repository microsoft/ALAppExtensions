codeunit 17127 "Create NZ Item Charge"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record "Item Charge")
    var
        CreateItemCharge: Codeunit "Create Item Charge";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight(),
            CreateItemCharge.PurchAllowance(),
            CreateItemCharge.PurchFreight(),
            CreateItemCharge.PurchRestock(),
            CreateItemCharge.SaleAllowance(),
            CreateItemCharge.SaleFreight(),
            CreateItemCharge.SaleRestock():
                ValidateRecordFields(Rec, CreateNZVATPostingGroup.VAT15());
        end;
    end;

    local procedure ValidateRecordFields(var ItemCharge: Record "Item Charge"; VATProdPostingGroup: Code[20])
    begin
        ItemCharge.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;
}