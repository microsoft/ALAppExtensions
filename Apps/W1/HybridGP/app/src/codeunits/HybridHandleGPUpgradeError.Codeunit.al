codeunit 40020 "Hybrid Handle GP Upgrade Error"
{
    TableNo = "Hybrid Replication Summary";

    trigger OnRun()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        FailureMessageOutStream: OutStream;
    begin
        HybridCompanyStatus.Get(CompanyName);
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Failed;
        HybridCompanyStatus."Upgrade Failure Message".CreateOutStream(FailureMessageOutStream);
        FailureMessageOutStream.Write(GetLastErrorText());
        HybridCompanyStatus.Modify();
        Commit();

        Rec.Find();
        Rec.Status := Rec.Status::UpgradeFailed;
        Rec.Modify();
    end;
}