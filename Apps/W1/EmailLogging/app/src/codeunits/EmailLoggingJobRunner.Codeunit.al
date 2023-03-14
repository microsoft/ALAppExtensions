codeunit 1683 "Email Logging Job Runner"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        EmailLoggingInvoke: Codeunit "Email Logging Invoke";
    begin
        if not EmailLoggingInvoke.Run() then
            Error(ErrorMessageTxt, EmailLoggingInvoke.GetErrorContext(), GetLastErrorText());
    end;

    var
        ErrorMessageTxt: Label '%1 : %2.', Locked = true;
}

