/// <summary>
/// Provides test initialization integration events for coordinating test setup across different test libraries.
/// </summary>
codeunit 132250 "Library - Test Initialize"
{

    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnTestInitialize(CallerCodeunitID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
    end;
}

