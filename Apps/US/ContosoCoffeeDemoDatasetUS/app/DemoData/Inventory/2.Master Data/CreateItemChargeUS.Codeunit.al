codeunit 10600 "Create Item Charge US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Item Charge")
    var
        CreateItemCharge: Codeunit "Create Item Charge";
        CreateTaxGroupUS: Codeunit "Create Tax Group US";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight():
                ValidateRecordFields(Rec, CreateTaxGroupUS.Labor(), '');
            CreateItemCharge.PurchAllowance():
                ValidateRecordFields(Rec, CreateTaxGroupUS.Labor(), '');
            CreateItemCharge.PurchFreight():
                ValidateRecordFields(Rec, CreateTaxGroupUS.Labor(), '');
            CreateItemCharge.PurchRestock():
                ValidateRecordFields(Rec, CreateTaxGroupUS.Labor(), '');
            CreateItemCharge.SaleAllowance():
                ValidateRecordFields(Rec, CreateTaxGroupUS.Labor(), '');
            CreateItemCharge.SaleFreight():
                ValidateRecordFields(Rec, CreateTaxGroupUS.Labor(), '');
            CreateItemCharge.SaleRestock():
                ValidateRecordFields(Rec, CreateTaxGroupUS.Labor(), '');
        end;
    end;

    local procedure ValidateRecordFields(var ItemCharge: Record "Item Charge"; TaxGroupCode: Code[20]; VATProdPostingGroup: Code[20])
    begin
        ItemCharge.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        ItemCharge.Validate("Tax Group Code", TaxGroupCode);
    end;
}