// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;

page 18317 "GST Credit Adjustment"
{
    Caption = 'GST Credit Adjustment';
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(AdjDocNo2; AdjDocNo)
                {
                    Caption = 'Adjustment  Document No.';
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for this transaction.';
                }
                field(GSTINNo2; GSTINNo)
                {
                    Caption = 'GST Registration No.';
                    ApplicationArea = Basic, Suite;
                    TableRelation = "GST Registration Nos." where("Input Service Distributor" = const(false));
                    ToolTip = 'Specifies the companies GST registration number issued by authorized body.';

                    trigger OnValidate()
                    var
                        GSTRegistrationNos: Record "GST Registration Nos.";
                    begin
                        GSTRegistrationNos.Get(GSTINNo);
                        InputSerDist := GSTRegistrationNos."Input Service Distributor";
                        if GSTRegistrationNos."Input Service Distributor" then
                            Error(ISDGSTRegNoErr);
                    end;
                }
                field(PeriodMonth2; PeriodMonth)
                {
                    Caption = 'Period Month';
                    MaxValue = 12;
                    MinValue = 1;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the period month and the value must be less than or equal to 12.';

                    trigger OnValidate()
                    begin
                        if (PeriodMonth < 1) or (PeriodMonth > 12) then
                            Error(MonthFormatErr);
                    end;
                }
                field(PeriodYear2; PeriodYear)
                {
                    Caption = 'Period Year';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the period year and the format must be YYYY.';

                    trigger OnValidate()
                    begin
                        if StrLen(Format(PeriodYear)) <> 4 then
                            Error(YearFormatErr);
                    end;
                }
                field(PostingDate2; PostingDate)
                {
                    Caption = 'Posting Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entries posting date.';
                }
                field(VendorNo2; VendorNo)
                {
                    Caption = 'Vendor No.';
                    TableRelation = Vendor;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor code for which credit adjustment has to be done.';
                }
                field(DocumentNo2; DocumentNo)
                {
                    Caption = 'Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entries document number.';
                }
                field(ExternalDocNo2; ExternalDocNo)
                {
                    Caption = 'External Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customers or vendors numbering system.';
                }
                field(NatureOfAdjustment2; NatureOfAdjustment)
                {
                    Caption = 'Nature Of Adjustment';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies different adjustment types. For example, Credit Availment/Credit Reversal.';
                }
                field(InputSerDist2; InputSerDist)
                {
                    Caption = 'Input Service Distribution';
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether Input Service Distributor is applicable or not.';
                }
                field(ReverseCharge2; ReverseCharge)
                {
                    Caption = 'Reverse Charge';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if reverse charge is applicable.';
                }
                field(AdjustmentPerc2; AdjustmentPerc)
                {
                    Caption = 'Adjustment %';
                    ApplicationArea = Basic, Suite;
                    MaxValue = 100;
                    MinValue = 0;
                    ToolTip = 'Specifies whether Input Service Distributor is applicable or not.';
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
                ToolTip = 'Apply Entries';

                trigger OnAction()
                var
                    GSTCreditAdjustmentJournal: Record "GST Credit Adjustment Journal";
                begin
                    CheckMandatoryFields();
                    CheckCreditAdjForPeriod();
                    GSTCreditAdjustmentJournal.DeleteAll();
                    GSTSettlement.FillAdjustmentJournal(
                        GSTINNo,
                        VendorNo,
                        PeriodMonth,
                        PeriodYear,
                        PostingDate,
                        DocumentNo,
                        ExternalDocNo,
                        NatureOfAdjustment,
                        AdjDocNo,
                        ReverseCharge,
                        AdjustmentPerc);

                    Commit();
                    Page.RunModal(Page::"GST Credit Adjustment Journal");
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        AdjDocNo := NoSeriesManagement.GetNextNo(
            GSTSettlement.GetNoSeriesCode(false),
            PostingDate,
            false);
        AdjustmentPerc := 100;
    end;

    var
        GSTSettlement: Codeunit "GST Settlement";
        NatureOfAdjustment: Enum "Credit Adjustment Type";
        PeriodMonth: Integer;
        PeriodYear: Integer;
        AdjDocNo: Code[20];
        GSTINNo: Code[20];
        VendorNo: Code[20];
        ExternalDocNo: Code[35];
        DocumentNo: Code[20];
        ReverseCharge: Boolean;
        InputSerDist: Boolean;
        PostingDate: Date;
        AdjustmentPerc: Decimal;
        GSTINNoErr: Label 'GSTIN No. must not be empty.';
        MonthErr: Label 'Period Month must not be empty.';
        YearErr: Label 'Period Year must not be empty.';
        PostingDateErr: Label 'Posting Date must not be blank.';
        YearFormatErr: Label 'Year format must be YYYY.';
        MonthFormatErr: Label 'Month must be within 1 to 12.';
        AdjDocErr: Label 'Adjust Document No. must not be empty.';
        NatureOfAdjErr: Label 'Nature of Adjustment can not be blank.';
        AdjPeriodErr: Label 'Posting Date must be after Period Month & Period Year.';
        ISDGSTRegNoErr: Label 'You must select GST Registration No. that has ISD set to False.';
        ReverseChargeAdjstTypeErr: Label 'Permanent Reversal is not allowed for Reverse Charge transactions.';
        RegisteredAdjstTypeErr: Label 'Credit Availment and Reversal of Availment is allowed for Reverse Charge Vendors.';
        AdjPercErr: Label 'Adjustment Percentage must have some value.';

    local procedure CheckMandatoryFields()
    begin
        if AdjDocNo = '' then
            Error(AdjDocErr);

        if GSTINNo = '' then
            Error(GSTINNoErr);

        if PeriodMonth = 0 then
            Error(MonthErr);

        if PeriodYear = 0 then
            Error(YearErr);

        if PostingDate = 0D then
            Error(PostingDateErr);

        if NatureOfAdjustment = NatureOfAdjustment::" " then
            Error(NatureOfAdjErr);

        if ReverseCharge and (NatureOfAdjustment = NatureOfAdjustment::"Permanent Reversal") then
            Error(ReverseChargeAdjstTypeErr);

        if (not ReverseCharge) and
           (NatureOfAdjustment in [
               NatureOfAdjustment::"Credit Availment",
               NatureOfAdjustment::"Reversal of Availment"])
        then
            Error(RegisteredAdjstTypeErr);

        if AdjustmentPerc = 0 then
            Error(AdjPercErr);
    end;

    local procedure CheckCreditAdjForPeriod()
    begin
        if (PeriodMonth >= Date2DMY(PostingDate, 2)) and (PeriodYear = Date2DMY(PostingDate, 3)) then
            Error(AdjPeriodErr);

        if PeriodYear > Date2DMY(PostingDate, 3) then
            Error(AdjPeriodErr);
    end;
}
