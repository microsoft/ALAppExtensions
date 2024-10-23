namespace Microsoft.SubscriptionBilling;

using System.IO;

codeunit 8030 "Generic Import Mappings"
{
    TableNo = "Data Exch.";
    SingleInstance = true;
    Access = Internal;

    trigger OnRun()
    var
        UsageDataImport: Record "Usage Data Import";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        ProcessDataExch: Codeunit "Process Data Exch.";
        RecRef: RecordRef;
    begin
        RecRef.Get(Rec."Related Record");
        RecRef.SetTable(UsageDataImport);
        UsageDataGenericImport.InitFromUsageDataImport(UsageDataImport);
        RecRef.GetTable(UsageDataGenericImport);

        ProcessDataExch.ProcessAllLinesColumnMapping(Rec, RecRef);
    end;

}
