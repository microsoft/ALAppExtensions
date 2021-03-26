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
                field("code"; Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(packageName; "Package Name")
                {
                    Caption = 'packageName', Locked = true;
                    ToolTip = 'Specifies the name of the package.';
                }
                field(languageId; "Language ID")
                {
                    Caption = 'languageId', Locked = true;
                }
                field(productVersion; "Product Version")
                {
                    Caption = 'productVersion', Locked = true;
                }
                field(processingOrder; "Processing Order")
                {
                    Caption = 'processingOrder', Locked = true;
                }
                field(excludeConfigurationTables; "Exclude Config. Tables")
                {
                    Caption = 'excludeConfigurationTables', Locked = true;
                }
                field(numberOfTables; "No. of Tables")
                {
                    Caption = 'numberOfTables', Locked = true;
                    Editable = false;
                }
                field(numberOfRecords; "No. of Records")
                {
                    Caption = 'numberOfRecords', Locked = true;
                    Editable = false;
                }
                field(numberOfErrors; "No. of Errors")
                {
                    Caption = 'numberOfErrors', Locked = true;
                    Editable = false;
                }
                field(importStatus; "Import Status")
                {
                    Caption = 'importStatus', Locked = true;
                    Editable = false;
                }
                field(importError; "Import Error")
                {
                    Caption = 'importError', Locked = true;
                    Editable = false;
                }
                field(applyStatus; "Apply Status")
                {
                    Caption = 'applyStatus', Locked = true;
                    Editable = false;
                }
                field(applyError; "Apply Error")
                {
                    Caption = 'applyError', Locked = true;
                    Editable = false;
                }
                part(file; "APIV1 - Aut. Conf. Pack. File")
                {
                    Caption = 'file', Locked = true;
                    EntityName = 'file';
                    EntitySetName = 'file';
                    SubPageLink = Code = FIELD(Code);
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
        VALIDATE("Import Status", "Import Status"::No);
        VALIDATE("Apply Status", "Apply Status"::No);

        TenantConfigPackageFile.VALIDATE(Code, Code);
        TenantConfigPackageFile.INSERT(TRUE);
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
        IF IsImportOrApplyPending() THEN
            ERROR(ApplyOrImportInProgressImportErr);

        TenantConfigPackageFile.SETAUTOCALCFIELDS(Content);
        IF NOT TenantConfigPackageFile.GET(Code) THEN
            ERROR(MissingRapisStartFileErr);
        IF NOT TenantConfigPackageFile.Content.HASVALUE() THEN
            ERROR(MissingRapisStartFileErr);

        VALIDATE("Import Status", "Import Status"::Scheduled);
        MODIFY(TRUE);

        IF TASKSCHEDULER.CANCREATETASK() THEN
            TASKSCHEDULER.CREATETASK(
              CODEUNIT::"Automation - Import RSPackage", CODEUNIT::"Automation - Failure RSPackage", TRUE, COMPANYNAME(), CURRENTDATETIME() + 200,
              RECORDID())
        ELSE BEGIN
            COMMIT();
            ImportSessionID := 0;
            STARTSESSION(ImportSessionID, CODEUNIT::"Automation - Import RSPackage", COMPANYNAME(), Rec);
        END;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Aut. Config. Packages");
        ActionContext.AddEntityKey(FieldNo(Code), Code);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Apply(var ActionContext: WebServiceActionContext)
    var
        ImportSessionID: Integer;
    begin
        IF IsImportOrApplyPending() THEN
            ERROR(ApplyOrImportInProgressApplyErr);

        IF "Import Status" <> "Import Status"::Completed THEN
            ERROR(ImportNotCompletedErr);

        VALIDATE("Apply Status", "Apply Status"::Scheduled);
        MODIFY(TRUE);

        IF TASKSCHEDULER.CANCREATETASK() THEN
            TASKSCHEDULER.CREATETASK(
              CODEUNIT::"Automation - Apply RSPackage", CODEUNIT::"Automation - Failure RSPackage", TRUE, COMPANYNAME(), CURRENTDATETIME() + 200,
              RECORDID())
        ELSE BEGIN
            COMMIT();
            ImportSessionID := 0;
            STARTSESSION(ImportSessionID, CODEUNIT::"Automation - Apply RSPackage", COMPANYNAME(), Rec);
        END;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Aut. Config. Packages");
        ActionContext.AddEntityKey(FieldNo(Code), Code);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    local procedure IsImportOrApplyPending(): Boolean
    begin
        EXIT(
          ("Import Status" IN ["Import Status"::InProgress, "Import Status"::Scheduled]) OR
          ("Apply Status" IN ["Apply Status"::InProgress, "Apply Status"::Scheduled]));
    end;
}

