// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8700 "Table Information Cache Impl."
{
    Access = Internal;
    Permissions = tabledata "Table Information Cache" = rimd,
                  tabledata "Company Size Cache" = rimd;

    var
        ProgressDialogLbl: Label 'Progress: @1@@@@@@@@@@', Comment = 'The string should always end with @1@@@@@@@@@@.';
        CrossCompanyDataLbl: Label '(Cross-Company Data)', MaxLength = 30;

    procedure RefreshTableInformationCache()
    var
        TableInformation: Record "Table Information";
        TableInformationCache: Record "Table Information Cache";
        ProgressDialog: Dialog;
        Total: Integer;
        Counter: Integer;
    begin
        if not TableInformationCache.IsEmpty() then
            TableInformationCache.DeleteAll();

        Total := TableInformation.Count();
        if GuiAllowed() then
            ProgressDialog.Open(ProgressDialogLbl);
        if TableInformation.FindSet() then
            repeat
                TableInformationCache.TransferFields(TableInformation);
                if TableInformationCache."Company Name" = '' then
                    TableInformationCache."Company Name" := CrossCompanyDataLbl;
                TableInformationCache.Insert();
                Counter += 1;
                if GuiAllowed() then
                    ProgressDialog.Update(1, Round(Counter / Total) * 10000)
            until TableInformation.Next() = 0;

        if GuiAllowed() then
            ProgressDialog.Close();
        RefreshCompanySizeCache();
        CalcThirtyDayGrowth();
    end;

    procedure CalcCompaniesTotalSize(): Integer
    var
        CompanySizeCache: Record "Company Size Cache";
    begin
        CompanySizeCache.CalcSums("Size (KB)");
        Exit(CompanySizeCache."Size (KB)");
    end;

    local procedure RefreshCompanySizeCache()
    var
        Company: Record Company;
        TableInformationCache: Record "Table Information Cache";
        CompanySizeCache: Record "Company Size Cache";
    begin
        if not CompanySizeCache.IsEmpty() then
            CompanySizeCache.DeleteAll();

        InsertCompanySizeCache(TableInformationCache, CrossCompanyDataLbl); // common data
        if Company.FindSet() then
            repeat
                InsertCompanySizeCache(TableInformationCache, Company.Name);
            until Company.Next() = 0;
    end;

    local procedure InsertCompanySizeCache(var TableInformationCache: Record "Table Information Cache"; CompanyName: Text)
    var
        CompanySizeCache: Record "Company Size Cache";
    begin
        TableInformationCache.SetRange("Company Name", CompanyName);
#pragma warning disable AA0181
        TableInformationCache.FindSet();
#pragma warning restore
        TableInformationCache.CalcSums("Size (KB)", "Data Size (KB)", "Index Size (KB)");

        CompanySizeCache.Init();
        CompanySizeCache."Company Name" := TableInformationCache."Company Name";
        CompanySizeCache."Size (KB)" := TableInformationCache."Size (KB)";
        CompanySizeCache."Data Size (KB)" := TableInformationCache."Data Size (KB)";
        CompanySizeCache."Index Size (KB)" := TableInformationCache."Index Size (KB)";
        CompanySizeCache.Insert();
    end;

    local procedure CalcThirtyDayGrowth()
    var
        TableInformationCache: Record "Table Information Cache";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        SetBiggestTablesFilter(TableInformationCache);
        if TableInformationCache.FindSet() then
            repeat
                RecordRef.Open(TableInformationCache."Table No.");
                if not (TableInformationCache."Company Name" in ['', CrossCompanyDataLbl, CompanyName()]) then
                    RecordRef.ChangeCompany(TableInformationCache."Company Name");

                FieldRef := RecordRef.Field(RecordRef.SystemCreatedAtNo);
#pragma warning disable AA0217
                FieldRef.SetFilter(StrSubstNo('''''|<%1', CreateDateTime(CalcDate('<-30D>', Today), 0T)));
#pragma warning restore AA0217
                TableInformationCache."Last Period No. of Records" := RecordRef.Count();
                TableInformationCache."Last Period Data Size (KB)" := Round((RecordRef.Count() * TableInformationCache."Record Size" / 1024), 1);
                if TableInformationCache."Last Period Data Size (KB)" <> 0 then
                    TableInformationCache."Growth %" := Round(((TableInformationCache."Data Size (KB)" / TableInformationCache."Last Period Data Size (KB)") - 1), 0.01) * 100;
                TableInformationCache.Modify();
                RecordRef.Close();
            until TableInformationCache.Next() = 0;
    end;

    procedure SetBiggestTablesFilter(var TableInformationCache: Record "Table Information Cache")
    begin
        TableInformationCache.SetCurrentKey("Data Size (KB)");
        TableInformationCache.SetAscending("Data Size (KB)", false);
        TableInformationCache.FilterGroup := 2;
        // exclude tenant media tables
        TableInformationCache.SetFilter("Table No.", '<>%1&<>%2&<>%3', Database::"Tenant Media", Database::"Tenant Media Set", Database::"Tenant Media Thumbnails");
        // get top 25 biggest tables
        if TableInformationCache.FindSet() then begin
            TableInformationCache.Next(24);
            TableInformationCache.SetFilter("Data Size (KB)", '>=%1', TableInformationCache."Data Size (KB)");
            TableInformationCache.FindFirst();
        end;
        TableInformationCache.FilterGroup := 0;
    end;
}