codeunit 5176 "Create Employee Absence"
{
    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
        CreateEmployee: Codeunit "Create Employee";
        CausesOfAbsence: Codeunit "Create Causes of Absence";
        CommonUoM: Codeunit "Create Common Unit Of Measure";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.InventoryManager(), ContosoUtilities.AdjustDate(19020112D), 0D, CausesOfAbsence.Sick(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.InventoryManager(), ContosoUtilities.AdjustDate(19020115D), 0D, CausesOfAbsence.DayOff(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.InventoryManager(), ContosoUtilities.AdjustDate(19020607D), ContosoUtilities.AdjustDate(19020611D), CausesOfAbsence.Holiday(), 5, CommonUoM.Day());

        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.Secretary(), ContosoUtilities.AdjustDate(19020302D), 0D, CausesOfAbsence.Sick(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.Secretary(), ContosoUtilities.AdjustDate(19020322D), 0D, CausesOfAbsence.DayOff(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.Secretary(), ContosoUtilities.AdjustDate(19020719D), ContosoUtilities.AdjustDate(19020730D), CausesOfAbsence.Holiday(), 5, CommonUoM.Day());

        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ProductionAssistant(), ContosoUtilities.AdjustDate(19020201D), 0D, CausesOfAbsence.Sick(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ProductionAssistant(), ContosoUtilities.AdjustDate(19020402D), 0D, CausesOfAbsence.DayOff(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ProductionAssistant(), ContosoUtilities.AdjustDate(19020607D), ContosoUtilities.AdjustDate(19020611D), CausesOfAbsence.Holiday(), 5, CommonUoM.Day());

        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ProductionManager(), ContosoUtilities.AdjustDate(19020225D), 0D, CausesOfAbsence.Sick(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ProductionManager(), ContosoUtilities.AdjustDate(19020430D), 0D, CausesOfAbsence.DayOff(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ProductionManager(), ContosoUtilities.AdjustDate(19020621D), ContosoUtilities.AdjustDate(19020702D), CausesOfAbsence.Holiday(), 5, CommonUoM.Day());

        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.Designer(), ContosoUtilities.AdjustDate(19020114D), 0D, CausesOfAbsence.Sick(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.Designer(), ContosoUtilities.AdjustDate(19020322D), 0D, CausesOfAbsence.DayOff(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.Designer(), ContosoUtilities.AdjustDate(19020614D), ContosoUtilities.AdjustDate(19020618D), CausesOfAbsence.Holiday(), 5, CommonUoM.Day());

        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.SalesManager(), ContosoUtilities.AdjustDate(19020115D), 0D, CausesOfAbsence.Sick(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.SalesManager(), ContosoUtilities.AdjustDate(19020309D), 0D, CausesOfAbsence.DayOff(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.SalesManager(), ContosoUtilities.AdjustDate(19020614D), ContosoUtilities.AdjustDate(19020618D), CausesOfAbsence.Holiday(), 5, CommonUoM.Day());

        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ManagingDirector(), ContosoUtilities.AdjustDate(19020112D), 0D, CausesOfAbsence.Sick(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ManagingDirector(), ContosoUtilities.AdjustDate(19020115D), 0D, CausesOfAbsence.DayOff(), 8, CommonUoM.Hour());
        ContosoHumanResources.InsertEmployeeAbsence(CreateEmployee.ManagingDirector(), ContosoUtilities.AdjustDate(19020607D), ContosoUtilities.AdjustDate(19020611D), CausesOfAbsence.Holiday(), 8, CommonUoM.Day());
    end;
}