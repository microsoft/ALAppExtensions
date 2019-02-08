codeunit 13667 "OIOUBL-File Events"
{
    procedure FileCreated(FilePath: Text)
    begin
        FileCreatedEvent(FilePath);
    end;

    [IntegrationEvent(false, false)]
    local procedure FileCreatedEvent(FilePath: Text)
    begin
    end;
}