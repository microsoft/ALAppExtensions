// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN24
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Setup;

report 31118 "Batch Post Sales Ret. Ord. CZL"
{
    Caption = 'Batch Post Sales Return Orders';
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by standard report 6655 "Batch Post Sales Return Orders"';
    ObsoleteTag = '24.0';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const("Return Order"));
            RequestFilterFields = "No.", Status;
            RequestFilterHeading = 'Sales Return Order';

            trigger OnPreDataItem()
            var
                SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt.";
            begin
                if ReplaceVATDateReq and (VATDateReq = 0D) then
                    Error(EnterVATDateErr);

                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDateReq);
                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"VAT Date", VATDateReq);

                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::Receive, ReceiveReq);
                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::Print, PrintDocReq);
                SalesBatchPostMgt.RunBatch("Sales Header", ReplacePostingDateReq, PostingDateReq, ReplaceDocumentDateReq, CalcInvDiscReq, false, InvReq);

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
                        ApplicationArea = SalesReturnOrder;
                        Caption = 'Receive';
                        ToolTip = 'Specifies if the orders are received when posted. If you select this check box, it applies to all the orders that are posted.';
                    }
                    field(Invoice; InvReq)
                    {
                        ApplicationArea = SalesReturnOrder;
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
                        ApplicationArea = SalesReturnOrder;
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
                        ApplicationArea = SalesReturnOrder;
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
                    field(CalcInvDisc; CalcInvDiscReq)
                    {
                        ApplicationArea = SalesReturnOrder;
                        Caption = 'Calc. Inv. Discount';
                        ToolTip = 'Specifies if you want the invoice discount amount to be automatically calculated on the orders before posting.';

                        trigger OnValidate()
                        var
                            SalesReceivablesSetup: Record "Sales & Receivables Setup";
                        begin
                            SalesReceivablesSetup.Get();
                            SalesReceivablesSetup.TestField("Calc. Inv. Discount", false);
                        end;
                    }
                    field(PrintDoc; PrintDocReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = PrintDocVisible;
                        Caption = 'Print';
                        ToolTip = 'Specifies if you want to print the return order after posting. In the Report Output Type field on the Sales & Receivables page, you define if the report will be printed or output as a PDF.';

                        trigger OnValidate()
                        var
                            SalesReceivablesSetup: Record "Sales & Receivables Setup";
                        begin
                            if PrintDocReq then begin
                                SalesReceivablesSetup.Get();
                                if SalesReceivablesSetup."Post with Job Queue" then
                                    SalesReceivablesSetup.TestField("Post & Print with Job Queue");
                            end;
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            GeneralLedgerSetup: Record "General Ledger Setup";
            SalesReceivablesSetup: Record "Sales & Receivables Setup";
            VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        begin
            GeneralLedgerSetup.Get();
            SalesReceivablesSetup.Get();
            CalcInvDiscReq := SalesReceivablesSetup."Calc. Inv. Discount";
            ReplacePostingDateReq := false;
            ReplaceDocumentDateReq := false;
            PrintDocReq := false;
            PrintDocVisible := SalesReceivablesSetup."Post & Print with Job Queue";
            VATDateVisible := VATReportingDateMgt.IsVATDateEnabled();
        end;
    }

    var
        ExchRateNotApplyMsg: Label 'The exchange rate associated with the new posting date on the sales header will apply to the sales lines.';
        PostingDateReq: Date;
        VATDateReq: Date;
        ReceiveReq: Boolean;
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