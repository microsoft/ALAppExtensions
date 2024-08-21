// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Upgrade;

codeunit 6168 "E-Document Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnUpgradePerCompany()
    begin
        UpgradeLogURLMaxLength();
    end;

    local procedure UpgradeLogURLMaxLength()
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        UpgradeTag: Codeunit "Upgrade Tag";
        EDocumentIntegrationLogDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(GetUpgradeLogURLMaxLengthUpgradeTag()) then
            exit;

        EDocumentIntegrationLogDataTransfer.SetTables(Database::"E-Document Integration Log", Database::"E-Document Integration Log");
        EDocumentIntegrationLogDataTransfer.AddFieldValue(EDocumentIntegrationLog.FieldNo(URL), EDocumentIntegrationLog.FieldNo("Request URL"));
        EDocumentIntegrationLogDataTransfer.UpdateAuditFields(false);
        EDocumentIntegrationLogDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(GetUpgradeLogURLMaxLengthUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetUpgradeLogURLMaxLengthUpgradeTag());
    end;

    internal procedure GetUpgradeLogURLMaxLengthUpgradeTag(): Code[250]
    begin
        exit('MS-540448-LogURLMaxLength-20240813');
    end;
}