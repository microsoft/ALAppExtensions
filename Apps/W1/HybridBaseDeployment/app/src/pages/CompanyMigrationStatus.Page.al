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
                    ToolTip = 'Specifies the value of the Validated field.';
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
                ToolTip = 'Run validation on all migrated companies that havve yet to be validated.';
                Image = Process;

                trigger OnAction()
                var
                    IntelligentCloudSetup: Record "Intelligent Cloud Setup";
                    HybridCompanyStatus: Record "Hybrid Company Status";
                    MigrationValidationMgmt: Codeunit "Migration Validation Mgmt.";
                    SessionsStarted: Boolean;
                begin
                    if not IntelligentCloudSetup.Get() then
                        exit;

                    HybridCompanyStatus.SetFilter(Name, '<>%1', '');
                    HybridCompanyStatus.SetRange(Validated, false);
                    if not HybridCompanyStatus.FindSet() then begin
                        Message('No companies need to be validated.');
                        exit;
                    end;

                    repeat
                        MigrationValidationMgmt.StartValidationSession(IntelligentCloudSetup."Product ID", HybridCompanyStatus.Name, true, false);
                        SessionsStarted := true;
                    until HybridCompanyStatus.Next() = 0;

                    if SessionsStarted then
                        Message('Validation has started.');
                end;
            }
        }
    }
}