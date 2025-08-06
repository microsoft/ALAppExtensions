// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using System.Upgrade;
#if not CLEANSCHEMA30
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument;
#endif

#pragma warning disable AS0130
#pragma warning disable PTE0025
codeunit 6380 Upgrade
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var

    begin
#if not CLEAN26
        // Upgrade code per company
        UpdateServiceIntegration();
#endif
#if not CLEANSCHEMA30
        UpdateAvalaraDocId();
#endif
    end;

#if not CLEAN26
    local procedure UpdateServiceIntegration()
    var
        EDocumentService: Record "E-Document Service";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeServiceIntegrationTag()) then
            exit;

        // 6370 - Avlara Integration
        EDocumentService.SetRange("Service Integration", 6370);
        if EDocumentService.FindSet() then
            repeat
                EDocumentService."Service Integration V2" := Enum::"Service Integration"::Avalara;
                EDocumentService."Service Integration" := Enum::"E-Document Integration"::"No Integration";
                EDocumentService.Modify();
            until EDocumentService.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeServiceIntegrationTag());
    end;
#endif


#if not CLEANSCHEMA30
    local procedure UpdateAvalaraDocId()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        ConnectionSetup: Record "Connection Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        RecordRef: RecordRef;
        Codes, DocumentId : Text;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeAvalaraDocIdTag()) then
            exit;

        // Old integration path
        Clear(Codes);
        EDocumentService.SetRange("Service Integration V2", Enum::"Service Integration"::Avalara);
        if EDocumentService.FindSet() then begin
            repeat
                Codes += EDocumentService.Code;
                Codes += '|';
            until EDocumentService.Next() = 0;
            if Codes <> '' then
                Codes := Codes.TrimEnd('|'); // Remove the last '|' character
        end;

        // Only run upgrade from Document Id to Avalara Document Id if the field exists.
        // Since any upgrade comes from version where dependency on Pagero existed, this is safe.
        // 6363 = "Document Id"
        RecordRef.GetTable(EDocument);
        if RecordRef.FieldExist(6363) then begin

            EDocument.ReadIsolation := IsolationLevel::ReadUncommitted;
            EDocumentServiceStatus.SetLoadFields("E-Document Entry No", "E-Document Service Code");
            EDocumentServiceStatus.SetFilter("E-Document Service Code", Codes);
            if EDocumentServiceStatus.FindSet() then
                repeat
                    if EDocument.Get(EDocumentServiceStatus."E-Document Entry No") then begin
                        RecordRef := EDocument;
                        DocumentId := RecordRef.Field(6363).Value();
                        if DocumentId <> '' then begin
                            EDocument."Avalara Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Avalara Document Id"));
                            EDocument.Modify();
                        end;
                    end;
                until EDocumentServiceStatus.Next() = 0;

            if ConnectionSetup.FindSet() then
                repeat
                    case ConnectionSetup."Send Mode" of
                        ConnectionSetup."Send Mode"::Production:
                            ConnectionSetup."Avalara Send Mode" := Enum::"Avalara Send Mode"::Production;
                        ConnectionSetup."Send Mode"::Test:
                            ConnectionSetup."Avalara Send Mode" := Enum::"Avalara Send Mode"::Test;
                        ConnectionSetup."Send Mode"::Certification:
                            ConnectionSetup."Avalara Send Mode" := Enum::"Avalara Send Mode"::Certification;
                    end;
                    ConnectionSetup.Modify();
                until ConnectionSetup.Next() = 0;

        end;
        UpgradeTag.SetUpgradeTag(UpgradeAvalaraDocIdTag());
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(UpgradeServiceIntegrationTag());
        PerCompanyUpgradeTags.Add(UpgradeAvalaraDocIdTag());
    end;

    local procedure UpgradeServiceIntegrationTag(): Code[250]
    begin
        exit('MS-547765-UpdateServiceIntegrationAvalara-20241118');
    end;

    local procedure UpgradeAvalaraDocIdTag(): Code[250]
    begin
        exit('MS-547765-UpdateAvalaraDocId-20250627');
    end;


}