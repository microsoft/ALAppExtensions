page 5194 "Contoso Demo Tool"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Contoso Demo Data Module";
    Caption = 'Contoso Demo Tool';
    AdditionalSearchTerms = 'Demo Data';
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(general)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the demo data module name';
                }
                field("Data Level"; Rec."Data Level")
                {
                    ToolTip = 'Specifies the demo data module installation level';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(GenerateDemoData)
            {
                Caption = 'Generate';
                Image = Create;
                action(Generate)
                {
                    Caption = 'Generate';
                    ToolTip = 'Generate demo data for selected module';
                    Image = Create;

                    trigger OnAction()
                    var
                        DemoDataModule: Record "Contoso Demo Data Module";
                        DemoTool: Codeunit "Contoso Demo Tool";
                    begin
                        CurrPage.SetSelectionFilter(DemoDataModule);

                        DemoTool.CreateDemoData(DemoDataModule, Enum::"Contoso Demo Data Level"::All);

                        FeatureTelemetry.LogUptake('0000KZW', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Used);
                        FeatureTelemetry.LogUsage('0000L00', ContosoCoffeeDemoDatasetFeatureNameTok, 'Contoso demo Data generated for All');
                    end;
                }
                action(GenerateSetup)
                {
                    Caption = 'Generate Setup Data';
                    ToolTip = 'Generate setup data for selected modules';
                    Image = Create;

                    trigger OnAction()
                    var
                        DemoDataModule: Record "Contoso Demo Data Module";
                        DemoTool: Codeunit "Contoso Demo Tool";
                    begin
                        CurrPage.SetSelectionFilter(DemoDataModule);

                        DemoTool.CreateDemoData(DemoDataModule, Enum::"Contoso Demo Data Level"::"Setup Data");

                        FeatureTelemetry.LogUptake('0000KZX', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Used);
                        FeatureTelemetry.LogUsage('0000L01', ContosoCoffeeDemoDatasetFeatureNameTok, 'Contoso demo Data generated for Setup');
                    end;
                }
            }
            action(Configuration)
            {
                Caption = 'Configure';
                ToolTip = 'Open the configuration page for the selected module';
                Image = Setup;

                trigger OnAction()
                var
                    ContosoDemoDataModule: Record "Contoso Demo Data Module";
                    Module: Interface "Contoso Demo Data Module";
                begin
                    CurrPage.GetRecord(ContosoDemoDataModule);
                    Module := ContosoDemoDataModule.Module;
                    Module.RunConfigurationPage();
                end;
            }
        }
        area(Promoted)
        {
            group(GeneratePromoted)
            {
                Caption = 'Generate';
                ShowAs = SplitButton;
                actionref(Generate_Promoted; Generate) { }
                actionref(GenerateAll_Promoted; GenerateSetup) { }
            }

            actionref(Configuration_Promoted; Configuration) { }
        }
    }

    trigger OnOpenPage()
    var
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
    begin
        FeatureTelemetry.LogUptake('0000KZY', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);
        ContosoDemoTool.RefreshModules(Rec);
        FeatureTelemetry.LogUptake('0000KZZ', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
}