codeunit 10509 "Create GB Sales DimensionValue"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDimension: Codeunit "Contoso Dimension";
        CreateCustomer: Codeunit "Create Customer";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticAdatumCorporation(), CreateDimension.DepartmentDimension(), CreateDimensionValue.SalesDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticTreyResearch(), CreateDimension.DepartmentDimension(), CreateDimensionValue.SalesDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.ExportSchoolofArt(), CreateDimension.DepartmentDimension(), CreateDimensionValue.SalesDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.EUAlpineSkiHouse(), CreateDimension.DepartmentDimension(), CreateDimensionValue.SalesDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticRelecloud(), CreateDimension.DepartmentDimension(), CreateDimensionValue.SalesDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", OnBeforeInsertEvent, '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Default Dimension")
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.DomesticAdatumCorporation()) and (Rec."Dimension Code" = CreateDimension.CustomerGroupDimension()) then
            ValidateRecordFields(Rec, CreateDimensionValue.SmallBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::" ");

        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.DomesticTreyResearch()) and (Rec."Dimension Code" = CreateDimension.CustomerGroupDimension()) then
            ValidateRecordFields(Rec, CreateDimensionValue.MediumBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::" ");

        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.ExportSchoolofArt()) and (Rec."Dimension Code" = CreateDimension.CustomerGroupDimension()) then
            ValidateRecordFields(Rec, CreateDimensionValue.LargeBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::" ");

        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.EUAlpineSkiHouse()) and (Rec."Dimension Code" = CreateDimension.CustomerGroupDimension()) then
            ValidateRecordFields(Rec, CreateDimensionValue.SmallBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::" ");

        if (Rec."Table ID" = Database::Customer) and (Rec."No." = CreateCustomer.DomesticRelecloud()) and (Rec."Dimension Code" = CreateDimension.CustomerGroupDimension()) then
            ValidateRecordFields(Rec, CreateDimensionValue.MediumBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::" ");
    end;

    local procedure ValidateRecordFields(var DefaultDimension: Record "Default Dimension"; DimensionValueCode: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type")
    begin
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
        DefaultDimension.Validate("Value Posting", ValuePosting);
    end;
}