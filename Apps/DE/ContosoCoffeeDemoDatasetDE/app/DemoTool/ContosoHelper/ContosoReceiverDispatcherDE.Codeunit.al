codeunit 11117 "Contoso Receiver/Dispatcher DE"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Place of Receiver" = rim,
        tabledata "Place of Dispatcher" = rim,
        tabledata "Area" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertPlaceOfReceiverData(ReceiverCode: Code[10]; ReceiverPlace: Text[250])
    var
        PlaceofReceiver: Record "Place of Receiver";
        Exists: Boolean;
    begin
        if PlaceofReceiver.Get(ReceiverCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PlaceofReceiver.Init();
        PlaceofReceiver.Validate(Code, ReceiverCode);
        PlaceofReceiver.Validate(Text, ReceiverPlace);

        if Exists then
            PlaceofReceiver.Modify(true)
        else
            PlaceofReceiver.Insert(true);
    end;

    procedure InsertPlaceOfDispatcherData(DispatcherCode: Code[10]; DispatcherPlace: Text[250])
    var
        PlaceofDispatcher: Record "Place of Dispatcher";
        Exists: Boolean;
    begin
        if PlaceofDispatcher.Get(DispatcherCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PlaceofDispatcher.Init();
        PlaceofDispatcher.Validate(Code, DispatcherCode);
        PlaceofDispatcher.Validate(Text, DispatcherPlace);

        if Exists then
            PlaceofDispatcher.Modify(true)
        else
            PlaceofDispatcher.Insert(true);
    end;

    procedure InsertAreaData(AreaCode: Code[10]; AreaPlace: Text[250])
    var
        AreaData: Record "Area";
        Exists: Boolean;
    begin
        if AreaData.Get(AreaCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AreaData.Init();
        AreaData.Validate(Code, AreaCode);
        AreaData.Validate(Text, AreaPlace);

        if Exists then
            AreaData.Modify(true)
        else
            AreaData.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}