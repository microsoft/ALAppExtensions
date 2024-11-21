codeunit 27059 "Create CA Item Charge"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Item Charge")
    var
        CreateItemCharge: Codeunit "Create Item Charge";
        CreateCATaxGroup: Codeunit "Create CA Tax Group";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight():
                ValidateRecordFields(Rec, CreateCATaxGroup.Taxable());
            CreateItemCharge.PurchAllowance():
                ValidateRecordFields(Rec, CreateCATaxGroup.Taxable());
            CreateItemCharge.PurchFreight():
                ValidateRecordFields(Rec, CreateCATaxGroup.Taxable());
            CreateItemCharge.PurchRestock():
                ValidateRecordFields(Rec, CreateCATaxGroup.Taxable());
            CreateItemCharge.SaleAllowance():
                ValidateRecordFields(Rec, CreateCATaxGroup.Taxable());
            CreateItemCharge.SaleFreight():
                ValidateRecordFields(Rec, CreateCATaxGroup.Taxable());
            CreateItemCharge.SaleRestock():
                ValidateRecordFields(Rec, CreateCATaxGroup.Taxable());
        end;
    end;

    local procedure ValidateRecordFields(var ItemCharge: Record "Item Charge"; TaxGroupCode: Code[20])
    begin
        ItemCharge.Validate("Tax Group Code", TaxGroupCode);
    end;
}