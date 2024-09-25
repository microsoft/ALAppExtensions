// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.AuditCodes;
using System.Telemetry;

tableextension 10826 "Audit File Export Header FEC" extends "Audit File Export Header"
{
    fields
    {
        modify("Audit File Export Format")
        {
            trigger OnBeforeValidate()
            var
                AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
            begin
                if Rec."Audit File Export Format" = Rec."Audit File Export Format"::FEC then
                    if not AuditFileExportFormatSetup.Get(Rec."Audit File Export Format"::FEC) then
                        Error(AuditExportFormatSetupNotExistMsg);
            end;

            trigger OnAfterValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
            begin
                if Rec."Audit File Export Format" = Rec."Audit File Export Format"::FEC then begin
                    Rec.Validate("Split By Month", false);
                    Rec.Validate("Split By Date", false);
                    Rec.Validate("Create Multiple Zip Files", false);

                    FeatureTelemetry.LogUptake('0000K6Z', FECAuditFileTok, Enum::"Feature Uptake Status"::Discovered);
                end;
            end;
        }

        field(10826; "Include Opening Balances"; Boolean)
        {
        }
        field(10827; "Default Source Code"; Code[10])
        {
            TableRelation = "Source Code";
        }
        field(10828; "G/L Account Filter Expression"; Text[2048])
        {
            Caption = 'G/L Account Filter';
        }
        field(10829; "G/L Account View String"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10830; "Use Transaction No."; Boolean)
        {
            ObsoleteReason = 'The transaction number will be used as the progressive number by default. This field is no longer needed.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
    }

    var
        TooManyFiltersErr: label 'You have selected too many filters for G/L accounts. Open the filter page again and set fewer filters.';
        AuditExportFormatSetupNotExistMsg: label 'Audit File Export Format Setup does not exist for the Fichier des écritures comptables (FEC) export format. Reinstall FEC Audit File extension or add a new line with the FEC format to Audit File Export Format setup.';
        FECAuditFileTok: label 'FEC Audit File', Locked = true;

    internal procedure SetTableFilter()
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
