namespace Microsoft.API.V1;

using System.Environment;
using System.IO;

page 20000 "APIV1 - Aut. Config. Packages"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'configurationPackage', Locked = true;
    DelayedInsert = true;
    EntityName = 'configurationPackage';
    EntitySetName = 'configurationPackages';
    PageType = API;
    SourceTable = "Config. Package";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(packageName; Rec."Package Name")
                {
                    Caption = 'packageName', Locked = true;
                    ToolTip = 'Specifies the name of the package.';
                }
                field(languageId; Rec."Language ID")
                {
                    Caption = 'languageId', Locked = true;
                }
                field(productVersion; Rec."Product Version")
                {
                    Caption = 'productVersion', Locked = true;
                }
                field(processingOrder; Rec."Processing Order")
                {
                    Caption = 'processingOrder', Locked = true;
                }
                field(excludeConfigurationTables; Rec."Exclude Config. Tables")
                {
                    Caption = 'excludeConfigurationTables', Locked = true;
                }
                field(numberOfTables; Rec."No. of Tables")
                {
                    Caption = 'numberOfTables', Locked = true;
                    Editable = false;
                }
                field(numberOfRecords; Rec."No. of Records")
                {
                    Caption = 'numberOfRecords', Locked = true;
                    Editable = false;
                }
                field(numberOfErrors; Rec."No. of Errors")
                {
                    Caption = 'numberOfErrors', Locked = true;
                    Editable = false;
                }
                field(importStatus; Rec."Import Status")
                {
                    Caption = 'importStatus', Locked = true;
                    Editable = false;
                }
                field(importError; Rec."Import Error")
                {
                    Caption = 'importError', Locked = true;
                    Editable = false;
                }
                field(applyStatus; Rec."Apply Status")
                {
                    Caption = 'applyStatus', Locked = true;
                    Editable = false;
                }
                field(applyError; Rec."Apply Error")
                {
                    Caption = 'applyError', Locked = true;
                    Editable = false;
                }
                part(file; "APIV1 - Aut. Conf. Pack. File")
                {
                    Caption = 'file', Locked = true;
                    EntityName = 'file';
                    EntitySetName = 'file';
                    SubPageLink = Code = field(Code);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        TenantConfigPackageFile: Record "Tenant Config. Package File";
    begin
        Rec.Validate("Import Status", Rec."Import Status"::No);
        Rec.Validate("Apply Status", Rec."Apply Status"::No);

        TenantConfigPackageFile.Validate(Code, Rec.Code);
        TenantConfigPackageFile.insert(true);
    end;

    trigger OnOpenPage()
    begin
        BINDSUBSCRIPTION(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        ApplyOrImportInProgressImportErr: Label 'Cannot import a package while import or apply is in progress.';
        ApplyOrImportInProgressApplyErr: Label 'Cannot apply a package while import or apply is in progress.';
        ImportNotCompletedErr: Label 'Import Status is not completed. You must import the package before you apply it.';
        MissingRapisStartFileErr: Label 'Please upload a Rapid Start File, before running the import.';

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Import(var ActionContext: WebServiceActionContext)
    var
        TenantConfigPackageFile: Record "Tenant Config. Package File";
        ImportSessionID: Integer;
    begin
        if IsImportOrApplyPending() then
            error(ApplyOrImportInProgressImportErr);

        TenantConfigPackageFile.SETAUTOCALCfieldS(Content);
        if not TenantConfigPackageFile.Get(Rec.Code) then
            error(MissingRapisStartFileErr);
        if not TenantConfigPackageFile.Content.HasValue() then
            error(MissingRapisStartFileErr);

        Rec.Validate("Import Status", Rec."Import Status"::Scheduled);
        Rec.Modify(true);

        if TaskScheduler.CanCreateTask() then
            TASKSCHEDULER.CREATETASK(
              Codeunit::"Automation - Import RSPackage", Codeunit::"Automation - Failure RSPackage", true, CompanyName(), CurrentDateTime() + 200,
              Rec.RecordId())
        else begin
            COMMIT();
            ImportSessionID := 0;
            STARTSESSION(ImportSessionID, CODEUNIT::"Automation - Import RSPackage", COMPANYNAME(), Rec);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Aut. Config. Packages");
        ActionContext.AddEntityKey(Rec.FieldNo(Code), Rec.Code);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Apply(var ActionContext: WebServiceActionContext)
    var
        ImportSessionID: Integer;
    begin
        if IsImportOrApplyPending() then
            error(ApplyOrImportInProgressApplyErr);

        if Rec."Import Status" <> Rec."Import Status"::Completed then
            error(ImportNotCompletedErr);

        Rec.Validate("Apply Status", Rec."Apply Status"::Scheduled);
        Rec.Modify(true);

        if TaskScheduler.CanCreateTask() then
            TASKSCHEDULER.CREATETASK(
              Codeunit::"Automation - Apply RSPackage", Codeunit::"Automation - Failure RSPackage", true, CompanyName(), CurrentDateTime() + 200,
              Rec.RecordId())
        else begin
            Commit();
            ImportSessionID := 0;
            StartSession(ImportSessionID, Codeunit::"Automation - Apply RSPackage", Companyname(), Rec);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Aut. Config. Packages");
        ActionContext.AddEntityKey(Rec.FieldNo(Code), Rec.Code);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    local procedure IsImportOrApplyPending(): Boolean
    begin
        exit(
          (Rec."Import Status" in [Rec."Import Status"::InProgress, Rec."Import Status"::Scheduled]) or
          (Rec."Apply Status" in [Rec."Apply Status"::InProgress, Rec."Apply Status"::Scheduled]));
    end;
}


