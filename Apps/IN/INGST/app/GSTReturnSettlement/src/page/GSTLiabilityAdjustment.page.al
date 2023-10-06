// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;

page 18320 "GST Liability Adjustment"
{
    Caption = 'GST Liability Adjustment';
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Adj Doc No"; AdjDocNo)
                {
                    Caption = 'Adjustment  Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the Journal.';
                }
                field(GSTINNo2; GSTINNo)
                {
                    Caption = 'GST Registration No.';
                    ApplicationArea = Basic, Suite;
                    TableRelation = "GST Registration Nos." where("Input Service Distributor" = const(false));
                    ToolTip = 'Specifies the companies GST registration number.';

                    trigger OnValidate()
                    var
                        GSTRegistrationNos: Record "GST Registration Nos.";
                    begin
                        GSTRegistrationNos.Get(GSTINNo);
                        if GSTRegistrationNos."Input Service Distributor" then
                            Error(ISDGSTRegNoErr);
                    end;
                }
                field(PostingDate2; PostingDate)
                {
                    Caption = 'Posting Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entries posting date.';

                    trigger OnValidate()
                    var
                        CalculationDateFor: DateFormula;
                        CalculationDateStr: Text;
                    begin
                        if Format(LiabilityDateFormula) <> '' then begin
                            CalculationDateStr := '-' + Format(LiabilityDateFormula);
                            EVALUATE(CalculationDateFor, CalculationDateStr);
                            LiabilityFilterDate := CalcDate(CalculationDateFor, PostingDate);
                        end;
                    end;
                }
                field(LiabilityDateFormula2; LiabilityDateFormula)
                {
                    Caption = 'Liability Date Formula';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a day count from which system will reverse count from posting date for arriving to liability filter date.';

                    trigger OnValidate()
                    var
                        CalculationDateFor: DateFormula;
                        CalculationDateStr: Text;
                    begin
                        if Format(LiabilityDateFormula) <> '' then begin
                            CalculationDateStr := '-' + Format(LiabilityDateFormula);
                            EVALUATE(CalculationDateFor, CalculationDateStr);
                            LiabilityFilterDate := CalcDate(CalculationDateFor, PostingDate);
                        end;
                    end;
                }
                field(LiabilityFilterDate2; LiabilityFilterDate)
                {
                    Caption = 'Liability Filter Date';
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a date filter in combination of posting date and liability date filter formula.';
                }
                field(VendorNo2; VendorNo)
                {
                    Caption = 'Vendor No.';
                    ApplicationArea = Basic, Suite;
                    TableRelation = Vendor."No." where("GST Vendor Type" = FILTER('Registered|Unregistered|Import|SEZ'));
                    ToolTip = 'Specifies the Vendor number for which adjustment has to be done.';
                }
                field(DocumentNo2; DocumentNo)
                {
                    Caption = 'Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the journal entry .';
                }
                field(ExternalDocNo2; ExternalDocNo)
                {
                    Caption = 'External Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customers or Vendors numbering system.';
                }
                field(NatureOfAdjustment2; NatureOfAdjustment)
                {
                    Caption = 'Nature Of Adjustment';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies different adjustment types. For example, Generate/Reverse etc.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(ApplyEntries)
            {
                Caption = '&Apply Entries';
                Image = ApplyEntries;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+F11';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select one or more ledger entries that you want to apply this record to so that the related posted documents are closed as paid or refunded.';

                trigger OnAction()
                var
                    GSTLiabilityAdjustment: Record "GST Liability Adjustment";
                begin
                    CheckMandatoryFields();
                    GSTLiabilityAdjustment.DeleteAll();
                    GSTSettlement.FillGSTLiabilityAdjustmentJournal(
                        GSTINNo,
                        VendorNo,
                        LiabilityFilterDate,
                        DocumentNo,
                        ExternalDocNo,
                        NatureOfAdjustment,
                        AdjDocNo,
                        PostingDate);
                    Commit();
                    Page.RunModal(Page::"GST Liability Adj. Journal");
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        AdjDocNo := NoSeriesManagement.GetNextNo(GSTSettlement.GetNoSeriesCode(true), PostingDate, false);
    end;

    local procedure CheckMandatoryFields()
    begin
        if AdjDocNo = '' then
            Error(AdjDocErr);
        if GSTINNo = '' then
            Error(GSTINNoErr);
        if PostingDate = 0D then
            Error(PostingDateErr);
        if Format(LiabilityDateFormula) = '' then
            Error(DateFormulaErr);
        if NatureOfAdjustment = NatureOfAdjustment::" " then
            Error(NatureOfAdjErr);
    end;

    var
        GSTSettlement: Codeunit "GST Settlement";
        LiabilityDateFormula: DateFormula;
        NatureOfAdjustment: Enum "Cr Libty Adjustment Type";
        AdjDocNo: Code[20];
        GSTINNo: Code[15];
        VendorNo: Code[20];
        DocumentNo: Code[20];
        ExternalDocNo: Code[35];
        PostingDate: Date;
        LiabilityFilterDate: Date;
        GSTINNoErr: Label 'GSTIN No. must not be empty.';
        PostingDateErr: Label 'Posting Date must not be blank.';
        AdjDocErr: Label 'Adjust Document No. must not be empty.';
        NatureOfAdjErr: Label 'Nature of Adjustment can not be blank.';
        ISDGSTRegNoErr: Label 'You must select GST Registration No. that has ISD set to False.';
        DateFormulaErr: Label 'Liability Formula must not be blank.';
}
