// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Account;

tableextension 5314 "Audit File Export Header SIE" extends "Audit File Export Header"
{
    fields
    {
        modify("Starting Date")
        {
            trigger OnAfterValidate()
            begin
                if "Fiscal Year" = '' then
                    "Fiscal Year" := Format(Date2DMY("Starting Date", 3));
            end;
        }
        modify("Audit File Export Format")
        {
#if CLEAN22
            trigger OnBeforeValidate()
            var
                SIEManagement: Codeunit "SIE Management";
            begin
                if Rec."Audit File Export Format" = Enum::"Audit File Export Format"::SIE then
                    if not SIEManagement.SIEFormatSetupExists() then
                        Error(AuditExportFormatSetupNotExistMsg);
            end;
#else
            trigger OnBeforeValidate()
            var
                SIEManagement: Codeunit "SIE Management";
            begin
                if Rec."Audit File Export Format" = Enum::"Audit File Export Format"::SIE then begin
                    if not SIEManagement.IsFeatureEnabled() then
                        Error(FeatureNotEnabledMsg);
                    if not SIEManagement.SIEFormatSetupExists() then
                        Error(AuditExportFormatSetupNotExistMsg);
                end;
            end;
#endif

            trigger OnAfterValidate()
            begin
                if Rec."Audit File Export Format" = Enum::"Audit File Export Format"::SIE then begin
                    Rec.Validate("Split By Month", false);
                    Rec.Validate("Split By Date", false);
                    Rec.Validate("Create Multiple Zip Files", false);
                end;
            end;
        }

        field(5314; "File Type"; enum "File Type SIE")
        {
            DataClassification = CustomerContent;
            Caption = 'File Type';
        }
        field(5315; "Fiscal Year"; Text[4])
        {
            DataClassification = CustomerContent;
            Caption = 'Fiscal Year';
            Numeric = true;
        }
        field(5316; Dimensions; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Dimensions';
            Editable = false;
        }
        field(5317; "G/L Account Filter Expression"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Account Filter';

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "G/L Account Filter Expression" <> '' then begin
                    GLAccount.SetView(ConvertFilterStringToView("G/L Account Filter Expression"));
                    "G/L Account View String" := CopyStr(GLAccount.GetView(false), 1, MaxStrLen("G/L Account View String"));
                    "G/L Account Filter Expression" := CopyStr(GLAccount.GetFilters(), 1, MaxStrLen("G/L Account Filter Expression"));
                end else
                    "G/L Account View String" := '';
            end;

            trigger OnLookup()
            begin
                LookupFilterExpression();
            end;
        }
        field(5318; "G/L Account View String"; Text[1024])
        {
            Caption = 'G/L Account View String';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    trigger OnInsert()
    var
        DimensionSie: Record "Dimension SIE";
    begin
        Rec.Dimensions := DimensionSie.GetDimSelectionText();
    end;

    var
        FilterStringParseErr: label 'Could not parse the filter expression. Use the lookup action, or type a string in the following format: "Account Type: Total, Account Category: Assets".';
        TooManyFiltersErr: label 'You have selected too many filters for G/L accounts. Open the filter page again and set fewer filters.';
        AuditExportFormatSetupNotExistMsg: label 'Audit File Export Format Setup does not exist for the SIE export format. Open the SIE Audit File Export Setup Guide page and follow the instructions.';
#if not CLEAN22
        FeatureNotEnabledMsg: label 'SIE feature is not enabled yet in your Business Central. An administrator can enable the feature on the Feature Management page.';
#endif
        FilterTxt: label '%1=FILTER(%2)', Locked = true;
        WhereTxt: label '%1 WHERE(%2)', Locked = true;

    local procedure ConvertFilterStringToView(FilterString: Text): Text
    var
        GLAccount: Record "G/L Account";
        ConvertedFilterString: Text;
        MidPos: Integer;
        FinishPos: Integer;
    begin
        while FilterString <> '' do begin
            // Convert "Account Type: Total" to "Account Type=FILTER(Total)"
            MidPos := StrPos(FilterString, ':');
            if MidPos < 2 then
                Error(FilterStringParseErr);
            FinishPos := StrPos(FilterString, ',');
            if FinishPos = 0 then
                FinishPos := StrLen(FilterString) + 1;
            if ConvertedFilterString <> '' then
                ConvertedFilterString += ',';
            ConvertedFilterString +=
              StrSubstNo(FilterTxt, CopyStr(FilterString, 1, MidPos - 1), CopyStr(FilterString, MidPos + 1, FinishPos - MidPos - 1));
            FilterString := DelStr(FilterString, 1, FinishPos);
        end;

        if ConvertedFilterString <> '' then
            exit(StrSubstNo(WhereTxt, GLAccount.GetView(), ConvertedFilterString));

        exit('');
    end;

    local procedure LookupFilterExpression()
    var
        GLAccount: Record "G/L Account";
        FilterPageBuilder: FilterPageBuilder;
        TableCaptionValue: Text;
        GLAccountViewString: Text;
    begin
        TableCaptionValue := GLAccount.TableCaption();
        FilterPageBuilder.AddTable(TableCaptionValue, Database::"G/L Account");
        if "G/L Account View String" <> '' then
            FilterPageBuilder.SetView(TableCaptionValue, "G/L Account View String");
        if FilterPageBuilder.RunModal() then begin
            GLAccountViewString := FilterPageBuilder.GetView(TableCaptionValue, false);
            if StrLen(GLAccountViewString) > MaxStrLen("G/L Account View String") then
                Error(TooManyFiltersErr);
            GLAccount.SetView(FilterPageBuilder.GetView(TableCaptionValue, false));
            "G/L Account View String" := CopyStr(GLAccount.GetView(false), 1, MaxStrLen("G/L Account View String"));
            "G/L Account Filter Expression" := CopyStr(GLAccount.GetFilters(), 1, MaxStrLen("G/L Account Filter Expression"));
        end;
    end;
}
