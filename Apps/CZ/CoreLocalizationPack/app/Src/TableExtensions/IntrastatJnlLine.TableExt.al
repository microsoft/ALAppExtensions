// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

#pragma warning disable AL0432
tableextension 31026 "Intrastat Jnl. Line CZL" extends "Intrastat Jnl. Line"
#pragma warning restore AL0432
{
    fields
    {
        field(31080; "Additional Costs CZL"; Boolean)
        {
            Caption = 'Additional Costs';
            Editable = false;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31081; "Source Entry Date CZL"; Date)
        {
            Caption = 'Source Entry Date';
            Editable = false;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31082; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No."));
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31083; "Statistics Period CZL"; Code[10])
        {
            Caption = 'Statistics Period';
            Editable = false;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31085; "Declaration No. CZL"; Code[10])
        {
            Caption = 'Declaration No.';
            Editable = false;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31086; "Statement Type CZL"; Enum "Intrastat Statement Type CZL")
        {
            Caption = 'Statement Type';
            Editable = false;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31087; "Prev. Declaration No. CZL"; Code[10])
        {
            Caption = 'Prev. Declaration No.';
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22
            trigger OnLookup()
            begin
                LookUpPrevDeclaration(true);
            end;
#endif
        }
        field(31088; "Prev. Declaration Line No. CZL"; Integer)
        {
            Caption = 'Prev. Declaration Line No.';
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22
            trigger OnLookup()
            begin
                LookUpPrevDeclaration(false);
            end;
#endif
        }
        field(31090; "Specific Movement CZL"; Code[10])
        {
            Caption = 'Specific Movement';
            TableRelation = "Specific Movement CZL".Code;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31091; "Supplem. UoM Code CZL"; Code[10])
        {
            Caption = 'Supplem. UoM Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31092; "Supplem. UoM Quantity CZL"; Decimal)
        {
            Caption = 'Supplem. UoM Quantity';
            DecimalPlaces = 0 : 3;
            Editable = false;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31093; "Supplem. UoM Net Weight CZL"; Decimal)
        {
            Caption = 'Supplem. UoM Net Weight';
            DecimalPlaces = 2 : 5;
            Editable = false;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31094; "Base Unit of Measure CZL"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
    }
#if not CLEAN22
    local procedure LookUpPrevDeclaration(Header: Boolean)
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        IntrastatJnlLine2: Record "Intrastat Jnl. Line";
        IntrastatJournalLines: Page "Intrastat Journal Lines CZL";
    begin
        Clear(IntrastatJournalLines);
        IntrastatJnlLine.Reset();
        IntrastatJnlLine.FilterGroup(2);
        if Header or ("Prev. Declaration No. CZL" = '') then
            IntrastatJnlLine.SetFilter("Declaration No. CZL", '<>%1', '')
        else
            IntrastatJnlLine.SetRange("Declaration No. CZL", "Prev. Declaration No. CZL");
        IntrastatJnlLine.FilterGroup(0);
        IntrastatJournalLines.LookupMode := true;
        IntrastatJournalLines.SetTableView(IntrastatJnlLine);
        if IntrastatJournalLines.RunModal() = Action::LookupOK then begin
            IntrastatJournalLines.GetRecord(IntrastatJnlLine2);
            if Header then
                "Prev. Declaration No. CZL" := IntrastatJnlLine2."Declaration No. CZL"
            else begin
                IntrastatJnlLine2."Journal Template Name" := "Journal Template Name";
                IntrastatJnlLine2."Journal Batch Name" := "Journal Batch Name";
                IntrastatJnlLine2.Type := Type;
                IntrastatJnlLine2."Internal Ref. No." := "Internal Ref. No.";
                IntrastatJnlLine2."Prev. Declaration No. CZL" := IntrastatJnlLine2."Declaration No. CZL";
                IntrastatJnlLine2."Prev. Declaration Line No. CZL" := IntrastatJnlLine2."Line No.";
                IntrastatJnlLine2."Declaration No. CZL" := "Declaration No. CZL";
                IntrastatJnlLine2."Line No." := "Line No.";
                IntrastatJnlLine2."Statistics Period CZL" := "Statistics Period CZL";
                TransferFields(IntrastatJnlLine2, false);
            end;
        end;
    end;

    procedure RoundValueCZL(Value: Decimal): Decimal
    begin
        if Value >= 1 then
            exit(Round(Value, 1));
        exit(Value);
    end;

    procedure ExportIntrastatJournalCZL(var IntrastatJnlLine: Record "Intrastat Jnl. Line")
    var
        IntrastatExportObjectType: Option ,,,Report,,Codeunit,XMLPort;
        IntrastatExportObjectNo: Integer;
        IsHandled: Boolean;
    begin
        IntrastatExportObjectType := IntrastatExportObjectType::Report;
        IntrastatExportObjectNo := Report::"Intrastat Declaration Exp. CZL";
        IsHandled := false;
        OnBeforeExportIntrastatJournalCZL(IntrastatJnlLine, IntrastatExportObjectType, IntrastatExportObjectNo, IsHandled);
        if IsHandled then
            exit;

        case IntrastatExportObjectType of
            IntrastatExportObjectType::Report:
                Report.RunModal(IntrastatExportObjectNo, true, false, IntrastatJnlLine);
            IntrastatExportObjectType::Codeunit:
                Codeunit.Run(IntrastatExportObjectNo, IntrastatJnlLine);
            IntrastatExportObjectType::XmlPort:
                XmlPort.Run(IntrastatExportObjectNo, true, false, IntrastatJnlLine);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportIntrastatJournalCZL(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; var IntrastatExportObjectType: Option ,,,Report,,Codeunit,XMLPort; var IntrastatExportObjectNo: Integer; var IsHandled: Boolean)
    begin
    end;
#endif
}
