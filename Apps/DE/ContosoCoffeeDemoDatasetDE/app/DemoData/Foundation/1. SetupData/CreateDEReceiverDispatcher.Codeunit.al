codeunit 11116 "Create DE Receiver/Dispatcher"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateDEPlaceOfReceiver();
        CreateDEPlaceOfDispatcher();
    end;

    local procedure CreateDEPlaceOfReceiver()
    var
        ContosoPlaceofReceiver: Codeunit "Contoso Receiver/Dispatcher DE";
    begin
        ContosoPlaceofReceiver.InsertPlaceOfReceiverData('1', ReceiveDispatcherPlace1Lbl);
        ContosoPlaceofReceiver.InsertPlaceOfReceiverData('3', ReceiveDispatcherPlace3Lbl);
        ContosoPlaceofReceiver.InsertPlaceOfReceiverData('6', ReceiverPlace6Lbl);
        ContosoPlaceofReceiver.InsertPlaceOfReceiverData('7', ReceiverPlace7Lbl);
        ContosoPlaceofReceiver.InsertPlaceOfReceiverData('8', ReceiverPlace8Lbl);
        ContosoPlaceofReceiver.InsertPlaceOfReceiverData('9', ReceiverPlace9Lbl);
    end;

    local procedure CreateDEPlaceOfDispatcher()
    var
        ContosoPlaceofDispatcher: Codeunit "Contoso Receiver/Dispatcher DE";
    begin
        ContosoPlaceofDispatcher.InsertPlaceOfDispatcherData('1', ReceiveDispatcherPlace1Lbl);
        ContosoPlaceofDispatcher.InsertPlaceOfDispatcherData('5', ReceiveDispatcherPlace3Lbl);
        ContosoPlaceofDispatcher.InsertPlaceOfDispatcherData('7', DispatcherPlace7Lbl);
        ContosoPlaceofDispatcher.InsertPlaceOfDispatcherData('9', DispatcherPlace9Lbl);
    end;

    var
        ReceiveDispatcherPlace1Lbl: Label 'in Hamburg', MaxLength = 250;
        ReceiveDispatcherPlace3Lbl: Label 'in Bremen und Bremerhaven', MaxLength = 250;
        ReceiverPlace6Lbl: Label 'in Berlin (West)', MaxLength = 250;
        ReceiverPlace7Lbl: Label 'im Saarland', MaxLength = 250;
        ReceiverPlace8Lbl: Label 'in Lübeck', MaxLength = 250;
        ReceiverPlace9Lbl: Label 'sowie Brandenburg, Mecklenburg-Vorpommern, Sachsen, Sachsen-Anhalt, Thüringen', MaxLength = 250;
        DispatcherPlace7Lbl: Label 'in Lübeck, Brandenburg, Mecklenburg-Vorpommern, Sachsen, Sachsen-Anhalt', MaxLength = 250;
        DispatcherPlace9Lbl: Label 'sowie Brandenburg, Mecklenburg-Vorpommern, Sachsen, Sachsen-Anhalt, Thüringen', MaxLength = 250;
}