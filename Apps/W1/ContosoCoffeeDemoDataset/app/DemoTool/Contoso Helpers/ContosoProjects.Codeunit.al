codeunit 5662 "Contoso Projects"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata Resource = rim,
                    tabledata "Resources Setup" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertResourcesSetup(ResourceNos: Code[20]; TimeSheetNos: Code[20])
    var
        ResourcesSetup: Record "Resources Setup";
    begin
        if not ResourcesSetup.Get() then
            ResourcesSetup.Insert();

        ResourcesSetup.Validate("Resource Nos.", ResourceNos);
        ResourcesSetup.Validate("Time Sheet Nos.", TimeSheetNos);
        ResourcesSetup.Modify(true);
    end;

    procedure InsertResource(No: Code[20]; ResourceType: Enum "Resource Type"; Name: Text[100]; Address: Text[100]; City: Text[30]; JobTitle: Text[30]; EmploymentDate: Date; BaseUnitOfMeasure: Code[10]; DirectUnitCost: Decimal; IndirectCostPercentage: Decimal; UnitCost: Decimal; ProfitPercentage: Decimal; PriceProfitCalculation: Integer; UnitPrice: Decimal; GenProdPostingGroup: Code[20]; PostCode: Code[20]; VATProdPostingGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        Resource: Record "Resource";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if Resource.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Resource.Validate("No.", No);
        Resource.Validate(Type, ResourceType);
        Resource.Validate(Name, Name);
        Resource.Validate(Address, Address);
        Resource.Validate(City, City);
        Resource.Validate("Job Title", JobTitle);
        Resource.Validate("Employment Date", EmploymentDate);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Indirect Cost %", IndirectCostPercentage);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Price/Profit Calculation", PriceProfitCalculation);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        Resource.Validate("Post Code", PostCode);
        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);

        if Exists then
            Resource.Modify(true)
        else
            Resource.Insert(true);

        if BaseUnitOfMeasure <> '' then begin
            Resource.Validate("Base Unit of Measure", BaseUnitOfMeasure);
            Resource.Modify(true);
        end;
    end;
}