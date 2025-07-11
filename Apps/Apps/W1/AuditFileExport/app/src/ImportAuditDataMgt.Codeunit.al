// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.IO;
using System.Reflection;

codeunit 5262 "Import Audit Data Mgt."
{
    TableNo = "G/L Account Mapping Header";

    var
        NotPossibleToParseMappingXMLFileErr: label 'Not possible to parse XML file with %1 for mapping', Comment = '%1 = a standard account type';
        StandardAccountsTxt: label 'Standard Accounts';
        GroupingCodesTxt: label 'Grouping Codes';

    /// <summary> Fills Standard Account table from temporary XML Buffer table.</summary>
    /// <param name="TempCSVBuffer">Temporary table XML Buffer.</param>
    /// <param name="StandardAccountType">Standard account type for which standard account records are created.</param>
    /// <remarks>
    /// XML Buffer must contain 2 child nodes for each buffer record. The 1st node holds Standard Account No.; 2nd - Standard Account Description".
    /// </remarks>
    procedure ImportStandardAccountsFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary; StandardAccountType: enum "Standard Account Type")
    var
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        StandardAccount: Record "Standard Account";
        StandardAccNo: Code[20];
    begin
        if not TempXMLBuffer.HasChildNodes() then
            Error(NotPossibleToParseMappingXMLFileErr, StandardAccountsTxt);
        repeat
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            StandardAccNo := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(StandardAccount."No."));
            StandardAccount.Init();
            StandardAccount.Type := StandardAccountType;
            StandardAccount."No." := StandardAccNo;
            TempChildXMLBuffer.Next();
            StandardAccount.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(StandardAccount.Description));
            if StandardAccount.Insert() then;
        until TempXMLBuffer.Next() = 0;
    end;

    /// <summary> Fills Standard Account table from temporary XML Buffer table.</summary>
    /// <param name="TempCSVBuffer">Temporary table XML Buffer.</param>
    /// <param name="StandardAccountType">Standard account type for which standard account records are created.</param>
    /// <remarks>
    /// XML Buffer must contain 3 child nodes for each buffer record. 
    /// The 1st node holds Standard Account Category No.; 2nd - Standard Account No.; 3rd - Standard Account Description".
    /// </remarks>
    procedure ImportStandardAccountsWithGroupingCodesFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary; StandardAccountType: enum "Standard Account Type")
    var
        StandardAccountCategory: Record "Standard Account Category";
        StandardAccount: Record "Standard Account";
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        CategoryCode: Code[20];
    begin
        repeat
            if not TempXMLBuffer.HasChildNodes() then
                Error(NotPossibleToParseMappingXMLFileErr, GroupingCodesTxt);
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            CategoryCode := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(CategoryCode));
            if CategoryCode <> StandardAccountCategory."No." then begin
                StandardAccountCategory.Init();
                StandardAccountCategory."Standard Account Type" := StandardAccountType;
                StandardAccountCategory."No." := CategoryCode;
                TempChildXMLBuffer.Next();
                StandardAccountCategory.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(StandardAccountCategory.Description));
                if not StandardAccountCategory.Insert() then
                    StandardAccountCategory.Modify();
            end else
                TempChildXMLBuffer.Next();

            StandardAccount.Init();
            StandardAccount.Type := StandardAccountType;
            StandardAccount."Category No." := StandardAccountCategory."No.";
            TempChildXMLBuffer.Next();
            if TempChildXMLBuffer.Name = 'CategoryDescription' then
                TempChildXMLBuffer.Next();
            StandardAccount."No." := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(StandardAccount."No."));
            TempChildXMLBuffer.Next();
            StandardAccount.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(StandardAccount.Description));
            if not StandardAccount.Insert() then
                StandardAccount.Modify();
        until TempXMLBuffer.Next() = 0;
    end;

    /// <summary> Fills Standard Account table from temporary CSV Buffer table. </summary>
    /// <param name="TempCSVBuffer">Temporary table CSV Buffer.</param>
    /// <param name="StandardAccountType">Standard account type for which standard account records are created.</param>
    /// <remarks>
    /// CSV Buffer must contain at least 2 fields for each line. The 1st field holds Standard Account No.; 2nd - Standard Account Description; 3rd - Standard Account Category (optional)".
    /// </remarks>
    procedure ImportStandardAccountsFromCSVBuffer(var TempCSVBuffer: Record "CSV Buffer" temporary; StandardAccountType: enum "Standard Account Type")
    var
        StandardAccount: Record "Standard Account";
        StandardAccCategoryNo: Code[20];
        StandardAccNo: Code[20];
        StandardAccDescription: Text[250];
        LinesCount: Integer;
        LineNo: Integer;
        CategoryNoFieldNo: Integer;
        AccountNoFieldNo: Integer;
        DescriptionFieldNo: Integer;
    begin
        if TempCSVBuffer.IsEmpty() then
            exit;

        AccountNoFieldNo := 1;
        DescriptionFieldNo := 2;
        CategoryNoFieldNo := 3;
        LinesCount := TempCSVBuffer.GetNumberOfLines();

        for LineNo := 1 to LinesCount do begin
            StandardAccNo := CopyStr(TempCSVBuffer.GetValue(LineNo, AccountNoFieldNo), 1, MaxStrLen(StandardAccount."No."));
            StandardAccDescription := CopyStr(TempCSVBuffer.GetValue(LineNo, DescriptionFieldNo), 1, MaxStrLen(StandardAccount.Description));

            StandardAccCategoryNo := '';
            if TempCSVBuffer.Get(LineNo, CategoryNoFieldNo) then
                StandardAccCategoryNo := CopyStr(TempCSVBuffer.GetValue(LineNo, CategoryNoFieldNo), 1, MaxStrLen(StandardAccount."Category No."));

            StandardAccount.Init();
            StandardAccount.Type := StandardAccountType;
            StandardAccount."Category No." := StandardAccCategoryNo;
            StandardAccount."No." := StandardAccNo;
            StandardAccount.Description := StandardAccDescription;
            if StandardAccount.Insert() then;
        end;
    end;

    /// <summary>Parses CSV document content and saves it into the temporary CSV Buffer table. </summary>
    /// <param name="TempCSVBuffer">Temporary table CSV Buffer.</param>
    /// <param name="CSVDocContent">CSV text in a format "Standard Account No.; Standard Account Description; Standard Account Category" or "Standard Account No.; Standard Account Description"</param>
    /// <param name="CSVFieldSeparator">Separator which is used to divide values within a CSV line.</param>
    procedure LoadStandardAccountsFromCSVTextToCSVBuffer(var TempCSVBuffer: Record "CSV Buffer" temporary; CSVDocContent: Text; CSVFieldSeparator: Text[1])
    var
        TypeHelper: Codeunit "Type Helper";
        CSVLines: List of [Text];
        CSVLine: Text;
        CSVValues: List of [Text];
        CSVFieldValue: Text;
        CRLF: Text[2];
        LineNo: Integer;
        FieldNo: Integer;
    begin
        CRLF := TypeHelper.CRLFSeparator();
        CSVLines := CSVDocContent.Split(CRLF);

        for LineNo := 1 to CSVLines.Count do begin
            Clear(CSVValues);
            CSVLine := CSVLines.Get(LineNo);
            CSVValues := CSVLine.Split(CSVFieldSeparator);
            for FieldNo := 1 to CSVValues.Count do begin
                CSVFieldValue := DelChr(CSVValues.Get(FieldNo), '<>');
                TempCSVBuffer.InsertEntry(LineNo, FieldNo, CopyStr(CSVFieldValue, 1, MaxStrLen(TempCSVBuffer.Value)));
            end;
        end;
    end;
}
