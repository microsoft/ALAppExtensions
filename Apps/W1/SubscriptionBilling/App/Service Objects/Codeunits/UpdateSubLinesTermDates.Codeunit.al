namespace Microsoft.SubscriptionBilling;

using System.Threading;

codeunit 8058 "Update Sub. Lines Term. Dates"
{
    Access = Internal;

    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        UpdateAllServiceCommitmentTerminationDates();
    end;

    local procedure UpdateAllServiceCommitmentTerminationDates()
    var
        ServiceObject: Record "Subscription Header";
    begin
        if ServiceObject.FindSet() then
            repeat
                ServiceObject.UpdateServicesDates();
                Commit(); // Commit to reduce backlog when updating all Subscriptions
            until ServiceObject.Next() = 0;
    end;

}