namespace Microsoft.API.V2;

using System.Environment;
using System.IO;

page 30000 "APIV2 - Aut. Config. Packages"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Configuration Package';
    EntitySetCaption = 'Configuration Packages';
    DelayedInsert = true;
    EntityName = 'configurationPackage';
    EntitySetName = 'configurationPackages';
    PageType = API;
    SourceTable = "Config. Package";
    Extensible = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(packageName; Rec."Package Name")
                {
                    Caption = 'Package Name';
                }
                field(languageId; Rec."Language ID")
                {
                    Caption = 'Language Id';
                }
                field(productVersion; Rec."Product Version")
                {
                    Caption = 'Product Version';
                }
                field(processingOrder; Rec."Processing Order")
                {
                    Caption = 'Processing Order';
                }
                field(excludeConfigurationTables; Rec."Exclude Config. Tables")
                {
                    Caption = 'Exclude Configuration Tables';
                }
                field(numberOfTables; Rec."No. of Tables")
                {
                    Caption = 'No. Of Tables';
                    Editable = false;
                }
                field(numberOfRecords; Rec."No. of Records")
                {
                    Caption = 'No. Of Records';
                    Editable = false;
                }
                field(numberOfErrors; Rec."No. of Errors")
                {
                    Caption = 'No. Of Errors';
                    Editable = false;
                }
                field(importStatus; Rec."Import Status")
                {
                    Caption = 'Import Status';
                    Editable = false;
                }
                field(importError; Rec."Import Error")
                {
                    Caption = 'Import Error';
                    Editable = false;
                }
                field(applyStatus; Rec."Apply Status")
                {
                    Caption = 'Apply Status';
                    Editable = false;
                }
                field(applyError; Rec."Apply Error")
                {
                    Caption = 'Apply Error';
                    Editable = false;
                }
                part(packageFile; "APIV2 - Aut. Conf. Pack. File")
                {
                    Caption = 'File';
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
        TenantConfigPackageFile.Insert(true);
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
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
            Error(ApplyOrImportInProgressImportErr);

        TenantConfigPackageFile.SetAutoCalcFields(Content);
        if not TenantConfigPackageFile.Get(Rec.Code) then
            Error(MissingRapisStartFileErr);
        if not TenantConfigPackageFile.Content.HasValue() then
            Error(MissingRapisStartFileErr);

        Rec.Validate("Import Status", Rec."Import Status"::Scheduled);
        Rec.Modify(true);

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(
              Codeunit::"Automation - Import RSPackage", Codeunit::"Automation - Failure RSPackage", true, CompanyName(), CurrentDateTime() + 200,
              Rec.RecordId())
        else begin
            Commit();
            ImportSessionID := 0;
            StartSession(ImportSessionID, Codeunit::"Automation - Import RSPackage", CompanyName(), Rec);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Config. Packages");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Apply(var ActionContext: WebServiceActionContext)
    var
        ImportSessionID: Integer;
    begin
        if IsImportOrApplyPending() then
            Error(ApplyOrImportInProgressApplyErr);

        if Rec."Import Status" <> Rec."Import Status"::Completed then
            Error(ImportNotCompletedErr);

        Rec.Validate("Apply Status", Rec."Apply Status"::Scheduled);
        Rec.Modify(true);

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(
              Codeunit::"Automation - Apply RSPackage", Codeunit::"Automation - Failure RSPackage", true, CompanyName(), CurrentDateTime() + 200,
              Rec.RecordId())
        else begin
            Commit();
            ImportSessionID := 0;
            StartSession(ImportSessionID, Codeunit::"Automation - Apply RSPackage", CompanyName(), Rec);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Config. Packages");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    local procedure IsImportOrApplyPending(): Boolean
    begin
        exit(
          (Rec."Import Status" in [Rec."Import Status"::InProgress, Rec."Import Status"::Scheduled]) or
          (Rec."Apply Status" in [Rec."Apply Status"::InProgress, Rec."Apply Status"::Scheduled]));
    end;
}

