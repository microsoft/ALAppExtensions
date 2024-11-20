codeunit 5412 "Create Sales Dimension Value"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDimension: Codeunit "Contoso Dimension";
        CreateCustomer: Codeunit "Create Customer";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticAdatumCorporation(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthNonEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticAdatumCorporation(), CreateDimension.CustomerGroupDimension(), CreateDimensionValue.MediumBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");

        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticTreyResearch(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthNonEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticTreyResearch(), CreateDimension.CustomerGroupDimension(), CreateDimensionValue.LargeBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");

        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.ExportSchoolofArt(), CreateDimension.AreaDimension(), CreateDimensionValue.AmericaNorthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory", CreateDimensionValue.AmericaNorthArea() + '|' + CreateDimensionValue.AmericaSouthArea());
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.ExportSchoolofArt(), CreateDimension.BusinessGroupDimension(), CreateDimensionValue.HomeBusinessGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.ExportSchoolofArt(), CreateDimension.CustomerGroupDimension(), CreateDimensionValue.MediumBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");

        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.EUAlpineSkiHouse(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.EUAlpineSkiHouse(), CreateDimension.CustomerGroupDimension(), CreateDimensionValue.SmallBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");

        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticRelecloud(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthNonEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticRelecloud(), CreateDimension.BusinessGroupDimension(), CreateDimensionValue.OfficeBusinessGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");
        ContosoDimension.InsertDefaultDimensionValue(Database::Customer, CreateCustomer.DomesticRelecloud(), CreateDimension.CustomerGroupDimension(), CreateDimensionValue.MediumBusinessCustomerGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");
    end;
}