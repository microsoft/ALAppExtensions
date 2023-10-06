namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;

codeunit 7236 "Master Data Mgt. Tbl. Uncouple"
{
    TableNo = "Integration Table Mapping";
    Permissions = tabledata "Master Data Mgt. Coupling" = rd;

    trigger OnRun()
    var
        Handled: Boolean;
    begin
        OnBeforeRun(Rec, Handled);
        if Handled then
            exit;

        PerformScheduledUncoupling(Rec);
    end;

    var
        IntegrationMasterDataSynch: Codeunit "Integration Master Data Synch.";

    local procedure PerformScheduledUncoupling(var IntegrationTableMapping: Record "Integration Table Mapping")
    var
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        JobId: Guid;
    begin
        JobId := IntegrationTableSynch.BeginIntegrationUncoupleJob(TableConnectionType::ExternalSQL, IntegrationTableMapping, IntegrationTableMapping."Table ID");
        if not IsNullGuid(JobId) then begin
            UncoupleRecords(IntegrationTableMapping, IntegrationTableSynch);
            IntegrationTableSynch.EndIntegrationSynchJob();
        end;
    end;

    local procedure UncoupleRecords(var IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch.")
    var
        TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary;
        LocalTableFilter: Text;
        IntegrationTableFilter: Text;
        HasCouplings: Boolean;
    begin
        IntegrationMasterDataSynch.CreateMasterDataMgtCouplingClone(IntegrationTableMapping."Table ID", TempMasterDataMgtCoupling);
        HasCouplings := not TempMasterDataMgtCoupling.IsEmpty();

        LocalTableFilter := IntegrationTableMapping.GetTableFilter();
        IntegrationTableFilter := IntegrationTableMapping.GetIntegrationTableFilter();

        if (LocalTableFilter = '') and (IntegrationTableFilter = '') then begin
            if HasCouplings then
                UncoupleAllCoupledRecords(IntegrationTableMapping, IntegrationTableSynch, TempMasterDataMgtCoupling);
            exit;
        end;

        if not HasCouplings then
            exit;

        if LocalTableFilter <> '' then
            UncoupleFilteredLocalRecords(IntegrationTableMapping, IntegrationTableSynch, TempMasterDataMgtCoupling)
        else
            UncoupleFilteredIntegrationRecords(IntegrationTableMapping, IntegrationTableSynch, TempMasterDataMgtCoupling);
    end;

    local procedure UncoupleFilteredLocalRecords(var IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch."; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary)
    var
        LocalRecordRef: RecordRef;
        IntegrationRecordRef: RecordRef;
    begin
        LocalRecordRef.Open(IntegrationTableMapping."Table ID");
        IntegrationTableMapping.SetRecordRefFilter(LocalRecordRef);
        if LocalRecordRef.FindSet() then
            repeat
                if TempMasterDataMgtCoupling.IsLocalSystemIdCoupled(LocalRecordRef.Field(LocalRecordRef.SystemIdNo()).Value()) then begin
                    Clear(IntegrationRecordRef);
                    IntegrationTableSynch.Uncouple(LocalRecordRef, IntegrationRecordRef);
                end;
            until LocalRecordRef.Next() = 0;
    end;

    local procedure UncoupleFilteredIntegrationRecords(var IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch."; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        LocalRecordRef: RecordRef;
        IntegrationRecordRef: RecordRef;
    begin
        MasterDataManagementSetup.Get();
        IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
        IntegrationRecordRef.ChangeCompany(MasterDataManagementSetup."Company Name");
        IntegrationTableMapping.SetIntRecordRefFilter(IntegrationRecordRef);
        if IntegrationRecordRef.FindSet() then
            repeat
                if TempMasterDataMgtCoupling.IsIntegrationRecordRefCoupled(IntegrationRecordRef) then begin
                    TempMasterDataMgtCoupling.Delete();
                    Clear(LocalRecordRef);
                    IntegrationTableSynch.Uncouple(LocalRecordRef, IntegrationRecordRef);
                end;
            until IntegrationRecordRef.Next() = 0;
    end;

    local procedure UncoupleAllCoupledRecords(var IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch."; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataManagement: Codeunit "Master Data Management";
        LocalRecordRef: RecordRef;
        IntegrationRecordRef: RecordRef;
        LocalRecordFound: Boolean;
        IntegrationRecordFound: Boolean;
        TableId: Integer;
    begin
        if TempMasterDataMgtCoupling.FindSet() then
            repeat
                TableId := TempMasterDataMgtCoupling."Table ID";
                if TableId <> 0 then begin
                    Clear(LocalRecordRef);
                    LocalRecordRef.Open(TableId);
                    LocalRecordFound := LocalRecordRef.GetBySystemId(TempMasterDataMgtCoupling."Local System ID");
                    if not LocalRecordFound then begin
                        Clear(IntegrationrecordRef);
                        IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
                        IntegrationRecordFound := MasterDataManagement.GetIntegrationRecordRef(IntegrationTableMapping, TempMasterDataMgtCoupling."Integration System ID", IntegrationRecordRef);
                    end;
                    if LocalRecordFound or IntegrationRecordFound then begin
                        IntegrationTableSynch.Uncouple(LocalRecordRef, IntegrationRecordRef);
                        if MasterDataMgtCoupling.Get(TempMasterDataMgtCoupling."Integration System ID", TempMasterDataMgtCoupling."Local System ID") then
                            MasterDataMgtCoupling.Delete();
                    end else begin
                        if MasterDataMgtCoupling.Get(TempMasterDataMgtCoupling."Integration System ID", TempMasterDataMgtCoupling."Local System ID") then
                            MasterDataMgtCoupling.Delete();

                        if MasterDataMgtCoupling.Get(TempMasterDataMgtCoupling."Local System ID", TempMasterDataMgtCoupling."Integration System ID") then
                            MasterDataMgtCoupling.Delete();
                    end;
                end;
            until TempMasterDataMgtCoupling.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRun(IntegrationTableMapping: Record "Integration Table Mapping"; var Handled: Boolean)
    begin
    end;
}
