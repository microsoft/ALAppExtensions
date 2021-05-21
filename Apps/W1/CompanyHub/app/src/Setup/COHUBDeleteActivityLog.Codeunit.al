codeunit 1159 "COHUB Delete Activity Log"
{
    Access = Internal;

    trigger OnRun()
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.SetRange(Context, ActivityContextTxt);
        ActivityLog.SetRange("User ID", UserId());
        ActivityLog.DeleteAll();
    end;

    var
        ActivityContextTxt: Label 'Company Hub';
}

