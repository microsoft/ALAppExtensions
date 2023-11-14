// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN24
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Foundation.BatchProcessing;

report 31119 "Batch Post Purch. Ret.Ord. CZL"
{
    Caption = 'Batch Post Purch. Ret. Orders';
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by standard report 6665 "Batch Post Purch. Ret. Orders"';
    ObsoleteTag = '24.0';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const("Return Order"));
            RequestFilterFields = "No.", Status;
            RequestFilterHeading = 'Purchase Return Order';

            trigger OnPreDataItem()
            var
                PurchaseBatchPostMgt: Codeunit "Purchase Batch Post Mgt.";
            begin
                if ReplaceVATDateReq and (VATDateReq = 0D) then
                    Error(EnterVATDateErr);

                PurchaseBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDateReq);
                PurchaseBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"VAT Date", VATDateReq);

                PurchaseBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::Ship, ShipReq);
                PurchaseBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::Print, PrintDocReq);
                PurchaseBatchPostMgt.RunBatch("Purchase Header", ReplacePostingDateReq, PostingDateReq, ReplaceDocumentDateReq, CalcInvDiscReq, false, InvReq);

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
                    field(Ship; ShipReq)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Ship';
                        ToolTip = 'Specifies if the orders are shipped when posted. If you select this check box, it applies to all orders that are posted.';
                    }
                    field(Invoice; InvReq)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Invoice';
                        ToolTip = 'Specifies if the orders are invoiced when posted. If you select this check box, it applies to all the orders that are posted.';
                    }
                    field(PostingDate; PostingDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date that you want to use as the document date or the posting date when you post if you select the Replace Document Date check box or the Replace Posting Date check box.';

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
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Replace Posting Date';
                        ToolTip = 'Specifies if you want to replace the posting date of the orders with the date that is entered in the Posting Date field.';

                        trigger OnValidate()
                        begin
                            if ReplacePostingDateReq then
                                Message(ExchRateNotApplyMsg);
                        end;
                    }
                    field(ReplaceDocumentDate; ReplaceDocumentDateReq)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Replace Document Date';
                        ToolTip = 'Specifies if you want to replace the document date of the orders with the date in the Posting Date field.';
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
                        ApplicationArea = PurchReturnOrder;
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
                        ApplicationArea = Basic, Suite;
                        Visible = PrintDocVisible;
                        Caption = 'Print';
                        ToolTip = 'Specifies if you want to print the return order after posting. In the Report Output Type field on the Purchases and Payables page, you define if the report will be printed or output as a PDF.';

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
        PostingDateReq: Date;
        VATDateReq: Date;
        ShipReq: Boolean;
        InvReq: Boolean;
        ReplacePostingDateReq: Boolean;
        ReplaceDocumentDateReq: Boolean;
        ReplaceVATDateReq: Boolean;
        VATDateVisible: Boolean;
        CalcInvDiscReq: Boolean;
        PrintDocReq: Boolean;
        PrintDocVisible: Boolean;
        EnterVATDateErr: Label 'Enter the VAT date.';
}
#endif