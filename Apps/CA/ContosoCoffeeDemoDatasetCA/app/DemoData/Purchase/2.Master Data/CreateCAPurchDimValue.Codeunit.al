codeunit 27083 "Create CA Purch. Dim. Value"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", OnBeforeInsertEvent, '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Default Dimension")
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        if (Rec."Table ID" = Database::Vendor) and (Rec."Dimension Code" = CreateDimension.AreaDimension()) then
            case Rec."No." of
                CreateVendor.DomesticFirstUp():
                    ValidateRecordFields(Rec, CreateDimensionValue.AmericaNorthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
                CreateVendor.EUGraphicDesign():
                    ValidateRecordFields(Rec, CreateDimensionValue.AmericaNorthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
                CreateVendor.DomesticWorldImporter():
                    ValidateRecordFields(Rec, CreateDimensionValue.AmericaNorthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
                CreateVendor.DomesticNodPublisher():
                    ValidateRecordFields(Rec, CreateDimensionValue.AmericaNorthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
            end;
    end;

    local procedure ValidateRecordFields(var DefaultDimension: Record "Default Dimension"; DimensionValueCode: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type")
    begin
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
        DefaultDimension.Validate("Value Posting", ValuePosting);
    end;
}