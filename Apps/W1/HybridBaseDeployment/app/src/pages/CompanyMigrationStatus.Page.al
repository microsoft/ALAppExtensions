namespace Microsoft.DataMigration;

page 40066 "Company Migration Status"
{
    ApplicationArea = All;
    Caption = 'Company Migration Status';
    PageType = List;
    SourceTable = "Hybrid Company Status";
    UsageCategory = None;
    InsertAllowed = false;
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Upgrade Status"; Rec."Upgrade Status")
                {
                    ToolTip = 'Specifies the value of the Upgrade Status field.';
                }
                field(Validated; Rec.Validated)
                {
                    ToolTip = 'Indicates if the company has been validated.';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(RunAllValidation_Promoted; RunAllValidation)
            {
            }
        }

        area(Processing)
        {
            action(RunAllValidation)
            {
                ApplicationArea = All;
                Caption = 'Run All Validation';
                ToolTip = 'Run validation on all migrated companies that have yet to be validated.';
                Image = Process;

                trigger OnAction()
                var
                    IntelligentCloudSetup: Record "Intelligent Cloud Setup";
                    HybridCompanyStatus: Record "Hybrid Company Status";
                    MigrationValidation: Codeunit "Migration Validation";
                    ForceRun: Boolean;
                    InitialCompanyName: Text;
                begin
                    if not IntelligentCloudSetup.Get() then
                        exit;

                    InitialCompanyName := CompanyName();

                    ForceRun := Dialog.Confirm(ShouldForceValidateQst, false);

                    HybridCompanyStatus.SetFilter(Name, '<>%1', '');

                    if not ForceRun then
                        HybridCompanyStatus.SetRange(Validated, false);

                    if not HybridCompanyStatus.FindSet() then begin
                        Message(NoCompaniesToValidateMsg);
                        exit;
                    end;

                    repeat
                        ChangeCompany(HybridCompanyStatus.Name);
                        MigrationValidation.StartValidation(IntelligentCloudSetup."Product ID", ForceRun);
                    until HybridCompanyStatus.Next() = 0;

                    ChangeCompany(InitialCompanyName);
                    Message(ValidationFinishedMsg);
                end;
            }
        }
    }

    var
        ShouldForceValidateQst: Label 'Do you want to force validation on all companies, even if it was previously validated?';
        NoCompaniesToValidateMsg: Label 'No companies need to be validated.';
        ValidationFinishedMsg: Label 'Validation is finished.';
}