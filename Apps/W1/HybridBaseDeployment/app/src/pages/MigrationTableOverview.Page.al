namespace Microsoft.DataMigration;

using System.Reflection;

page 40034 "Migration Table Overview"
{
    PageType = Worksheet;
    SourceTable = "Hybrid Table Status";
    ModifyAllowed = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                ShowCaption = false;

                field(HybridCompanyNameFilter; CompanyFilterDisplayName)
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    TableRelation = "Hybrid Company".Name;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                        FilterText: Text;
                    begin
                        HybridReplicationStatistics.LookupCompanies(FilterText, CompanyFilterDisplayName);
                        Rec.SetFilter("Company Name", FilterText);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        FilterCompanies();
                    end;
                }
                field(TableNameFilter; TableNameFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                    begin
                        if HybridReplicationStatistics.LookupTableData(TableNameFilter) then
                            Rec.SetRange("Table Name", TableNameFilter);

                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        if TableNameFilter = '' then
                            Rec.SetRange("Table Name")
                        else
                            Rec.SetFilter("Table Name", TableNameFilter);
                        CurrPage.Update(false);
                    end;
                }
            }

            repeater(MainGroup)
            {
                field(Company; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                }
                field(TableName; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    StyleExpr = StatusExpr;
                }
                field(Details; Rec.Details)
                {
                    ApplicationArea = All;
                    Caption = 'Details';
                    StyleExpr = StatusExpr;
                }
                field("Total records - Source"; Rec."Total records - Source Table")
                {
                    ApplicationArea = All;
                    Caption = 'Total records - Source table';
                    BlankZero = true;
                    Editable = false;
                }
                field("Total records - Target table"; Rec."Total records - Target Table")
                {
                    ApplicationArea = All;
                    Caption = 'Total records - Target table';
                    BlankZero = true;
                    Editable = false;
                }
                field("Target difference to Source"; Rec."Target difference to Source")
                {
                    ApplicationArea = All;
                    Caption = 'Difference between target and source';
                    BlankZero = true;
                    Editable = false;
                }

                field("Number of replications"; Rec."Replication Count")
                {
                    ApplicationArea = All;
                    Caption = 'Number of replications';
                    BlankZero = true;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        HybridReplicationDetail: Record "Hybrid Replication Detail";
                    begin
                        HybridReplicationDetail.SetRange("Company Name", Rec."Company Name");
                        HybridReplicationDetail.SetRange("Table Name", Rec."Table Name");
                        Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        Clear(StatusExpr);
        if Rec.Status = Rec.Status::Failed then
            StatusExpr := 'Unfavorable';

        HybridReplicationDetail.SetRange("Company Name", Rec."Company Name");
        HybridReplicationDetail.SetRange("Table Name", Rec."Table Name");
        HybridReplicationDetail.SetFilter("Total Records", '>0');
        if HybridReplicationDetail.FindFirst() then
            Rec."Total records - Source Table" := HybridReplicationDetail."Total Records";

        if not HybridReplicationDetail.GetCountOfRecordsInTheTableSafe(HybridReplicationDetail, Rec."Total records - Target Table") then begin
            Rec."Target difference to Source" := 0;
            Rec."Total records - Target Table" := 0;
#pragma warning disable AA0139
            Rec.Details := CopyStr(CouldNotReadTargetTableCountLbl + Rec.Details, 1, MaxStrLen(Rec.Details)).TrimEnd(';');
#pragma warning restore AA0139
            StatusExpr := 'Ambiguous';
            exit;
        end;

        Rec."Target difference to Source" := Rec."Total records - Target Table" - Rec."Total records - Source Table";
    end;

    trigger OnOpenPage()
    var
        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
    begin
        AllObj.SetFilter("Object Type", '=%1|%2', AllObj."Object Type"::Table, AllObj."Object Type"::"TableExtension");
        CompanyFilterDisplayName := Rec.GetFilter("Company Name");
        if CompanyFilterDisplayName = '' then
            CompanyFilterDisplayName := HybridReplicationStatistics.GetAllCompaniesLbl();

        if Rec.FindFirst() then;
    end;

    local procedure FilterCompanies()
    var
        HybridCompany: Record "Hybrid Company";
    begin
        HybridCompany.SetRange(Name, CompanyFilterDisplayName);
        if HybridCompany.IsEmpty then
            Rec.SetFilter("Company Name", CompanyFilterDisplayName)
        else
            Rec.SetRange("Company Name", CompanyFilterDisplayName);
    end;

    var
        AllObj: Record AllObj;
        CouldNotReadTargetTableCountLbl: Label 'Could not get the target table count.';
        CompanyFilterDisplayName: Text;
        TableNameFilter: Text;
        StatusExpr: Text;
}