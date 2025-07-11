namespace Microsoft.DataMigration;

using System.Integration;
using System.Reflection;

codeunit 40029 "Hybrid Replication Statistics"
{
    Permissions = tabledata "Intelligent Cloud Status" = r;

    trigger OnRun()
    begin
    end;

    internal procedure ShowSuccessfulTables()
    var
        TempHybridTableStatus: Record "Hybrid Table Status" temporary;
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        TotalTablesCount: Integer;
    begin
        TotalTablesCount := HybridReplicationDetail.Count();
        GetTableStatus(TempHybridTableStatus, TotalTablesCount);

        Page.Run(Page::"Migration Table Overview", TempHybridTableStatus);
    end;

    internal procedure GetTableStatus(var TempHybridTableStatus: Record "Hybrid Table Status" temporary; TotalTablesCount: Integer)
    var
        FailedHybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridUniqueTableStatus: Query "Hybrid Unique Table Status";
    begin
        HybridUniqueTableStatus.SetFilter(HybridUniqueTableStatus.Status, '=%1', HybridUniqueTableStatus.Status::Successful);
        HybridUniqueTableStatus.Open();

        while HybridUniqueTableStatus.Read() do begin
            TempHybridTableStatus."Table Name" := HybridUniqueTableStatus.Table_Name;
            TempHybridTableStatus."Company Name" := HybridUniqueTableStatus.Company_Name;
            TempHybridTableStatus.Status := HybridUniqueTableStatus.Status;
            TempHybridTableStatus."Replication Count" := HybridUniqueTableStatus.ReplicationCount;
            if TempHybridTableStatus.Insert() then;
        end;

        GetTotalFailedTables(FailedHybridReplicationDetail);
        if FailedHybridReplicationDetail.FindSet() then
            repeat
                if TempHybridTableStatus.Get(FailedHybridReplicationDetail."Table Name", FailedHybridReplicationDetail."Company Name") then begin
                    TempHybridTableStatus.Validate(Status, TempHybridTableStatus.Status::Failed);
                    TempHybridTableStatus.Details := CopyStr(FailedHybridReplicationDetail."Error Message", 1, MaxStrLen(TempHybridTableStatus.Details));
                    TempHybridTableStatus.Modify();
                end;
            until FailedHybridReplicationDetail.Next() = 0;
    end;

    internal procedure GetTotalFailedTables(var HybridReplicationDetail: Record "Hybrid Replication Detail"): Boolean
    var
        LaterHybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        Clear(HybridReplicationDetail);
        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Failed);
        if not HybridReplicationDetail.FindSet() then
            exit(false);

        repeat
            LaterHybridReplicationDetail.SetRange("Company Name", HybridReplicationDetail."Company Name");
            LaterHybridReplicationDetail.SetRange("Table Name", HybridReplicationDetail."Table Name");
            LaterHybridReplicationDetail.SetFilter("End Time", '>%1', HybridReplicationDetail."End Time");
            LaterHybridReplicationDetail.SetCurrentKey("End Time");
            LaterHybridReplicationDetail.Ascending(true);
            if LaterHybridReplicationDetail.IsEmpty() then
                HybridReplicationDetail.Mark(true);
        until HybridReplicationDetail.Next() = 0;

        HybridReplicationDetail.MarkedOnly(true);
        exit(HybridReplicationDetail.FindFirst());
    end;

    internal procedure ShowFailedTables()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        GetTotalFailedTables(HybridReplicationDetail);
        Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
    end;

    internal procedure GetTotalSuccessfulTables(var TempHybridReplicationDetail: Record "Hybrid Replication Detail")
    var
        FailedHybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridUniqueTableStatus: Query "Hybrid Unique Table Status";
    begin
        HybridUniqueTableStatus.SetFilter(HybridUniqueTableStatus.Status, '=%1', HybridUniqueTableStatus.Status::Successful);
        HybridUniqueTableStatus.Open();
        while HybridUniqueTableStatus.Read() do begin
            TempHybridReplicationDetail."Table Name" := HybridUniqueTableStatus.Table_Name;
            TempHybridReplicationDetail."Company Name" := HybridUniqueTableStatus.Company_Name;
            TempHybridReplicationDetail.Status := HybridUniqueTableStatus.Status;
            if TempHybridReplicationDetail.Insert() then;
        end;

        GetTotalFailedTables(FailedHybridReplicationDetail);
        if FailedHybridReplicationDetail.FindSet() then
            repeat
                if TempHybridReplicationDetail.Get('', FailedHybridReplicationDetail."Table Name", FailedHybridReplicationDetail."Company Name") then
                    TempHybridReplicationDetail.Delete();
            until FailedHybridReplicationDetail.Next() = 0;
    end;

    internal procedure OpenLastRunTablesStatus(StatusFilter: Option)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        if not HybridCloudManagement.GetLastReplicationSummary(HybridReplicationSummary) then
            exit;

        OpenTablesStatus(StatusFilter, HybridReplicationSummary);
    end;

    internal procedure OpenTablesStatus(StatusFilter: Option; var HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");

        if StatusFilter <> -1 then
            HybridReplicationDetail.SetRange(Status, StatusFilter);

        if StatusFilter = HybridReplicationDetail.Status::Warning then
            HybridReplicationDetail.SetFilter("Error Code", '<>%1', MissingOnPremTableIDTxt);

        Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
    end;

    internal procedure OpenTablesRemaining()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        if not HybridCloudManagement.GetLastReplicationSummary(HybridReplicationSummary) then
            exit;

        HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
        HybridReplicationDetail.SetFilter(Status, '%1|%2', HybridReplicationDetail.Status::NotStarted, HybridReplicationDetail.Status::InProgress);
        Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
    end;

    internal procedure LookupCompanies(var FilterText: Text; var FilterDisplayName: Text)
    var
        HybridFilterCompanies: Page "Hybrid Filter Companies";
    begin
        HybridFilterCompanies.LookupMode(true);
        if HybridFilterCompanies.RunModal() in [Action::OK, Action::LookupOK] then
            HybridFilterCompanies.GetSelectedCompaniesAsFilters(FilterText, FilterDisplayName);
    end;

    internal procedure GetCompaniesOverviewText(): Text
    var
        HybridCompany: Record "Hybrid Company";
        OnPremCompaniesText: Text;
        TotalOnPremCompanies: Integer;
        ReplicatedCompanies: Integer;
        CompaniesUnderReplication: Integer;
    begin
        TotalOnPremCompanies := HybridCompany.Count();
        if TotalOnPremCompanies = 0 then
            exit('');

        HybridCompany.SetRange(Replicated, true);
        ReplicatedCompanies := HybridCompany.Count();
        HybridCompany.Reset();
        HybridCompany.SetRange(Replicate, true);
        CompaniesUnderReplication := HybridCompany.Count();
        OnPremCompaniesText := StrSubstNo(CompaniesReplicatedLbl, CompaniesUnderReplication, ReplicatedCompanies, TotalOnPremCompanies);
        exit(OnPremCompaniesText);
    end;

    internal procedure GetAllCompaniesLbl(): Text
    begin
        exit(AllCompaniesLbl);
    end;

    internal procedure GetPerDatabaseTablesLbl(): Text
    begin
        exit(PerDatabaseTablesLbl);
    end;

    internal procedure LookupTableData(var TableNameFilter: Text): Boolean
    var
        AllObj: Record AllObj;
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        MigrationTableMapping: Record "Migration Table Mapping";
        TableMetadata: Record "Table Metadata";
        AllObjects: Page "All Objects";
    begin
        AllObj.SetFilter("Object Type", '%1|%2', AllObj."Object Type"::Table, AllObj."Object Type"::"TableExtension");

        AllObjects.SetTableView(AllObj);
        AllObjects.LookupMode(true);
        if not (AllObjects.RunModal() in [Action::OK, Action::LookupOK]) then
            exit(false);

        AllObjects.GetRecord(AllObj);
        TableNameFilter := AllObj."Object Name";

        if AllObj."Object Type" = AllObj."Object Type"::Table then
            if TableMetadata.Get(AllObj."Object ID") then
                if TableMetadata.ReplicateData = false then begin
                    if GuiAllowed then
                        Message(TableIsExcludedFormReplicationMsg);
                    exit(false);
                end;

        IntelligentCloudStatus.SetRange("Table Id", AllObj."Object ID");
        if IntelligentCloudStatus.FindFirst() then begin
            MigrationTableMapping.ValidateSourceTableName(MigrationTableMapping, IntelligentCloudStatus."Table Name");
            TableNameFilter := MigrationTableMapping."Source Table Name";
        end else
            if AllObj."Object Type" = AllObj."Object Type"::"TableExtension" then begin
                MigrationTableMapping.SetRange("Table ID", -AllObj."Object ID");
                if MigrationTableMapping.FindFirst() then
                    TableNameFilter := MigrationTableMapping."Source Table Name";
            end;

        HybridReplicationDetail.SetRange("Table Name", TableNameFilter);
        HybridReplicationDetail.SetCurrentKey("End Time");
        if not HybridReplicationDetail.FindLast() then begin
            if GuiAllowed() then
                Message(NoDataWasReplicatedFortableLbl, AllObj."Object Name");
            exit(false);
        end;

        if HybridReplicationDetail."Error Code" = MissingOnPremTableIDTxt then begin
            if GuiAllowed() then
                Message(MissingOnPremTableLbl);
            exit(false);
        end;

        exit(true);
    end;

    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        MissingOnPremTableIDTxt: label '50004', Locked = true;
        AllCompaniesLbl: Label 'All';
        PerDatabaseTablesLbl: Label 'Per database tables';
        MissingOnPremTableLbl: Label 'Table does not exist in the OnPrem database';
        NoDataWasReplicatedFortableLbl: Label 'No data was replicated for table %1. Check if the data is present in the OnPrem database.', Comment = '%1 - Name of the table';
        TableIsExcludedFormReplicationMsg: Label 'Table is excluded from cloud migraiton. It has ReplicateData property set to false.';
        CompaniesReplicatedLbl: Label 'Under replication: %1, Replicated: %2, Total: %3', Comment = '%1 - Number of companies under replication, %2 - Number of replicated companies, %31 - Total number of companies.';
}