namespace Microsoft.DataMigration;

page 40067 "Migration Validation Results"
{
    ApplicationArea = All;
    Caption = 'Migration Validation Results';
    PageType = Worksheet;
    SourceTable = "Validation Suite Line";
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
                    trigger OnDrillDown()
                    var
                        MigrationValidationError: Record "Migration Validation Error";
                        MigrationValidationErrors: Page "Migration Validation Errors";
                    begin
                        MigrationValidationError.SetRange("Validation Suite Id", Rec."Validation Suite Id");
                        MigrationValidationError.SetRange("Test Code", Rec.Code);

                        MigrationValidationErrors.SetTableView(MigrationValidationError);
                        MigrationValidationErrors.Run();
                    end;
                }
                field(Entity; Rec.Entity)
                {
                    Editable = false;
                }
                field("Test Description"; Rec."Test Description")
                {
                    Editable = false;
                }
                field("Code"; Rec."Code")
                {
                    Editable = false;
                }
                field("Validation Suite Id"; Rec."Validation Suite Id")
                {
                    Editable = false;
                }
                field(Ignore; Rec.Ignore)
                {
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