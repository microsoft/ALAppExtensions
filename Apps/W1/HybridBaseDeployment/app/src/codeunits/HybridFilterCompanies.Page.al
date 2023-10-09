namespace Microsoft.DataMigration;

using Microsoft.Utilities;

page 40039 "Hybrid Filter Companies"
{
    PageType = StandardDialog;
    SourceTable = "Name/Value Buffer";
    Editable = false;
    SourceTableTemporary = true;
    Caption = 'Select companies to show data';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            repeater(CompanyGroup)
            {
                field(CompanyName; Rec.Name)
                {
                    Caption = 'Company Name';
                    ToolTip = 'Specifies company name';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        CalculateFilters();
        exit(true);
    end;

    trigger OnOpenPage()
    var
        HybridCompany: Record "Hybrid Company";
        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
    begin
        Rec.Value := '1';
        Rec.Name := CopyStr(HybridReplicationStatistics.GetAllCompaniesLbl(), 1, MaxStrLen(Rec.Name));
        Rec.Insert();

        Rec.ID := Rec.ID + 1;
        Rec.Name := CopyStr(HybridReplicationStatistics.GetPerDatabaseTablesLbl(), 1, MaxStrLen(Rec.Name));
        Rec.Value := IncStr(Rec.Value);
        Rec.Insert();

        if not HybridCompany.FindSet() then
            exit;

        repeat
            Rec.ID := Rec.ID + 1;
            Rec.Name := HybridCompany.Name;
            Rec.Value := IncStr(Rec.Value);
            Rec.Insert();
        until HybridCompany.Next() = 0;

        if Rec.FindFirst() then;
    end;

    internal procedure GetSelectedCompaniesAsFilters(var NewFilterText: Text; var NewFilterDisplayName: Text)
    begin
        NewFilterText := FilterText;
        NewFilterDisplayName := FilterDisplayName;
    end;


    internal procedure CalculateFilters()
    var
        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
    begin
        CurrPage.SetSelectionFilter(Rec);
        if not Rec.FindFirst() then begin
            FilterText := '*';
            FilterDisplayName := HybridReplicationStatistics.GetAllCompaniesLbl();
            exit;
        end;

        repeat
            if Rec.Name = HybridReplicationStatistics.GetAllCompaniesLbl() then begin
                FilterText := '*';
                FilterDisplayName := HybridReplicationStatistics.GetAllCompaniesLbl();
                exit;
            end;

            if Rec.Name = HybridReplicationStatistics.GetPerDatabaseTablesLbl() then begin
                FilterText := '''''';
                FilterDisplayName := HybridReplicationStatistics.GetPerDatabaseTablesLbl();
                exit;
            end;

            FilterText += '|' + '''' + Rec.Name + '''';
        until Rec.Next() = 0;

        FilterText := FilterText.TrimStart('|');
        FilterDisplayName := FilterText;
    end;

    var
        FilterText: Text;
        FilterDisplayName: Text;
}