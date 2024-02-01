codeunit 5166 "Create Employee Relative"
{
    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
        CreateEmployee: Codeunit "Create Employee";
        ContosoUtilities: Codeunit "Contoso Utilities";
        Relative: Codeunit "Create Relatives";
    begin
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.ManagingDirector(), Relative.Husband(), JamesLbl, ContosoUtilities.AdjustDate(19020404D), 30);
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.ManagingDirector(), Relative.Child1(), MaryLbl, ContosoUtilities.AdjustDate(19020725D), 5);
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.ManagingDirector(), Relative.Child2(), ArthurLbl, ContosoUtilities.AdjustDate(19020926D), 3);

        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.ProductionManager(), Relative.Wife(), JuliaLbl, ContosoUtilities.AdjustDate(19020607D), 50);
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.ProductionManager(), Relative.Child1(), ElisabethLbl, ContosoUtilities.AdjustDate(19020318D), 25);
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.ProductionManager(), Relative.Child2(), LiamLbl, ContosoUtilities.AdjustDate(19020416D), 21);

        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.Designer(), Relative.Husband(), FrancoLbl, ContosoUtilities.AdjustDate(19020423D), 33);
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.Designer(), Relative.Child1(), CharlesLbl, ContosoUtilities.AdjustDate(19020529D), 8);

        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.SalesManager(), Relative.Wife(), DianaLbl, ContosoUtilities.AdjustDate(19021112D), 31);
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.SalesManager(), Relative.Child1(), JamesLbl, ContosoUtilities.AdjustDate(19020929D), 6);

        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.Secretary(), Relative.Wife(), SofieLbl, ContosoUtilities.AdjustDate(19020815D), 33);
        ContosoHumanResources.InsertEmployeeRelative(CreateEmployee.Secretary(), Relative.Child1(), MaryLbl, ContosoUtilities.AdjustDate(19021026D), 9);
    end;

    var
        JamesLbl: Label 'James', MaxLength = 30;
        MaryLbl: Label 'Mary', MaxLength = 30;
        ArthurLbl: Label 'Arthur', MaxLength = 30;
        JuliaLbl: Label 'Julia', MaxLength = 30;
        ElisabethLbl: Label 'Elisabeth', MaxLength = 30;
        LiamLbl: Label 'Liam', MaxLength = 30;
        FrancoLbl: Label 'Franco', MaxLength = 30;
        SofieLbl: Label 'Sofie', MaxLength = 30;
        DianaLbl: Label 'Diana', MaxLength = 30;
        CharlesLbl: Label 'Charles', MaxLength = 30;
}