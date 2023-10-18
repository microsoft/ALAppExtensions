// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment;
using System.Upgrade;

codeunit 10678 "SAF-T Upgrade"
{
    Permissions = TableData "Media Resources" = r, TableData "Tenant Media" = rimd;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeSAFTFileFromHeaderToSAFTExportFileTable();
        UpgradeSAFTMediaResourcesToTenantMedia();
        UpgradeExportCurrenfyInformationInSAFTExportHeader();
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

    local procedure UpgradeSAFTMediaResourcesToTenantMedia()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        MediaResources: Record "Media Resources";
        TenantMedia: Record "Tenant Media";
        UpgradeTag: Codeunit "Upgrade Tag";
        BLOBInStream: InStream;
        BLOBOutStream: OutStream;
    begin
        if UpgradeTag.HasUpgradeTag(GetSAFMediaResourcesToTenantMediaUpgradeTag()) then
            exit;

        if SAFTMappingSource.FindSet() then
            repeat
                if MediaResources.Get(SAFTMappingSource."Source No.") then begin
                    MediaResources.CalcFields(Blob);
                    If MediaResources.Blob.HasValue() then begin
                        MediaResources.Blob.CreateInStream(BLOBInStream);
                        TenantMedia.ID := CreateGuid();
                        TenantMedia."File Name" := SAFTMappingSource."Source No.";
                        TenantMedia.Description := TenantMedia."File Name";
                        TenantMedia."Company Name" := CompanyName();
                        TenantMedia.Height := 1;
                        TenantMedia.Width := 1;
                        TenantMedia.Content.CreateOutStream(BLOBOutStream);
                        CopyStream(BLOBOutStream, BLOBInStream);
                        TenantMedia.Insert(true);
                    end;
                end;
            until SAFTMappingSource.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetSAFMediaResourcesToTenantMediaUpgradeTag());
    end;

    local procedure UpgradeExportCurrenfyInformationInSAFTExportHeader()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetUpgradeExportCurrenfyInformationInSAFTExportHeader()) then
            exit;

        SAFTExportHeader.ModifyAll("Export Currency Information", true);

        UpgradeTag.SetUpgradeTag(GetUpgradeExportCurrenfyInformationInSAFTExportHeader());
    end;

    local procedure GetSAFTFileFromHeaderToSAFTExportFileTableUpgradeTag(): Code[250];
    begin
        exit('MS-361285-SAFTFileFromHeaderToSAFTExportFileTable-20200616');
    end;

    local procedure GetSAFMediaResourcesToTenantMediaUpgradeTag(): Code[250];
    begin
        exit('MS-382903-SAFMediaResourcesToTenantMedia-20201211');
    end;

    local procedure GetUpgradeExportCurrenfyInformationInSAFTExportHeader(): Code[250];
    begin
        exit('MS-399930-UpgradeExportCurrenfyInformationInSAFTExportHeader-20210519');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetSAFTFileFromHeaderToSAFTExportFileTableUpgradeTag());
        PerCompanyUpgradeTags.Add(GetSAFMediaResourcesToTenantMediaUpgradeTag());
        PerCompanyUpgradeTags.Add(GetUpgradeExportCurrenfyInformationInSAFTExportHeader());
    end;

}
