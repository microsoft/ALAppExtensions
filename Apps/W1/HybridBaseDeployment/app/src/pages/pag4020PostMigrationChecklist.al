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
        PostMigChecklist: Record "Post Migration Checklist";
        ShowHelp: Boolean;
        Users: Boolean;
        Sales: Boolean;
        DisableIntelligentCloud: Boolean;
        DefineUserMappings: Boolean;

    begin
        PostMigChecklist.Reset();
        PostMigChecklist.SetFilter(Help, '=%1', true);
        if PostMigChecklist.FindSet() then
            ShowHelp := true;

        PostMigChecklist.Reset();
        PostMigChecklist.SetFilter("Users Setup", '=%1', true);
        if PostMigChecklist.FindSet() then
            Users := true;

        PostMigChecklist.Reset();
        PostMigChecklist.SetFilter("D365 Sales", '=%1', true);
        if PostMigChecklist.FindSet() then
            Sales := true;

        PostMigChecklist.Reset();
        PostMigChecklist.SetFilter("Disable Intelligent Cloud", '=%1', true);
        if PostMigChecklist.FindSet() then
            DisableIntelligentCloud := true;

        PostMigChecklist.Reset();
        PostMigChecklist.SetFilter("Define User Mappings", '=%1', true);
        if PostMigChecklist.FindSet() then
            DefineUserMappings := true;

        PostMigChecklist.Reset();
        if not PostMigChecklist.IsEmpty() then
            HybridCompany.SetRange(Replicate, true);
        repeat
            if not PostMigChecklist.Get(HybridCompany.Name) then begin
                PostMigChecklist.Init();
                PostMigChecklist."Company Name" := HybridCompany.Name;
                PostMigChecklist.Help := ShowHelp;
                PostMigChecklist."Users Setup" := Users;
                PostMigChecklist."Disable Intelligent Cloud" := DisableIntelligentCloud;
                PostMigChecklist."D365 Sales" := Sales;
                PostMigChecklist."Define User Mappings" := DefineUserMappings;
                PostMigChecklist.Insert();
            end;
        until HybridCompany.Next() = 0;
    end;

    local procedure RemoveCompanies()
    var
        HybridCompany: Record "Hybrid Company";
        PostMigChecklist: Record "Post Migration Checklist";
        PostMigChecklistWork: Record "Post Migration Checklist";

    begin
        PostMigChecklistWork.Reset();

        if PostMigChecklistWork.FindSet() then
            repeat
                if not HybridCompany.Get(PostMigChecklistWork."Company Name") then begin
                    PostMigChecklist.Get(PostMigChecklistWork."Company Name");
                    PostMigChecklist.Delete();
                end else
                    If HybridCompany.Replicate = false then begin
                        PostMigChecklist.Get(PostMigChecklistWork."Company Name");
                        PostMigChecklist.Delete();
                    end;
            until PostMigChecklistWork.Next() = 0;
    end;

    local procedure MarkAll()
    var
        PostMigChecklist: Record "Post Migration Checklist";
    begin
        PostMigChecklist.Reset();
        PostMigChecklist.SetRange(Help, true);
        if PostMigChecklist.FindSet() then begin
            PostMigChecklist.Reset();
            PostMigChecklist.ModifyAll(Help, true);
            Commit();
        end;
        PostMigChecklist.Reset();
        PostMigChecklist.SetRange("Users Setup", true);
        if PostMigChecklist.FindSet() then begin
            PostMigChecklist.Reset();
            PostMigChecklist.ModifyAll("Users Setup", true);
            Commit();
        end;
        PostMigChecklist.Reset();
        PostMigChecklist.SetRange("D365 Sales", true);
        if PostMigChecklist.FindSet() then begin
            PostMigChecklist.Reset();
            PostMigChecklist.ModifyAll("D365 Sales", true);
            Commit();
        end;
        PostMigChecklist.Reset();
        PostMigChecklist.SetRange("Disable Intelligent Cloud", true);
        if PostMigChecklist.FindSet() then begin
            PostMigChecklist.Reset();
            PostMigChecklist.ModifyAll("Disable Intelligent Cloud", true);
            Commit();
        end;
        PostMigChecklist.Reset();
        PostMigChecklist.SetRange("Define User Mappings", true);
        if PostMigChecklist.FindSet() then begin
            PostMigChecklist.Reset();
            PostMigChecklist.ModifyAll("Define User Mappings", true);
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