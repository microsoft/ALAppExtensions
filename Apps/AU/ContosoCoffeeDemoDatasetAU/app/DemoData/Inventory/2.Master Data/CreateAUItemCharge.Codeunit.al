codeunit 17120 "Create AU Item Charge"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record "Item Charge"; RunTrigger: Boolean)
    var
        CreateItemCharge: Codeunit "Create Item Charge";
        CreateAUVATPostingGroups: Codeunit "Create AU VAT Posting Groups";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight(),
            CreateItemCharge.PurchAllowance(),
            CreateItemCharge.PurchFreight(),
            CreateItemCharge.PurchRestock(),
            CreateItemCharge.SaleAllowance(),
            CreateItemCharge.SaleFreight(),
            CreateItemCharge.SaleRestock():
                ValidateRecordFields(Rec, CreateAUVATPostingGroups.Vat10());
        end;
    end;

    local procedure ValidateRecordFields(var ItemCharge: Record "Item Charge"; VATProdPostingGroup: Code[20])
    begin
        ItemCharge.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;
}