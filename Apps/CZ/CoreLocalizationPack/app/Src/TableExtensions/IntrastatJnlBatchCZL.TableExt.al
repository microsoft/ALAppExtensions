// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;
#if not CLEAN22

using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
#endif

#pragma warning disable AL0432
tableextension 31025 "Intrastat Jnl. Batch CZL" extends "Intrastat Jnl. Batch"
#pragma warning restore AL0432
{
    fields
    {
        field(31081; "Declaration No. CZL"; Code[20])
        {
            Caption = 'Declaration No.';
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            begin
                TestField("Statistics Period");
#pragma warning disable AL0432
                CheckUniqueDeclarationNoCZL();
                if xRec."Declaration No. CZL" <> '' then
                    CheckJnlLinesExistCZL(FieldNo("Declaration No. CZL"));
#pragma warning restore AL0432
            end;
#endif
        }
        field(31082; "Statement Type CZL"; Enum "Intrastat Statement Type CZL")
        {
            Caption = 'Statement Type';
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            begin
#pragma warning disable AL0432
                CheckJnlLinesExistCZL(FieldNo("Statement Type CZL"));
#pragma warning restore AL0432
            end;
#endif
        }
    }
#if not CLEAN22

    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        DeclarationAlreadyExistsErr: Label 'Declaration No. %1 already exists for Statistics Period %2.', Comment = '%1 = declaration number, %2 = statistics period';
        CannotChangeFieldErr: Label 'You cannot change %1 value after Intrastat Journal Batch %2 was exported.', Comment = '%1 = field caption, %2 = intrastat journal batch name';

    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions. This function is not used anymore.', '22.0')]
    procedure CheckUniqueDeclarationNoCZL()
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
    begin
        if "Declaration No. CZL" <> '' then begin
            IntrastatJnlBatch.Reset();
            IntrastatJnlBatch.SetRange("Journal Template Name", "Journal Template Name");
            IntrastatJnlBatch.SetRange("Statistics Period", "Statistics Period");
            IntrastatJnlBatch.SetRange("Declaration No. CZL", "Declaration No. CZL");
            IntrastatJnlBatch.SetFilter(Name, '<>%1', Name);
            if not IntrastatJnlBatch.IsEmpty() then
                Error(DeclarationAlreadyExistsErr, "Declaration No. CZL", "Statistics Period");
        end;
    end;

    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions. This function is not used anymore.', '22.0')]
    procedure CheckJnlLinesExistCZL(CurrentFieldNo: Integer)
    begin
        IntrastatJnlLine.Reset();
        IntrastatJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        IntrastatJnlLine.SetRange("Journal Batch Name", Name);
        case CurrentFieldNo of
            FieldNo("Statistics Period"):
                begin
                    IntrastatJnlLine.SetRange("Statistics Period CZL", xRec."Statistics Period");
                    if IntrastatJnlLine.FindFirst() then
                        Error(CannotChangeFieldErr, FieldCaption("Statistics Period"), Name);
                end;
            FieldNo("Declaration No. CZL"):
                begin
                    IntrastatJnlLine.SetRange("Declaration No. CZL", xRec."Declaration No. CZL");
                    if IntrastatJnlLine.FindFirst() then
                        Error(CannotChangeFieldErr, FieldCaption("Declaration No. CZL"), Name);
                end;
            FieldNo("Statement Type CZL"):
                begin
                    IntrastatJnlLine.SetRange("Statement Type CZL", xRec."Statement Type CZL");
                    if IntrastatJnlLine.FindFirst() then
                        Error(CannotChangeFieldErr, FieldCaption("Statement Type CZL"), Name);
                end;
        end;
    end;

    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions. This function is not used anymore.', '22.0')]
    procedure AssistEditCZL(): Boolean
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if "Declaration No. CZL" = '' then begin
            StatutoryReportingSetupCZL.Get();
            StatutoryReportingSetupCZL.TestField("Intrastat Declaration Nos.");
            "Declaration No. CZL" := NoSeriesManagement.GetNextNo(StatutoryReportingSetupCZL."Intrastat Declaration Nos.", 0D, true);
            exit(true);
        end;
        exit(false);
    end;
#endif
}
