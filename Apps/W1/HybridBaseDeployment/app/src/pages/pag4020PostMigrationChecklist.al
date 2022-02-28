page 4020 "Post Migration Checklist"
{
    Caption = 'Post Migration Checklist';
    SourceTable = "Post Migration Checklist";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(PostMigInfo)
            {
                ShowCaption = false;
                InstructionalText = 'Once the migration process has been completed, there is additional data that will need to be setup. Complete the recommended steps below for areas that may need to be re-setup.';
            }
            group(ChecklistSteps)
            {
                ShowCaption = false;
                grid(StepsGrid)
                {
                    GridLayout = Columns;
                    group(RecommendedSteps)
                    {
                        Caption = 'Recommended Steps:';
                        field(ReadWhitePaperTxt; ReadHelpPaperTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                Hyperlink(ReadWhitePaperURLTxt);
                            end;
                        }
                        field(DisableCloudTxt; DisableMigrationTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                Page.Run(Page::"Intelligent Cloud Ready");
                            end;
                        }
                        field(UsersSetupTxt; UsersPermissionsSetupTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Page.Run(Page::"Users");
                            end;
                        }
                        field(DefineUserMappingsTxt; DefineMappingsTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Page.Run(Page::"Migration User Mapping");
                            end;
                        }
                        field(ResetupSalesConnectionTxt; ResetSalesConnectionTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            ToolTip = 'Use actions ''Rebuild Coupling Table'' and ''Use Certificate Authentication'' to complete the setup of the connection to Dynamics 365 Sales.';

                            trigger OnDrillDown()
                            begin
                                if Confirm(ResetSalesConnectionInstructionsTxt) then
                                    Page.Run(Page::"CRM Connection Setup");
                            end;
                        }
                    }
                }

                group(Checkbox)
                {
                    Caption = 'Mark Complete';
                    field(Help; Help)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        trigger OnValidate();
                        var
                            PostMigChecklist: Record "Post Migration Checklist";
                        begin
                            PostMigChecklist.ModifyAll(Help, Help);
                            CurrPage.Update(false);
                        end;
                    }
                    field("Disable Intelligent Cloud"; "Disable Intelligent Cloud")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        trigger OnValidate();
                        var
                            PostMigChecklist: Record "Post Migration Checklist";
                        begin
                            PostMigChecklist.ModifyAll("Disable Intelligent Cloud", "Disable Intelligent Cloud");
                            CurrPage.Update(false);
                        end;
                    }
                    field("Users Setup"; "Users Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        trigger OnValidate();
                        var
                            PostMigChecklist: Record "Post Migration Checklist";
                        begin
                            PostMigChecklist.ModifyAll("Users Setup", "Users Setup");
                            CurrPage.Update(false);
                        end;
                    }
                    field("Define User Mappings"; "Define User Mappings")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        trigger OnValidate();
                        var
                            PostMigChecklist: Record "Post Migration Checklist";
                        begin
                            PostMigChecklist.ModifyAll("Define User Mappings", "Define User Mappings");
                            CurrPage.Update(false);
                        end;
                    }
                    field("D365 Sales"; "D365 Sales")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        trigger OnValidate();
                        var
                            PostMigChecklist: Record "Post Migration Checklist";
                        begin
                            PostMigChecklist.ModifyAll("D365 Sales", "D365 Sales");
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
        }

    }
    actions
    {

    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if IntelligentCloudSetup.Get() then
            HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
        PopulateCompany();
        RemoveCompanies();
        MarkAll();
        Rec.SetRange("Company Name", COMPANYNAME());
    end;

    trigger OnClosePage()
    var
        PostMigrationNotification: Codeunit "Post Migration Notificaton";

    begin
        if PostMigrationNotification.IsCLNotificationEnabled() then
            PostMigrationNotification.ShowChecklistNotification();
    end;

    local procedure PopulateCompany()
    var
        HybridCompany: Record "Hybrid Company";
        PostMigrationChecklist: Record "Post Migration Checklist";
        ShowHelp: Boolean;
        Users: Boolean;
        Sales: Boolean;
        DisableIntelligentCloud: Boolean;
        DefineUserMappings: Boolean;

    begin
        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetFilter(Help, '=%1', true);
        if PostMigrationChecklist.FindSet() then
            ShowHelp := true;

        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetFilter("Users Setup", '=%1', true);
        if PostMigrationChecklist.FindSet() then
            Users := true;

        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetFilter("D365 Sales", '=%1', true);
        if PostMigrationChecklist.FindSet() then
            Sales := true;

        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetFilter("Disable Intelligent Cloud", '=%1', true);
        if PostMigrationChecklist.FindSet() then
            DisableIntelligentCloud := true;

        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetFilter("Define User Mappings", '=%1', true);
        if PostMigrationChecklist.FindSet() then
            DefineUserMappings := true;

        PostMigrationChecklist.Reset();
        if not PostMigrationChecklist.IsEmpty() then
            HybridCompany.SetRange(Replicate, true);
        repeat
            if not PostMigrationChecklist.Get(HybridCompany.Name) then begin
                PostMigrationChecklist.Init();
                PostMigrationChecklist."Company Name" := HybridCompany.Name;
                PostMigrationChecklist.Help := ShowHelp;
                PostMigrationChecklist."Users Setup" := Users;
                PostMigrationChecklist."Disable Intelligent Cloud" := DisableIntelligentCloud;
                PostMigrationChecklist."D365 Sales" := Sales;
                PostMigrationChecklist."Define User Mappings" := DefineUserMappings;
                PostMigrationChecklist.Insert();
            end;
        until HybridCompany.Next() = 0;
    end;

    local procedure RemoveCompanies()
    var
        HybridCompany: Record "Hybrid Company";
        PostMigrationChecklist: Record "Post Migration Checklist";
        PostMigrationChecklistWork: Record "Post Migration Checklist";

    begin
        PostMigrationChecklistWork.Reset();

        if PostMigrationChecklistWork.FindSet() then
            repeat
                if not HybridCompany.Get(PostMigrationChecklistWork."Company Name") then begin
                    PostMigrationChecklist.Get(PostMigrationChecklistWork."Company Name");
                    PostMigrationChecklist.Delete();
                end else
                    If HybridCompany.Replicate = false then begin
                        PostMigrationChecklist.Get(PostMigrationChecklistWork."Company Name");
                        PostMigrationChecklist.Delete();
                    end;
            until PostMigrationChecklistWork.Next() = 0;
    end;

    local procedure MarkAll()
    var
        PostMigrationChecklist: Record "Post Migration Checklist";
    begin
        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetRange(Help, true);
        if PostMigrationChecklist.FindSet() then begin
            PostMigrationChecklist.Reset();
            PostMigrationChecklist.ModifyAll(Help, true);
            Commit();
        end;
        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetRange("Users Setup", true);
        if PostMigrationChecklist.FindSet() then begin
            PostMigrationChecklist.Reset();
            PostMigrationChecklist.ModifyAll("Users Setup", true);
            Commit();
        end;
        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetRange("D365 Sales", true);
        if PostMigrationChecklist.FindSet() then begin
            PostMigrationChecklist.Reset();
            PostMigrationChecklist.ModifyAll("D365 Sales", true);
            Commit();
        end;
        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetRange("Disable Intelligent Cloud", true);
        if PostMigrationChecklist.FindSet() then begin
            PostMigrationChecklist.Reset();
            PostMigrationChecklist.ModifyAll("Disable Intelligent Cloud", true);
            Commit();
        end;
        PostMigrationChecklist.Reset();
        PostMigrationChecklist.SetRange("Define User Mappings", true);
        if PostMigrationChecklist.FindSet() then begin
            PostMigrationChecklist.Reset();
            PostMigrationChecklist.ModifyAll("Define User Mappings", true);
            Commit();
        end;
    end;

    var
        HybridDeployment: Codeunit "Hybrid Deployment";
        ReadHelpPaperTxt: Label '1. Read the Business Central Cloud Migration help.';
        ReadWhitePaperURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2009758', Locked = true;
        DisableMigrationTxt: Label '2. Disable the Cloud Migration.';
        UsersPermissionsSetupTxt: Label '3. Setup Users and permissions within Business Central.';
        DefineMappingsTxt: Label '4. Define User Mappings.';
        ResetSalesConnectionTxt: Label '5. Resetup Dynamics 365 Sales Connection.';
        ResetSalesConnectionInstructionsTxt: Label 'You must choose actions ''Rebuild Coupling Table'' and ''Use Certificate Authentication'' on the page ''Microsoft Dynamics 365 Connection Setup'' to complete the setup of the connection to Dynamics 365 Sales.\Choose Yes to open the setup page.';

}