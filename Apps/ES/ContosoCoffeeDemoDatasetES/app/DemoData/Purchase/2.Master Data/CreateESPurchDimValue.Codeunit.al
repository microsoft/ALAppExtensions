codeunit 10837 "Create ES Purch. Dim. Value"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", OnBeforeInsertEvent, '', false, false)]
    local procedure OnBeforeInsertVendorDefaultDimensions(var Rec: Record "Default Dimension")
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        if (Rec."Table ID" = Database::Vendor) then
            if Rec."Dimension Code" = CreateDimension.AreaDimension() then
                case Rec."No." of
                    CreateVendor.DomesticFirstUp(),
                    CreateVendor.DomesticWorldImporter(),
                    CreateVendor.DomesticNodPublisher():
                        ValidateRecordFields(Rec, CreateDimensionValue.EuropeSouthArea());
                end;
    end;

    local procedure ValidateRecordFields(var DefaultDimension: Record "Default Dimension"; DimensionValueCode: Code[20])
    begin
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
    end;
}