codeunit 5179 "Create Qualification"
{
    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertQualification(Designer(), DesignerLbl);
        ContosoHumanResources.InsertQualification(InteriorDesigner(), InteriorDesignerLbl);
        ContosoHumanResources.InsertQualification(ProjectManager(), ProjectManagerLbl);
        ContosoHumanResources.InsertQualification(QualityManager(), QualityManagerLbl);
        ContosoHumanResources.InsertQualification(Accountant(), AccountantLbl);
        ContosoHumanResources.InsertQualification(InternationalSales(), InternationalSalesLbl);
        ContosoHumanResources.InsertQualification(ProductionManager(), ProductionManagerLbl);
        ContosoHumanResources.InsertQualification(FluentInFrench(), FluentInFrenchLbl);
        ContosoHumanResources.InsertQualification(FluentInGerman(), FluentInGermanLbl);
    end;

    var
        DesignerTok: Label 'DESIGN', MaxLength = 10;
        DesignerLbl: Label 'Designer', MaxLength = 100;
        InteriorDesignerTok: Label 'INTDESIGN', MaxLength = 10;
        InteriorDesignerLbl: Label 'Interior Designer', MaxLength = 100;
        ProjectManagerTok: Label 'PROJECT', MaxLength = 10;
        ProjectManagerLbl: Label 'Project Manager', MaxLength = 100;
        QualityManagerTok: Label 'QUALITY', MaxLength = 10;
        QualityManagerLbl: Label 'Quality Manager', MaxLength = 100;
        AccountantTok: Label 'ACCOUNTANT', MaxLength = 10;
        AccountantLbl: Label 'Accountant', MaxLength = 100;
        InternationalSalesTok: Label 'INTSALES', MaxLength = 10;
        InternationalSalesLbl: Label 'International Sales', MaxLength = 100;
        ProductionManagerTok: Label 'PROD', MaxLength = 10;
        ProductionManagerLbl: Label 'Production Manager', MaxLength = 100;
        FluentInFrenchTok: Label 'FRENCH', MaxLength = 10;
        FluentInFrenchLbl: Label 'Fluent in French', MaxLength = 100;
        FluentInGermanTok: Label 'GERMAN', MaxLength = 10;
        FluentInGermanLbl: Label 'Fluent in German', MaxLength = 100;

    procedure Designer(): Text[10]
    begin
        exit(DesignerTok);
    end;

    procedure ProductionManager(): Text[10]
    begin
        exit(ProductionManagerTok);
    end;

    procedure InteriorDesigner(): Text[10]
    begin
        exit(InteriorDesignerTok)
    end;

    procedure ProjectManager(): Text[10]
    begin
        exit(ProjectManagerTok)
    end;

    procedure QualityManager(): Text[10]
    begin
        exit(QualityManagerTok)
    end;

    procedure Accountant(): Text[10]
    begin
        exit(AccountantTok)
    end;

    procedure InternationalSales(): Text[10]
    begin
        exit(InternationalSalesTok)
    end;

    procedure FluentInFrench(): Text[10]
    begin
        exit(FluentInFrenchTok)
    end;

    procedure FluentInGerman(): Text[10]
    begin
        exit(FluentInGermanTok)
    end;
}