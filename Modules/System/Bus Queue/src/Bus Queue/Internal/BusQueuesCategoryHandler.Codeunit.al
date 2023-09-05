codeunit 51756 "Bus Queues Category Handler"
{
    Access = Internal;
    TableNo = "Bus Queue";
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        HandleBusQueuesByCategory(Rec."Category Code");
    end;

    local procedure HandleBusQueuesByCategory(CategoryCode: Code[10])
    var
        BusQueue: Record "Bus Queue";
        ListEntryNoToBeProcessed: List of [Integer];
    begin
        ListEntryNoToBeProcessed := GetBusQueuesToBeProcessed(CategoryCode);
        if ListEntryNoToBeProcessed.Count() = 0 then
            exit;

        BusQueue.SetRange(Status, BusQueue.Status::Pending);
        BusQueue.SetRange("Category Code", CategoryCode);
        BusQueue.ModifyAll(Status, BusQueue.Status::Processing);

        HandleBusQueues(ListEntryNoToBeProcessed);            
    end;

    local procedure GetBusQueuesToBeProcessed(CategoryCode: Code[10]): List of [Integer]
    var
        BusQueue: Record "Bus Queue";
        ListEntryNoToBeProcessed: List of [Integer];
    begin
        BusQueue.SetLoadFields("Entry No.", Status);
        BusQueue.SetRange(Status, BusQueue.Status::Pending);
        BusQueue.SetRange("Category Code", CategoryCode);
        if BusQueue.FindSet(true) then
            repeat
                ListEntryNoToBeProcessed.Add(BusQueue."Entry No.");
            until BusQueue.Next() = 0;

        exit(ListEntryNoToBeProcessed);
    end;

    local procedure HandleBusQueues(ListEntryNoToBeProcessed: List of [Integer])
    var
        BusQueue: Record "Bus Queue";
        EntryNoToBeProcessed: Integer;
    begin
        foreach EntryNoToBeProcessed in ListEntryNoToBeProcessed do begin
            BusQueue.SetAutoCalcFields(Body);
            BusQueue.Get(EntryNoToBeProcessed);
            
            HandleBusQueue(BusQueue);            
        end;
    end;

    local procedure HandleBusQueue(BusQueue: Record "Bus Queue")
    var
        BusQueueResponse: Record "Bus Queue Response";
        BusQueueHandler: Codeunit "Bus Queue Handler";
        BusQueueResponseHandler: Codeunit "Bus Queue Response Handler";
    begin
        while BusQueue.Status in [BusQueue.Status::Processing, BusQueue.Status::Retry] do begin
            BusQueueResponse := BusQueueHandler.Handle(BusQueue);

            if BusQueue.Status = BusQueue.Status::Retry then
                Sleep(BusQueue."Seconds Between Retries" * 1000);
        end;

        if true in [BusQueue."Raise Response Event", BusQueueResponseHandler.IsOnAfterInsertBusQueueResponseSubscribed()] then
            if BusQueue."Use Task Scheduler" then
                TaskScheduler.CreateTask(Codeunit::"Bus Queue Response Handler", 0, true, CompanyName(), CurrentDateTime(), BusQueueResponse.RecordId())
            else
                BusQueueResponseHandler.Run(BusQueueResponse);
    end;
}