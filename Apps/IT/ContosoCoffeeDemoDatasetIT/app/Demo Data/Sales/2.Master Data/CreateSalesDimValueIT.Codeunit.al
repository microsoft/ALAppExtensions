codeunit 12239 "Create Sales Dim Value IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", OnBeforeInsertEvent, '', false, false)]
    local procedure OnBeforeInsertCustomerDefaultDimensions(var Rec: Record "Default Dimension")
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        if (Rec."Table ID" = Database::Customer) and (Rec."Dimension Code" = CreateDimension.AreaDimension()) then
            case Rec."No." of
                CreateCustomer.DomesticAdatumCorporation(),
                CreateCustomer.DomesticTreyResearch(),
                CreateCustomer.DomesticRelecloud():
                    ValidateRecordFields(Rec, CreateDimensionValue.EuropeSouthArea());
            end;
    end;

    local procedure ValidateRecordFields(var DefaultDimension: Record "Default Dimension"; DimensionValueCode: Code[20])
    begin
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
    end;
}