codeunit 20287 "Use Case Event Library"
{
    procedure AddUseCaseEventToLibrary(FunctionName: Text[100]; TableID: Integer; Description: Text[250]);
    begin
        OnAfterAddUseCaseEventToLibrary(FunctionName, TableID, Description);
    end;

    procedure HandleBusinessUseCaseEvent(EventName: Text[150]; Record: Variant; CurrencyCode: Code[20]; CurrencyFactor: Decimal);
    begin
        OnAfterHandleBusinessUseCaseEvent(EventName, Record, CurrencyCode, CurrencyFactor);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAddUseCaseEventstoLibrary();
    begin

    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAddUseCaseEventToLibrary(FunctionName: Text[100]; TableID: Integer; Description: Text[250]);
    begin

    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterHandleBusinessUseCaseEvent(EventName: Text[150]; Record: Variant; CurrencyCode: Code[20]; CurrencyFactor: Decimal);
    begin

    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRunBusinessUseCaseEngine(UseCaseID: Guid; var Record: Variant);
    begin

    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRunTaxUseCaseEngine(UseCaseID: Guid; var Record: Variant);
    begin

    end;
}