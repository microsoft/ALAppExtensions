codeunit 10678 "SAF-T Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeSAFTFileFromHeaderToSAFTExportFileTable();
    end;

    local procedure UpgradeSAFTFileFromHeaderToSAFTExportFileTable()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportFile: Record "SAF-T Export File";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSAFTFileFromHeaderToSAFTExportFileTableUpgradeTag()) then
            exit;

        SAFTExportHeader.SetRange(Status, SAFTExportHeader.Status::Completed);
        If SAFTExportHeader.FindSet() then
            repeat
                SAFTExportHeader.CalcFields("SAF-T File");
                If SAFTExportHeader."SAF-T File".HasValue() then begin
                    SAFTExportFile.SetRange("Export ID", SAFTExportHeader.ID);
                    IF SAFTExportFile.FindLast() then;
                    SAFTExportFile.Init();
                    SAFTExportFile."Export ID" := SAFTExportHeader.Id;
                    SAFTExportFile."File No." += 1;
                    SAFTExportFile."SAF-T File" := SAFTExportHeader."SAF-T File";
                    SAFTExportFile.Insert();
                end;
            until SAFTExportHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetSAFTFileFromHeaderToSAFTExportFileTableUpgradeTag());
    end;

    local procedure GetSAFTFileFromHeaderToSAFTExportFileTableUpgradeTag(): Code[250];
    begin
        exit('MS-361285-SAFTFileFromHeaderToSAFTExportFileTable-20200616');
    end;

    [EventSubscriber(ObjectType::Codeunit, 9999, 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetSAFTFileFromHeaderToSAFTExportFileTableUpgradeTag());
    end;

}
