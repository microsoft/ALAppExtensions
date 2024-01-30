codeunit 5185 "Create Confidential Info."
{

    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
        CreateEmployee: Codeunit "Create Employee";
        CreateConfidential: Codeunit "Create Confidential";
    begin
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ManagingDirector(), CreateConfidential.Insurance());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ManagingDirector(), CreateConfidential.Salary());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ManagingDirector(), CreateConfidential.Retire());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ManagingDirector(), CreateConfidential.Stock());

        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ProductionManager(), CreateConfidential.Insurance());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ProductionManager(), CreateConfidential.Salary());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ProductionManager(), CreateConfidential.Retire());

        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Designer(), CreateConfidential.Insurance());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Designer(), CreateConfidential.Salary());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Designer(), CreateConfidential.Retire());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Designer(), CreateConfidential.Stock());


        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.SalesManager(), CreateConfidential.Insurance());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.SalesManager(), CreateConfidential.Salary());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.SalesManager(), CreateConfidential.Retire());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.SalesManager(), CreateConfidential.Stock());

        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Secretary(), CreateConfidential.Insurance());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Secretary(), CreateConfidential.Salary());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Secretary(), CreateConfidential.Retire());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.Secretary(), CreateConfidential.Stock());

        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ProductionAssistant(), CreateConfidential.Insurance());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ProductionAssistant(), CreateConfidential.Salary());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ProductionAssistant(), CreateConfidential.Retire());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.ProductionAssistant(), CreateConfidential.Stock());


        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.InventoryManager(), CreateConfidential.Insurance());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.InventoryManager(), CreateConfidential.Salary());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.InventoryManager(), CreateConfidential.Retire());
        ContosoHumanResources.InsertConfidentialInformation(CreateEmployee.InventoryManager(), CreateConfidential.Stock());
    end;

}