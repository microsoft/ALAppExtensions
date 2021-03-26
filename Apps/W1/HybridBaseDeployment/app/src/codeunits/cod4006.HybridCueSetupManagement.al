codeunit 4006 "Hybrid Cue Setup Management"
{
    procedure GetReplicationSuccessRateCueValue() ReplicationSuccessRate: Decimal
    var
        totalNumberofTables: Integer;
        numberOfSuccessfulTables: Integer;
    begin
        totalNumberofTables := GetTotalNumberOfDistinctReplicatedTables();
        if totalNumberofTables = 0 then begin
            ReplicationSuccessRate := 0;
            exit;
        end;

        numberOfSuccessfulTables := GetTotalNumberOfSuccessfulReplicatedTables();

        ReplicationSuccessRate := numberOfSuccessfulTables / totalNumberofTables;
        ReplicationSuccessRate := Round(ReplicationSuccessRate, 0.01, '<');
    end;

    procedure InsertDataForReplicationSuccessRateCue()
    var
        ActivitiesCue: Record "Activities Cue";
        CuesAndKPIs: Codeunit "Cues And KPIs";
        CuesAndKPIsStyle: Enum "Cues And KPIs Style";
    begin
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Replication Success Rate"), CuesAndKPIsStyle::Unfavorable,
            0.5, CuesAndKPIsStyle::Ambiguous, 0.95, CuesAndKPIsStyle::Favorable);
    end;

    procedure GetReplicationSuccessRateCueStyle(ReplicationSuccessRate: Decimal) CueStyle: Enum "Cues And KPIs Style"
    var
        ActivitiesCue: Record "Activities Cue";
        CuesAndKPIs: Codeunit "Cues And KPIs";
    begin
        CuesAndKPIs.SetCueStyle(Database::"Activities Cue", ActivitiesCue.FieldNo("Replication Success Rate"), ReplicationSuccessRate, CueStyle);
    end;

    procedure GetTotalNumberOfDistinctReplicatedTables() TotalNumberofTables: Integer
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        TempHybridReplicationDetail: Record "Hybrid Replication Detail" temporary;
        HybridCompany: Record "Hybrid Company";
    begin
        // Total number of distinct tables for only companies that are enabled for replication
        HybridReplicationDetail.SetCurrentKey("Company Name", "Table Name");

        HybridReplicationSummary.SetFilter(ReplicationType, '%1|%2', HybridReplicationSummary.ReplicationType::Normal, HybridReplicationSummary.ReplicationType::Full);
        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::Completed);
        HybridCompany.SetRange(Replicate, true);
        if HybridReplicationSummary.FindSet() then
            repeat
                HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
                if HybridReplicationDetail.FindSet() then
                    repeat
                        TempHybridReplicationDetail."Company Name" := HybridReplicationDetail."Company Name";
                        TempHybridReplicationDetail."Table Name" := HybridReplicationDetail."Table Name";
                        HybridCompany.SetRange(Name, HybridReplicationDetail."Company Name");

                        if (HybridReplicationDetail."Company Name" = '') or not HybridCompany.IsEmpty() then
                            if not TempHybridReplicationDetail.Insert() then;
                    until HybridReplicationDetail.Next() = 0;
            until HybridReplicationSummary.Next() = 0;

        TotalNumberofTables := TempHybridReplicationDetail.Count();
    end;

    procedure GetTotalNumberOfSuccessfulReplicatedTables() NumberOfSuccessfulTables: Integer
    begin
        NumberOfSuccessfulTables := GetTotalNumberOfDistinctReplicatedTables() - GetTotalNumberOfFailedReplicatedTables();
    end;

    procedure GetTotalNumberOfFailedReplicatedTables() NumberOfFailedTables: Integer
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCompany: Record "Hybrid Company";
    begin
        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::Completed);
        HybridReplicationSummary.SetFilter(ReplicationType, '%1|%2', HybridReplicationSummary.ReplicationType::Normal, HybridReplicationSummary.ReplicationType::Full);
        HybridReplicationSummary.SetCurrentKey("Start Time");
        HybridReplicationSummary.SetAscending("Start Time", false);
        if not HybridReplicationSummary.FindFirst() then
            exit;

        HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
        HybridReplicationDetail.SetFilter(Status, '%1|%2', HybridReplicationDetail.Status::Failed, HybridReplicationDetail.Status::Warning);
        HybridCompany.SetRange(Replicate, true);
        if HybridReplicationDetail.FindSet() then
            repeat
                HybridCompany.SetRange(Name, HybridReplicationDetail."Company Name");
                if (HybridReplicationDetail."Company Name" = '') or not HybridCompany.IsEmpty() then
                    NumberOfFailedTables += 1;
            until HybridReplicationDetail.Next() = 0;
    end;
}