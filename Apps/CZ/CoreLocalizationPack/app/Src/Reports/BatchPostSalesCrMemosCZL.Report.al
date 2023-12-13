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

report 31114 "Batch Post Sales Cr. Memos CZL"
{
    Caption = 'Batch Post Sales Credit Memos';
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by standard report 298 "Batch Post Sales Credit Memos"';
    ObsoleteTag = '24.0';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const("Credit Memo"));
            RequestFilterFields = "No.", Status;
            RequestFilterHeading = 'Sales Credit Memo';

            trigger OnPreDataItem()
            var
                SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt.";
            begin
                if ReplaceVATDateReq and (VATDateReq = 0D) then
                    Error(EnterVATDateErr);

                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDateReq);
                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"VAT Date", VATDateReq);

                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::Print, PrintDocReq);
                SalesBatchPostMgt.RunBatch("Sales Header", ReplacePostingDateReq, PostingDateReq, ReplaceDocumentDateReq, CalcInvDiscReq, false, false);

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
                    field(PostingDate; PostingDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date that the program will use as the document and/or posting date when you post, if you place a checkmark in one or both of the fields below.';

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
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replace Posting Date';
                        ToolTip = 'Specifies if you want to replace the posting date of the credit memo with the date entered in the Posting/Document Date field.';

                        trigger OnValidate()
                        begin
                            if ReplacePostingDateReq then
                                Message(ExchRateNotApplyMsg);
                        end;
                    }
                    field(ReplaceDocumentDate; ReplaceDocumentDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replace Document Date';
                        ToolTip = 'Specifies if you want to replace the document date of the credit memo with the date in the Posting/Document Date field.';
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
                        ApplicationArea = Basic, Suite;
                        Caption = 'Calc. Inv. Discount';
                        ToolTip = 'Specifies whether the inventory discount should be calculated.';

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
                        ToolTip = 'Specifies if you want to print the credit memo after posting. In the Report Output Type field on the Sales and Receivables page, you define if the report will be printed or output as a PDF.';

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
            ReplaceVATDateReq := false;
            PrintDocReq := false;
            PrintDocVisible := SalesReceivablesSetup."Post & Print with Job Queue";
            VATDateVisible := VATReportingDateMgt.IsVATDateEnabled();
        end;
    }

    var
        ExchRateNotApplyMsg: Label 'The exchange rate associated with the new posting date on the sales header will apply to the sales lines.';
        CalcInvDiscReq: Boolean;
        EnterVATDateErr: Label 'Enter the VAT date.';
        ReplacePostingDateReq: Boolean;
        ReplaceDocumentDateReq: Boolean;
        ReplaceVATDateReq: Boolean;
        VATDateVisible: Boolean;
        PostingDateReq: Date;
        PrintDocReq: Boolean;
        PrintDocVisible: Boolean;
        VATDateReq: Date;
}
#endif