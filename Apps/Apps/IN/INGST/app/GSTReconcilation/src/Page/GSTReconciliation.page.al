// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

page 18282 "GST Reconciliation"
{
    Caption = 'GST Reconciliation';
    PaGetype = Document;
    PromotedActionCategories = 'New,Process,Report,Manage,Matching';
    SourceTable = "GST Reconcilation";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("GSTIN No."; Rec."GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'SpecIfies the GSTIN for which GST reconciliation is created.';

                    trigger OnValidate()
                    begin
                        if (Rec.Month <> 0) and (Rec.Year <> 0) then
                            CurrPage.Update();
                    end;
                }
                field(Month; Rec.Month)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'SpecIfies the month for which GST reconciliation is created.';

                    trigger OnValidate()
                    begin
                        if (Rec."GSTIN No." <> '') and (Rec.Year <> 0) then
                            CurrPage.Update();
                    end;
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'SpecIfies the year for which GST reconciliation is created.';

                    trigger OnValidate()
                    begin
                        if (Rec."GSTIN No." <> '') and (Rec.Month <> 0) then
                            CurrPage.Update();
                    end;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the document number for the reconciliation line.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'SpecIfies the date on which GST reconciliation entries will be posted.';
                }
                field("GST Recon. Tolerance"; Rec."GST Recon. Tolerance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'SpecIfies the acceptable tolerance for GST reconciliation.';
                }
                field("Input Service Distributor"; Rec."Input Service Distributor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'SpecIfies if the GSTIN is an input service distributor.';
                }
            }
            group("Reco Lines")
            {
                part("GST Reconciliation Lines"; "GST Reconciliation Lines")
                {
                    Caption = 'GST Reconciliation Lines';
                    ApplicationArea = Basic, Suite;
                    SubPageLink = "GSTIN No." = field("GSTIN No."),
                                  Month = field(Month),
                                  Year = field(Year);
                }
                part("Periodic GSTR-2A Data"; "Periodic GSTR-2A Data")
                {
                    Caption = 'Periodic GSTR-2A Data';
                    ApplicationArea = Basic, Suite;
                    SubPageLink = "GSTIN No." = field("GSTIN No."),
                                  Reconciled = filter(false),
                                  Month = field(Month),
                                  Year = field(Year);
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Import GSTR-2A")
                {
                    Caption = 'Import GSTR-2A';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the import recode invoice data for matching';
                    Image = Import;

                    trigger OnAction()
                    begin
                        Xmlport.Run(Xmlport::"Periodic GSTR-2A Data", false, true);
                    end;
                }
                action(FillGSTReconcilation)
                {
                    Caption = 'Fill GST Reconcilation';
                    Ellipsis = true;
                    Image = SuggestLines;
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Specifies Posted Invoice lines update for Reconciliation.';

                    trigger OnAction()
                    begin
                        GSTReconcilationMatch.CheckMandatoryFields(Rec);
                        GSTReconcilationMatch.CheckSettlement(Rec."GSTIN No.", Rec.Month, Rec.Year);
                        GSTReconcilationMatch.UpdateGSTReconcilationLine(Rec."GSTIN No.", Rec.Month, Rec.Year);
                    end;
                }
            }
            group("M&atching")
            {
                Caption = 'M&atching';
                action(Match)
                {
                    Caption = 'Match';
                    Image = MapAccounts;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Match line with GSTR 2a line.';

                    trigger OnAction()
                    begin
                        GSTReconcilationMatch.CheckMandatoryFields(rec);
                        GSTReconcilationMatch.CheckPostedGSTReconiliation(Rec."GSTIN No.", Rec.Month, Rec.Year);
                        CheckGSTAccountingPeriod(Rec."Posting Date");
                        ResetRecords(Rec."GSTIN No.", Rec.Month, Rec.Year);
                        GSTReconcilationMatch.ReconcileWithGSTR2AData(
                                Rec."GSTIN No.",
                                Rec.Month,
                                Rec.Year,
                                Rec."Posting Date");
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action(Post)
                {
                    Caption = 'Post';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Finalize the document by posting the amount and quantities to the related accounts.';

                    trigger OnAction()
                    begin
                        CheckGSTAccountingPeriod(Rec."Posting Date");
                        CheckGSTAccountingPeriod(DMY2Date(1, Rec.Month, Rec.Year));
                        CheckGSTAccountingPeriod(GSTReconcilationMatch.CalculateMonth(Rec.Month, Rec.Year));
                        GSTReconcilationMatch.CheckPostedGSTReconiliation(Rec."GSTIN No.", Rec.Month, Rec.Year);
                        GSTReconcilationMatch.PreparePostGSTReconcilation(
                                Rec."GSTIN No.",
                                Rec."Posting Date",
                                Rec.Month,
                                Rec.Year);
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    ApplicationArea = Dimensions;
                    Image = Dimensions;
                    ShortCutKey = 'ShIft+Ctrl+D';
                    Tooltip = 'Specifies the code for a  dimension that is linked to the record or entry for analysis purposes';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
            }
        }
    }

    local procedure ResetRecords(GSTINNo: Code[20]; GivenMonth: Integer; GivenYear: Integer)
    var
        GSTReconcilationLines: Record "GST Reconcilation Line";
        PeriodicGSTR2AData: Record "Periodic GSTR-2A Data";
    begin
        GSTReconcilationLines.SetRange("GSTIN No.", GSTINNo);
        GSTReconcilationLines.SetRange(Month, GivenMonth);
        GSTReconcilationLines.SetRange(Year, GivenYear);

        GSTReconcilationLines.ModifyAll(Reconciled, false);
        GSTReconcilationLines.ModifyAll("Reconciliation Date", 0D);
        GSTReconcilationLines.ModifyAll("User Id", '');
        GSTReconcilationLines.ModifyAll("Error Type", '');

        PeriodicGSTR2AData.SetRange("GSTIN No.", Rec."GSTIN No.");
        PeriodicGSTR2AData.SetRange(Month, GivenMonth);
        PeriodicGSTR2AData.SetRange(Year, GivenYear);
        PeriodicGSTR2AData.ModifyAll(Matched, PeriodicGSTR2AData.Matched::" ");
    end;

    local procedure CheckGSTAccountingPeriod(PostingDate: Date)
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        GSTSetup: Record "GST Setup";
        LastClosedDate: Date;
    begin
        LastClosedDate := GetLastClosedSubAccPeriod();

        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        TaxAccountingPeriod.Reset();
        TaxAccountingPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        if TaxAccountingPeriod.FindLast() then begin
            TaxAccountingPeriod.SetFilter("Starting Date", '>=%1', PostingDate);
            if not TaxAccountingPeriod.FindFirst() then
                Error(AccountingPeriodErr, PostingDate);
            if LastClosedDate <> 0D then
                if PostingDate < CalcDate('<1M>', LastClosedDate) then
                    Error(
                        PeriodClosedErr,
                        CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)),
                        CalcDate('<1M>', LastClosedDate));
        end else
            Error(AccountingPeriodErr, PostingDate);

        TaxAccountingPeriod.SetRange(Closed, false);
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        if TaxAccountingPeriod.FindLast() then begin
            TaxAccountingPeriod.SetFilter("Starting Date", '>=%1', PostingDate);
            if not TaxAccountingPeriod.FindFirst() then
                if LastClosedDate <> 0D then
                    if PostingDate < CalcDate('<1M>', LastClosedDate) then
                        Error(
                            PeriodClosedErr,
                            CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)),
                            CalcDate('<1M>', LastClosedDate));
            TaxAccountingPeriod.TestField(Closed, false);
        end else
            if LastClosedDate <> 0D then
                if PostingDate < CalcDate('<1M>', LastClosedDate) then
                    Error(
                        PeriodClosedErr,
                        CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)),
                        CalcDate('<1M>', LastClosedDate));
    end;

    local procedure GetLastClosedSubAccPeriod(): Date
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");
        TaxAccountingPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        TaxAccountingPeriod.SetRange(Closed, TRUE);
        if TaxAccountingPeriod.FindLast() then
            exit(TaxAccountingPeriod."Starting Date");
    end;

    var
        GSTReconcilationMatch: Codeunit "GST Reconcilation Match";
        AccountingPeriodErr: Label 'GST Accounting Period Does not exist for the given Date %1.', Comment = '%1 = PostingDate';
        PeriodClosedErr: Label 'Accounting Period has been closed till %1, Document Posting Date must be greater than or equal to %2.', Comment = '%1 = LastClosedDate,%2 = LastClosedDate';
}
