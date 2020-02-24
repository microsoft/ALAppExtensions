codeunit 1453 "MS - Yodlee Account Cleanup"
{

    trigger OnRun();
    begin
        CleanUpAccount();
    end;

    local procedure CleanUpAccount();
    var
        MSYodleeBankServiceSetup: Record 1450;
        MSYodleeServiceMgt: Codeunit 1450;
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN
            EXIT;

        IF NOT (MSYodleeBankServiceSetup.Enabled AND MSYodleeBankServiceSetup."Accept Terms of Use") THEN
            EXIT;

        IF MSYodleeBankServiceSetup.HasDefaultCredentials() AND
           (MSYodleeBankServiceSetup."Consumer Name" <> '') AND
           MSYodleeBankServiceSetup.HasPassword(MSYodleeBankServiceSetup."Consumer Password")
        THEN BEGIN
            MSYodleeServiceMgt.SetDisableRethrowException(TRUE);
            MSYodleeServiceMgt.UnregisterConsumer();
        END;
    end;

    local procedure VerifySessionResults(var TempNameValueBuffer: Record 823 temporary): Boolean;
    var
        ActiveSession: Record 2000000110;
        SessionId: Integer;
        Timeout: Integer;
        Delay: Integer;
        TotalTime: Integer;
        Errors: Boolean;
    begin
        // Wait for sessions to complete
        Timeout := 300 * 1000; // 5 mins
        Delay := 100;
        TotalTime := 0;
        Errors := FALSE;

        REPEAT
            SLEEP(Delay);
            TempNameValueBuffer.FINDSET();

            REPEAT
                EVALUATE(SessionId, TempNameValueBuffer.Value);
                ActiveSession.SetRange("Server Instance ID", ServiceInstanceId());
                ActiveSession.SetRange("Session ID", Sessionid);
                IF ActiveSession.IsEmpty() THEN BEGIN
                    IF NOT Errors THEN
                        Errors := NOT VerifyConsumerRemoved(TempNameValueBuffer.Name); // Verify result
                    TempNameValueBuffer.DELETE();
                END;
            UNTIL TempNameValueBuffer.NEXT() = 0;

            TotalTime += Delay;
        UNTIL TempNameValueBuffer.ISEMPTY() OR (TotalTime > Timeout);

        IF TotalTime > Timeout THEN BEGIN // we timed out
            TerminateRemainingSessions(TempNameValueBuffer);
            EXIT(FALSE);
        END;

        EXIT(NOT Errors)
    end;

    local procedure TerminateRemainingSessions(TempNameValueBuffer: Record 823 temporary);
    var
        SessionId: Integer;
    begin
        IF NOT TempNameValueBuffer.FINDSET() THEN
            EXIT;

        REPEAT
            EVALUATE(SessionId, TempNameValueBuffer.Value);
            STOPSESSION(SessionId);
        UNTIL TempNameValueBuffer.NEXT() = 0;
    end;

    local procedure VerifyConsumerRemoved(Company: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record 1450;
    begin
        MSYodleeBankServiceSetup.CHANGECOMPANY(Company);
        IF MSYodleeBankServiceSetup.GET() THEN
            IF (MSYodleeBankServiceSetup."Consumer Name" <> '') OR (NOT ISNULLGUID(MSYodleeBankServiceSetup."Consumer Password")) THEN
                EXIT(FALSE);
        EXIT(TRUE);
    end;

}

