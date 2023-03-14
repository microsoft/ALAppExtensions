#if not CLEAN20
codeunit 11725 "Data Load ES"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeTxt: Label 'ES', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterW1DataLoadForVersion', '', false, false)]
    local procedure LoadDataForES_16x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeTxt then
            exit;

        if TargetVersion <> 16.0 then
            exit;

        LoadReportSelections(HybridReplicationSummary);
        MoveCertificateToIsolatedCertificate(HybridReplicationSummary);
    end;

    local procedure LoadReportSelections(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        ReportSelections: Record "Report Selections";
        StgReportSelections: Record "Stg Report Selections";
        W1DataLoad: Codeunit "W1 Data Load";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetUpdateReportSelectionsTag()) then
            exit;

        StgReportSelections.SetRange(Usage, 100);
        if StgReportSelections.FindSet(false, false) then
            repeat
                ReportSelections.SetRange(Usage, 58);
                ReportSelections.SetRange(Sequence, StgReportSelections.Sequence);
                if ReportSelections.FindFirst() then
                    ReportSelections.Rename(StgReportSelections.Usage, StgReportSelections.Sequence);
            until StgReportSelections.Next() = 0;

        StgReportSelections.Reset();
        StgReportSelections.SetRange(Usage, 101);
        if StgReportSelections.FindSet(false, false) then
            repeat
                ReportSelections.SetRange(Usage, 59);
                ReportSelections.SetRange(Sequence, StgReportSelections.Sequence);
                if ReportSelections.FindFirst() then
                    ReportSelections.Rename(StgReportSelections.Usage, StgReportSelections.Sequence);
            until StgReportSelections.Next() = 0;

        W1DataLoad.OnAfterCompanyTableLoad(StgReportSelections.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgReportSelections.Reset();
        StgReportSelections.DeleteAll();
        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetUpdateReportSelectionsTag());
    end;

    local procedure MoveCertificateToIsolatedCertificate(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        SIISetup: Record "SII Setup";
        StgSIISetup: Record "Stg SII Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
        TempBlob: Codeunit "Temp Blob";
        CertificateManagement: Codeunit "Certificate Management";
        W1DataLoad: Codeunit "W1 Data Load";
        MoveCertificate: Boolean;
    begin
        // This code is based on app upgrade logic for ES.
        // Matching file: .\App\Layers\ES\BaseApp\Upgrade\UPGSIICertificate.Codeunit.al
        // Based on commit: 2c1c901e
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetUpdateSIICertificateTag()) then
            exit;

        if StgSIISetup.FindFirst() and SIISetup.FindFirst() then begin
            StgSIISetup.Calcfields(Certificate);
            MoveCertificate := (StgSIISetup.Certificate.HasValue()) and (SIISetup."Certificate Code" = '');
        end;
        if MoveCertificate then begin
            TempBlob.FromRecord(StgSIISetup, StgSIISetup.FieldNo(Certificate));
            CertificateManagement.SetCertPassword(StgSIISetup.Password);

            // The call to InitIsolatedCertificateFromBlob may fail if a record doesn't exist
            if not IsolatedCertificate.Insert(true) then;
            CertificateManagement.InitIsolatedCertificateFromBlob(IsolatedCertificate, TempBlob);

            IsolatedCertificate.Modify(true);
            SIISetup."Certificate Code" := IsolatedCertificate.Code;
            SIISetup.Modify();
        end;

        W1DataLoad.OnAfterCompanyTableLoad(StgSIISetup.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgSIISetup.DeleteAll();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetUpdateSIICertificateTag());
    end;
}
#endif