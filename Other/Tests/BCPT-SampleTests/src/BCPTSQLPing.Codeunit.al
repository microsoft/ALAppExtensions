codeunit 149117 "BCPT SQL Ping"
{
    trigger OnRun();
    var
        i: Integer;
    begin
        SelectLatestVersion(); // bypass the NST cache
        for i := 1 to 100 do begin
            SelectLatestVersion(); // bypass the NST cache
            GLsetup.Get();
        end;
    end;

    var
        GLsetup: Record "General Ledger Setup";
}