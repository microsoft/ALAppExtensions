codeunit 149124 "BCPT Calculate Plan Worksheet"
{
    trigger OnRun()
    begin
        CalculatePlan();
    end;

    local procedure CalculatePlan()
    var
        CalculatePlanPlanWksh: Report "Calculate Plan - Plan. Wksh.";
        StartingDate: Date;
        EndingDate: Date;
    begin
        //Start Calculate regenerative plan of the current month 
        StartingDate := CalcDate('<-CM>', WorkDate());
        EndingDate := CalcDate('<CM>', WorkDate());
        CalculatePlanPlanWksh.UseRequestPage(false);
        CalculatePlanPlanWksh.InitializeRequest(StartingDate, EndingDate, true);
        CalculatePlanPlanWksh.Run();
    end;
}