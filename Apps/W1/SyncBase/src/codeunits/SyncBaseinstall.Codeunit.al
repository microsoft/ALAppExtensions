#if not CLEAN24
namespace Microsoft.Integration.SyncBase;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;

codeunit 2399 "Sync Base install"
{
    Subtype = Install;
    ObsoleteState = Pending;
    ObsoleteReason = 'The extension is being obsoleted.';
    ObsoleteTag = '24.0';

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        SyncChange: Record "Sync Change";
        SyncMapping: Record "Sync Mapping";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Sync Change");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Sync Mapping");
        DataClassificationMgt.SetFieldToPersonal(Database::"Sync Change", SyncChange.FieldNo("NAV Data"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sync Change", SyncChange.FieldNo("Internal ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sync Mapping", SyncMapping.FieldNo("Internal ID"));
    end;
}
#endif