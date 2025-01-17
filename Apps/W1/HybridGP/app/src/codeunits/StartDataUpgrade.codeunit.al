codeunit 40126 "Start Data Upgrade"
{
    TableNo = "Hybrid Replication Summary";

    trigger OnRun()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.RunDataUpgrade(Rec);
    end;
}