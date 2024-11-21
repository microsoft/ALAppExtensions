codeunit 5294 "Create CRM Dimension Value"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateDimensionValue();
        CreateDefaultDimension();
    end;

    local procedure CreateDimensionValue()
    var
        CreateCRMDimension: Codeunit "Create CRM Dimension";
        CreateEmployee: Codeunit "Create Employee";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        ContosoDimension: Codeunit "Contoso Dimension";
        DimensionValueIndent: Codeunit "Dimension Value-Indent";
    begin
        ContosoDimension.InsertDimensionValue(CreateCRMDimension.Purchaser(), CreateEmployee.ProductionAssistant(), 'Marty Horst', 0, '');
        ContosoDimension.InsertDimensionValue(CreateCRMDimension.Purchaser(), SalespersonPurchaser.RobinBettencourt(), 'Robin Bettencourt', 0, '');
        ContosoDimension.InsertDimensionValue(CreateCRMDimension.Purchaser(), CreateEmployee.InventoryManager(), 'Terry Dodds', 0, '');

        ContosoDimension.InsertDimensionValue(CreateCRMDimension.SalesPerson(), SalespersonPurchaser.JimOlive(), 'Jim Olive', 0, '');
        ContosoDimension.InsertDimensionValue(CreateCRMDimension.SalesPerson(), SalespersonPurchaser.LinaTownsend(), 'Lina Townsend', 0, '');
        ContosoDimension.InsertDimensionValue(CreateCRMDimension.SalesPerson(), SalespersonPurchaser.OtisFalls(), 'Otis Falls', 0, '');

        DimensionValueIndent.Indent();
    end;

    local procedure CreateDefaultDimension()
    var
        ContosoDimension: Codeunit "Contoso Dimension";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateCRMDimension: Codeunit "Create CRM Dimension";
    begin
        ContosoDimension.InsertDefaultDimensionValue(Database::"Salesperson/Purchaser", SalespersonPurchaser.JimOlive(), CreateCRMDimension.SalesPerson(), SalespersonPurchaser.JimOlive(), Enum::"Default Dimension Value Posting Type"::"Same Code");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Salesperson/Purchaser", SalespersonPurchaser.LinaTownsend(), CreateCRMDimension.SalesPerson(), SalespersonPurchaser.LinaTownsend(), Enum::"Default Dimension Value Posting Type"::"Same Code");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Salesperson/Purchaser", SalespersonPurchaser.OtisFalls(), CreateCRMDimension.SalesPerson(), SalespersonPurchaser.OtisFalls(), Enum::"Default Dimension Value Posting Type"::"Same Code");

        ContosoDimension.InsertDefaultDimensionValue(Database::"Salesperson/Purchaser", SalespersonPurchaser.RobinBettencourt(), CreateCRMDimension.Purchaser(), SalespersonPurchaser.RobinBettencourt(), Enum::"Default Dimension Value Posting Type"::"Same Code");
    end;
}