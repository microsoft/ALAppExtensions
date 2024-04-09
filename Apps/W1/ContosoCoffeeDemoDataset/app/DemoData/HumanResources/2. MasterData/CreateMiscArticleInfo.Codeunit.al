codeunit 5184 "Create Misc. Article Info."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
        CreateEmployee: Codeunit "Create Employee";
        CreateMiscArticle: Codeunit "Create Misc. Article";
    begin
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ManagingDirector(), CreateMiscArticle.Computer());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ManagingDirector(), CreateMiscArticle.CompanyKey());

        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ProductionManager(), CreateMiscArticle.Computer());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ProductionManager(), CreateMiscArticle.CompanyKey());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ProductionManager(), CreateMiscArticle.CreditCard());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ProductionManager(), CreateMiscArticle.CompanyCar());

        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.Designer(), CreateMiscArticle.Computer());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.Designer(), CreateMiscArticle.CompanyCar());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.Designer(), CreateMiscArticle.CompanyKey());

        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.SalesManager(), CreateMiscArticle.Computer());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.SalesManager(), CreateMiscArticle.CompanyKey());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.SalesManager(), CreateMiscArticle.CompanyCar());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.SalesManager(), CreateMiscArticle.CreditCard());

        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.Secretary(), CreateMiscArticle.Computer());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.Secretary(), CreateMiscArticle.CompanyKey());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.Secretary(), CreateMiscArticle.CompanyCar());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.Secretary(), CreateMiscArticle.CreditCard());

        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ProductionAssistant(), CreateMiscArticle.Computer());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ProductionAssistant(), CreateMiscArticle.CompanyKey());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.ProductionAssistant(), CreateMiscArticle.CompanyCar());

        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.InventoryManager(), CreateMiscArticle.Computer());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.InventoryManager(), CreateMiscArticle.CompanyKey());
        ContosoHumanResources.InsertMiscArticleInformation(CreateEmployee.InventoryManager(), CreateMiscArticle.CompanyCar());
    end;
}