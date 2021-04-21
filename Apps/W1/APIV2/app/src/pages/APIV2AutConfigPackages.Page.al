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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Code)
                {
                    Caption = 'Code';
                }
                field(packageName; "Package Name")
                {
                    Caption = 'Package Name';
                }
                field(languageId; "Language ID")
                {
                    Caption = 'Language Id';
                }
                field(productVersion; "Product Version")
                {
                    Caption = 'Product Version';
                }
                field(processingOrder; "Processing Order")
                {
                    Caption = 'Processing Order';
                }
                field(excludeConfigurationTables; "Exclude Config. Tables")
                {
                    Caption = 'Exclude Configuration Tables';
                }
                field(numberOfTables; "No. of Tables")
                {
                    Caption = 'No. Of Tables';
                    Editable = false;
                }
                field(numberOfRecords; "No. of Records")
                {
                    Caption = 'No. Of Records';
                    Editable = false;
                }
                field(numberOfErrors; "No. of Errors")
                {
                    Caption = 'No. Of Errors';
                    Editable = false;
                }
                field(importStatus; "Import Status")
                {
                    Caption = 'Import Status';
                    Editable = false;
                }
                field(importError; "Import Error")
                {
                    Caption = 'Import Error';
                    Editable = false;
                }
                field(applyStatus; "Apply Status")
                {
                    Caption = 'Apply Status';
                    Editable = false;
                }
                field(applyError; "Apply Error")
                {
                    Caption = 'Apply Error';
                    Editable = false;
                }
                part(packageFile; "APIV2 - Aut. Conf. Pack. File")
                {
                    Caption = 'File';
                    EntityName = 'file';
                    EntitySetName = 'file';
                    SubPageLink = Code = Field(Code);
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
        Validate("Import Status", "Import Status"::No);
        Validate("Apply Status", "Apply Status"::No);

        TenantConfigPackageFile.Validate(Code, Code);
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
        if not TenantConfigPackageFile.Get(Code) then
            Error(MissingRapisStartFileErr);
        if not TenantConfigPackageFile.Content.HasValue() then
            Error(MissingRapisStartFileErr);

        Validate("Import Status", "Import Status"::Scheduled);
        Modify(true);

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(
              Codeunit::"Automation - Import RSPackage", Codeunit::"Automation - Failure RSPackage", true, CompanyName(), CurrentDateTime() + 200,
              RecordId())
        else begin
            Commit();
            ImportSessionID := 0;
            StartSession(ImportSessionID, Codeunit::"Automation - Import RSPackage", CompanyName(), Rec);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Config. Packages");
        ActionContext.AddEntityKey(FieldNo(SystemId), SystemId);
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

        if "Import Status" <> "Import Status"::Completed then
            Error(ImportNotCompletedErr);

        Validate("Apply Status", "Apply Status"::Scheduled);
        Modify(true);

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(
              Codeunit::"Automation - Apply RSPackage", Codeunit::"Automation - Failure RSPackage", true, CompanyName(), CurrentDateTime() + 200,
              RecordId())
        else begin
            Commit();
            ImportSessionID := 0;
            StartSession(ImportSessionID, Codeunit::"Automation - Apply RSPackage", CompanyName(), Rec);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Config. Packages");
        ActionContext.AddEntityKey(FieldNo(SystemId), SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    local procedure IsImportOrApplyPending(): Boolean
    begin
        exit(
          ("Import Status" in ["Import Status"::InProgress, "Import Status"::Scheduled]) or
          ("Apply Status" in ["Apply Status"::InProgress, "Apply Status"::Scheduled]));
    end;
}

