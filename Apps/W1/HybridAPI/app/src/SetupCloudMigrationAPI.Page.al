page 40023 "Setup Cloud Migration API"
{
    PageType = API;
    SourceTable = "Intelligent Cloud Setup";
    APIGroup = 'cloudMigration';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Setup Cloud Migration';
    EntitySetCaption = 'Setup Cloud Migration';
    EntitySetName = 'setupCloudMigration';
    EntityName = 'setupCloudMigration';
    DelayedInsert = true;
    Extensible = false;
    ODataKeyFields = SystemId;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Id';
                }

                field(productId; Rec."Product ID")
                {
                    ApplicationArea = All;
                    Caption = 'Product Id';
                }

                field(sqlServerType; Rec."SQL Server Type")
                {
                    ApplicationArea = All;
                    Caption = 'SQL Configuration';
                }

                field(sqlConnectionString; SqlConnectionStringTxt)
                {
                    ApplicationArea = All;
                    Caption = 'SQL Connection String';
                }

                field(runtimeName; RuntimeNameTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Integration Runtime Name';
                }

                field(runtimeKey; RuntimeKeyTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Runtime Key';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec.Get() then
            Error(InsertingNewRecordNotPossibleErr);

        Rec.Insert(true);
        SetupReplication();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.Modify(true);
        SetupReplication();
        exit(false);
    end;

    local procedure SetupReplication()
    var
        TempHybridProductType: Record "Hybrid Product Type" temporary;
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if HybridCloudManagement.CheckNeedsApprovalToRunCloudMigration() then
            Error(DelegatedAdminSetupErr);

        HybridCloudManagement.OnGetHybridProductType(TempHybridProductType);
        if not TempHybridProductType.Get(Rec."Product ID") then
            Error(WrongProductIdErr);

        if not HybridCloudManagement.CanSkipIRSetup(Rec."Sql Server Type", RuntimeNameTxt) then
            HybridCloudManagement.HandleShowIRInstructionsStep(TempHybridProductType, RuntimeNameTxt, RuntimeKeyTxt)
        else
            HybridCloudManagement.HandleShowCompanySelectionStep(TempHybridProductType, SqlConnectionStringTxt, Rec.ConvertSqlServerTypeToText(), RuntimeNameTxt);
    end;

    local procedure FinishSetup()
    var
        TempHybridProductType: Record "Hybrid Product Type" temporary;
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        ShowSettingsStep: Boolean;
    begin
        // TODO: Need verification event on GP
        HybridCloudManagement.OnGetHybridProductType(TempHybridProductType);
        if not TempHybridProductType.Get(Rec."Product ID") then
            Error(WrongProductIdErr);

        HybridCloudManagement.OnBeforeShowProductSpecificSettingsPageStep(TempHybridProductType, ShowSettingsStep);
        HybridCloudManagement.FinishCloudMigrationSetup(Rec);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; PageId: Integer; RunId: Guid; KeyFieldNo: Integer)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(PageId);
        ActionContext.AddEntityKey(KeyFieldNo, RunId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InstalledIntegrationRuntime()
    var
        TempHybridProductType: Record "Hybrid Product Type" temporary;
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.OnGetHybridProductType(TempHybridProductType);
        if not TempHybridProductType.Get(Rec."Product ID") then
            Error(WrongProductIdErr);

        HybridCloudManagement.HandleShowCompanySelectionStep(TempHybridProductType, SqlConnectionStringTxt, Rec.ConvertSqlServerTypeToText(), RuntimeNameTxt);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure CompleteSetup(var ActionContext: WebServiceActionContext)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        FinishSetup();
        HybridReplicationSummary.SetCurrentKey("Start Time");
        HybridReplicationSummary.FindLast();
        SetActionResponse(ActionContext, Page::"Cloud Migration Status API", HybridReplicationSummary.SystemId, HybridReplicationSummary.FieldNo("Run ID"));
    end;

    var
        SqlConnectionStringTxt: Text;
        RuntimeKeyTxt: Text;
        RuntimeNameTxt: Text;
        InsertingNewRecordNotPossibleErr: Label 'It is not possible to insert more than one record. Modify an existing record instead.';
        DelegatedAdminSetupErr: Label 'You are signed in as a delegated administrator. You must get approval from a licensed user with SUPER permissions to run the cloud migration on their behalf.';
        WrongProductIdErr: Label 'The value provided in Product ID field is incorrect, there is no such product ID.';
}