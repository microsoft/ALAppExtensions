codeunit 51752 "Bus Queues Handler"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Job Queue Entry" = RM,
                  tabledata "Scheduled Task" = R;
    
    trigger OnRun()
    begin
        if not HandleGroupedBusQueues() and not GuiAllowed then begin
            Rec.SetStatus(Rec.Status::"On Hold with Inactivity Timeout");
            Rec.Modify();
        end;
    end;

    local procedure HandleGroupedBusQueues(): Boolean
    var
        TempBusQueue: Record "Bus Queue" temporary;
    begin
        GroupBusQueuesByCategory(TempBusQueue);
        TempBusQueue.Reset();
        if not TempBusQueue.FindSet() then
            exit(false);
            
        repeat
            if TempBusQueue."Use Task Scheduler" then
                TaskScheduler.CreateTask(Codeunit::"Bus Queues Category Handler", 0, true, CompanyName(), CurrentDateTime(), TempBusQueue.RecordId())
            else
                Codeunit.Run(Codeunit::"Bus Queues Category Handler", TempBusQueue);
        until TempBusQueue.Next() = 0;

        exit(true);
    end;

    local procedure GroupBusQueuesByCategory(var TempBusQueue: Record "Bus Queue" temporary)
    var
        BusQueue: Record "Bus Queue";
    begin
        BusQueue.SetRange(Status, BusQueue.Status::Pending);
        if not BusQueue.FindSet() then
            exit;

        repeat
            TempBusQueue.SetRange("Category Code", BusQueue."Category Code");
            if TempBusQueue.IsEmpty() then begin
                TempBusQueue := BusQueue;
                TempBusQueue.Insert();
            end;
        until BusQueue.Next() = 0;
    end;
}