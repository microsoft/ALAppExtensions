// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN24
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;

report 31115 "Batch Post Purchase Orders CZL"
{
    Caption = 'Batch Post Purchase Orders';
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by standard report 496 "Batch Post Purchase Orders"';
    ObsoleteTag = '24.0';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
            RequestFilterFields = "No.", Status;
            RequestFilterHeading = 'Purchase Order';

            trigger OnPreDataItem()
            var
                PurchaseBatchPostMgt: Codeunit "Purchase Batch Post Mgt.";
            begin
                OnBeforePurchaseBatchPostMgt("Purchase Header", ReceiveReq, InvReq);

                if ReplaceVATDateReq and (VATDateReq = 0D) then
                    Error(EnterVATDateErr);

                PurchaseBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDateReq);
                PurchaseBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"VAT Date", VATDateReq);

                PurchaseBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::Print, PrintDocReq);
                PurchaseBatchPostMgt.RunBatch(
                  "Purchase Header", ReplacePostingDateReq, PostingDateReq, ReplaceDocumentDateReq, CalcInvDiscReq, ReceiveReq, InvReq);

                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Receive; ReceiveReq)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Receive';
                        ToolTip = 'Specifies whether the purchase orders will be received when posted. If you place a check mark in the box, it will apply to all the orders that are posted.';
                    }
                    field(Invoice; InvReq)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Invoice';
                        ToolTip = 'Specifies whether the purchase orders will be invoiced when posted. If you place a check mark in the box, it will apply to all the orders that are posted.';
                    }
                    field(PostingDate; PostingDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date that the program will use as the document and/or posting date when you post if you place a checkmark in one or both of the following boxes.';

                        trigger OnValidate()
                        begin
                            VATDateReq := PostingDateReq;
                        end;
                    }
                    field(VATDate; VATDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Date';
                        ToolTip = 'Specifies VAT Date for posting.';
                        Visible = VATDateVisible;
                    }
                    field(ReplacePostingDate; ReplacePostingDateReq)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Replace Posting Date';
                        ToolTip = 'Specifies if you want to replace the orders'' posting date with the date entered in the field above.';

                        trigger OnValidate()
                        begin
                            if ReplacePostingDateReq then
                                Message(ExchRateNotApplyMsg);
                        end;
                    }
                    field(ReplaceDocumentDate; ReplaceDocumentDateReq)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Replace Document Date';
                        ToolTip = 'Specifies if you want to replace the purchase orders'' document date with the date in the Posting Date field.';
                    }
                    field(ReplaceVATDate; ReplaceVATDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replace VAT Date';
                        ToolTip = 'Specifies if the new VAT date will be applied.';
                        Visible = VATDateVisible;
                    }
                    field(CalcInvDiscount; CalcInvDiscReq)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Calc. Inv. Discount';
                        ToolTip = 'Specifies if you want the invoice discount amount to be automatically calculated on the orders before posting.';

                        trigger OnValidate()
                        var
                            PurchasesPayablesSetup: Record "Purchases & Payables Setup";
                        begin
                            PurchasesPayablesSetup.Get();
                            PurchasesPayablesSetup.TestField("Calc. Inv. Discount", false);
                        end;
                    }
                    field(PrintDoc; PrintDocReq)
                    {
                        ApplicationArea = Suite;
                        Visible = PrintDocVisible;
                        Caption = 'Print';
                        ToolTip = 'Specifies if you want to print the order after posting. In the Report Output Type field on the Purchases and Payables page, you define if the report will be printed or output as a PDF.';

                        trigger OnValidate()
                        var
                            PurchasesPayablesSetup: Record "Purchases & Payables Setup";
                        begin
                            if PrintDocReq then begin
                                PurchasesPayablesSetup.Get();
                                if PurchasesPayablesSetup."Post with Job Queue" then
                                    PurchasesPayablesSetup.TestField("Post & Print with Job Queue");
                            end;
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            PurchasesPayablesSetup: Record "Purchases & Payables Setup";
            VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        begin
            PurchasesPayablesSetup.Get();
            CalcInvDiscReq := PurchasesPayablesSetup."Calc. Inv. Discount";
            PrintDocReq := false;
            PrintDocVisible := PurchasesPayablesSetup."Post & Print with Job Queue";
            VATDateVisible := VATReportingDateMgt.IsVATDateEnabled();
        end;
    }

    var
        ExchRateNotApplyMsg: Label 'The exchange rate associated with the new posting date on the purchase header will not apply to the purchase lines.';
        ReceiveReq: Boolean;
        InvReq: Boolean;
        PostingDateReq: Date;
        VATDateReq: Date;
        ReplacePostingDateReq: Boolean;
        ReplaceDocumentDateReq: Boolean;
        ReplaceVATDateReq: Boolean;
        VATDateVisible: Boolean;
        CalcInvDiscReq: Boolean;
        PrintDocReq: Boolean;
        PrintDocVisible: Boolean;
        EnterVATDateErr: Label 'Enter the VAT date.';

    procedure InitializeRequest(NewReceiveReq: Boolean; NewInvReq: Boolean; NewPostingDateReq: Date; NewVATDateReq: Date; NewReplacePostingDateReq: Boolean; NewReplaceDocumentDateReq: Boolean; NewReplaceVATDateReq: Boolean; NewCalcInvDiscReq: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if NewReplaceVATDateReq or (NewVATDateReq <> 0D) then
            GeneralLedgerSetup.TestIsVATDateEnabledCZL();
        VATDateReq := NewVATDateReq;
        ReplaceVATDateReq := NewReplaceVATDateReq;
        InitializeRequest(NewReceiveReq, NewInvReq, NewPostingDateReq, NewReplacePostingDateReq, NewReplaceDocumentDateReq, NewCalcInvDiscReq);
    end;

    procedure InitializeRequest(NewReceiveReq: Boolean; NewInvReq: Boolean; NewPostingDateReq: Date; NewReplacePostingDateReq: Boolean; NewReplaceDocumentDateReq: Boolean; NewCalcInvDiscReq: Boolean)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        ReceiveReq := NewReceiveReq;
        InvReq := NewInvReq;
        PostingDateReq := NewPostingDateReq;
        ReplacePostingDateReq := NewReplacePostingDateReq;
        ReplaceDocumentDateReq := NewReplaceDocumentDateReq;
        if NewCalcInvDiscReq then
            PurchasesPayablesSetup.TestField("Calc. Inv. Discount", false);
        CalcInvDiscReq := NewCalcInvDiscReq;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchaseBatchPostMgt(var PurchaseHeader: Record "Purchase Header"; var ReceiveReq: Boolean; var InvReq: Boolean)
    begin
    end;
}
#endif