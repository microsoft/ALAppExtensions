codeunit 11006 "Data Load DE"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeTxt: Label 'DE', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterW1DataLoadForVersion', '', false, false)]
    local procedure LoadDataForDE_15x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeTxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;

        // Move data from staged tables to real tables.
    end;
}