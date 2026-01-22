namespace Microsoft.DataMigration;

page 40067 "Migration Validation Results"
{
    ApplicationArea = All;
    Caption = 'Migration Validation Results';
    PageType = Worksheet;
    SourceTable = "Migration Validation Test";
    UsageCategory = Lists;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Filters';

                field(CurrentCompany; CurrentCompanyFilter)
                {
                    Caption = 'Current company only';
                    Visible = false;
                    ToolTip = 'Filter on the current company only or show tests results from all validated companies.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }

                field(HidePassingTests; HidePassingTestsFilter)
                {
                    Caption = 'Hide passing tests';
                    ToolTip = 'Hide test records that do not have any issues found from any validated company.';

                    trigger OnValidate()
                    begin
                        ApplyFilterHidePassingTests();
                        CurrPage.Update(false);
                    end;
                }
            }

            repeater(General)
            {
                field(FailCount; Rec."Fail Count")
                {
                    Caption = 'Failed';
                    ToolTip = 'Specifies the number of failures within the filter criteria.';

                    trigger OnDrillDown()
                    var
                        MigrationValidationError: Record "Migration Validation Error";
                        MigrationValidationErrors: Page "Migration Validation Errors";
                    begin
                        MigrationValidationError.SetRange("Validator Code", Rec."Validator Code");
                        MigrationValidationError.SetRange("Test Code", Rec.Code);

                        MigrationValidationErrors.SetTableView(MigrationValidationError);
                        MigrationValidationErrors.Run();
                    end;
                }
                field(Entity; Rec.Entity)
                {
                    Caption = 'Entity';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Test Description field.';
                }
                field("Test Description"; Rec."Test Description")
                {
                    Caption = 'Test Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Test Description field.';
                }
                field("Code"; Rec."Code")
                {
                    Caption = 'Code';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field("Validator Code"; Rec."Validator Code")
                {
                    Caption = 'Validator';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Validator Code field.';
                }
                field(Ignore; Rec.Ignore)
                {
                    ToolTip = 'Specifies the value of the Ignore field.';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(CompanyMigrationStatus_Promoted; CompanyMigrationStatus)
            {
            }
        }

        area(Navigation)
        {
            action(CompanyMigrationStatus)
            {
                ApplicationArea = All;
                Caption = 'Company Migration Status';
                Image = Process;
                ToolTip = 'Open the Company Migration Status page.';

                trigger OnAction()
                var
                    HybridCompaniesList: Page "Hybrid Companies List";
                begin
                    HybridCompaniesList.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        HidePassingTestsFilter := true;

        ApplyFilterHidePassingTests();
        Rec.CalcFields("Fail Count");
        Rec.SetCurrentKey("Fail Count");
        Rec.Ascending(false);

        CurrPage.SetTableView(Rec);
    end;

    local procedure ApplyFilterHidePassingTests()
    begin
        if HidePassingTestsFilter then
            Rec.SetFilter("Fail Count", '>0')
        else
            Rec.SetRange("Fail Count");
    end;

    var
        CurrentCompanyFilter: Boolean;
        HidePassingTestsFilter: Boolean;
}