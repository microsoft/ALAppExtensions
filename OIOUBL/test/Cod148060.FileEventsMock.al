codeunit 148060 "OIOUBL-File Events Mock"
{
    EventSubscriberInstance = Manual;

    trigger OnRun();
    begin
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    procedure Setup(me: Codeunit "OIOUBL-File Events Mock")
    begin
        LibraryVariableStorage.Clear();
        if UnbindSubscription(me) then;
        BindSubscription(me);
    end;

    procedure PopFilePath(): Text
    begin
        LibraryVariableStorage.AssertPeekAvailable(1);
        exit(LibraryVariableStorage.DequeueText())
    end;

    procedure TearDown(me: Codeunit "OIOUBL-File Events Mock")
    begin
        UnbindSubscription(me);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OIOUBL-File Events", 'FileCreatedEvent', '', false, false)]
    local procedure SavePathOnFileCreatedEvent(FilePath: Text)
    begin
        LibraryVariableStorage.Enqueue(FilePath);
    end;
}

