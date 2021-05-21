codeunit 1158 "COHUB Show Activity Log"
{
    Access = Internal;

    trigger OnRun()
    var
        ActivityLogPage: Page "Activity Log";
    begin
        ActivityLogPage.Run();
    end;
}

