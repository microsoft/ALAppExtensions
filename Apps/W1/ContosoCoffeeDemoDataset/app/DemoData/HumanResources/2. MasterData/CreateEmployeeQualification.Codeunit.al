codeunit 5165 "Create Employee Qualification"
{
    trigger OnRun()
    var
        EmployeeQualification: Record "Employee Qualification";
        ContosoHumanResource: Codeunit "Contoso Human Resources";
        Qualification: Codeunit "Create Qualification";
        CreateEmployee: Codeunit "Create Employee";
    begin
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.ManagingDirector(), Qualification.Accountant(), 0D, 0D, EmployeeQualification.Type::External, InternationalTradeGroupLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.ManagingDirector(), Qualification.FluentInFrench(), 0D, 0D, EmployeeQualification.Type::External, InternationalTradeGroupLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.ProductionManager(), Qualification.Accountant(), 0D, 0D, EmployeeQualification.Type::Internal, CronusInternationalLtdLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.ProductionManager(), Qualification.ProjectManager(), 0D, 0D, EmployeeQualification.Type::Internal, CronusInternationalLtdLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.Designer(), Qualification.Designer(), 0D, 0D, EmployeeQualification.Type::External, WorldFamousDesignersLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.Designer(), Qualification.InteriorDesigner(), 0D, 0D, EmployeeQualification.Type::External, WorldFamousDesignersLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.Designer(), Qualification.FluentInGerman(), 0D, 0D, EmployeeQualification.Type::External, WorldFamousDesignersLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.SalesManager(), Qualification.InternationalSales(), 0D, 0D, EmployeeQualification.Type::Internal, CronusInternationalLtdLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.Secretary(), Qualification.QualityManager(), 0D, 0D, EmployeeQualification.Type::Internal, CronusInternationalLtdLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.Secretary(), Qualification.ProductionManager(), 0D, 0D, EmployeeQualification.Type::Internal, CronusInternationalLtdLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.ProductionAssistant(), Qualification.ProductionManager(), 0D, 0D, EmployeeQualification.Type::Internal, CronusInternationalLtdLbl);
        ContosoHumanResource.InsertEmployeeQualification(CreateEmployee.InventoryManager(), Qualification.ProductionManager(), 0D, 0D, EmployeeQualification.Type::Internal, CronusInternationalLtdLbl);
    end;

    var
        InternationalTradeGroupLbl: Label 'International Trade Group', MaxLength = 30;
        CronusInternationalLtdLbl: Label 'Cronus International Ltd.', MaxLength = 30;
        WorldFamousDesignersLbl: Label 'World Famous Designers', MaxLength = 30;
}

