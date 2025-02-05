codeunit 10801 "Create ES Item Charge"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record "Item Charge")
    var
        CreateItemCharge: Codeunit "Create Item Charge";
        CreateESVATPostingGroups: Codeunit "Create ES VAT Posting Groups";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight(),
            CreateItemCharge.PurchAllowance(),
            CreateItemCharge.PurchFreight(),
            CreateItemCharge.PurchRestock(),
            CreateItemCharge.SaleAllowance(),
            CreateItemCharge.SaleFreight(),
            CreateItemCharge.SaleRestock():
                ValidateRecordFields(Rec, CreateESVATPostingGroups.Vat21());
        end;
    end;

    local procedure ValidateRecordFields(var ItemCharge: Record "Item Charge"; VATProdPostingGroup: Code[20])
    begin
        ItemCharge.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;
}