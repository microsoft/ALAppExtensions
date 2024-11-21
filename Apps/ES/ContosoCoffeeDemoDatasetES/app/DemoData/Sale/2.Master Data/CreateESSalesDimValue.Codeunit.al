codeunit 10836 "Create ES Sales Dim Value"
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
        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.DomesticAdatumCorporation()) then
            case Rec."Dimension Code" of
                CreateDimension.AreaDimension():
                    ValidateRecordFields(Rec, CreateDimensionValue.EuropeSouthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
            // CreateDimension.CustomerGroupDimension():
            //     ValidateRecordFields(Rec, CreateDimensionValue.MediumBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");
            end;

        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.DomesticTreyResearch()) then
            case Rec."Dimension Code" of
                CreateDimension.AreaDimension():
                    ValidateRecordFields(Rec, CreateDimensionValue.EuropeSouthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
            // CreateDimension.CustomerGroupDimension():
            //     ValidateRecordFields(Rec, CreateDimensionValue.LargeBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");
            end;

        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.DomesticRelecloud()) then
            case Rec."Dimension Code" of
                CreateDimension.AreaDimension():
                    ValidateRecordFields(Rec, CreateDimensionValue.EuropeSouthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
            // CreateDimension.CustomerGroupDimension():
            //     ValidateRecordFields(Rec, CreateDimensionValue.MediumBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");
            end;
    end;

    local procedure ValidateRecordFields(var DefaultDimension: Record "Default Dimension"; DimensionValueCode: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type")
    begin
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
        DefaultDimension.Validate("Value Posting", ValuePosting);
    end;
}