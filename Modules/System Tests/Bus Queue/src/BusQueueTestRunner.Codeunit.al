codeunit 51759 "Bus Queue Test Runner"
{
    Access = Public;
    Subtype = TestRunner;
    TestIsolation = Function;

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Bus Queue E2E");
    end;    
}