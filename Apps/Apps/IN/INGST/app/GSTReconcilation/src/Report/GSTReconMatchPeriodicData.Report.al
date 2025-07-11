// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

report 18280 "GST Recon. Match Periodic Data"
{
    Caption = 'GST Recon. Match Periodic Data';
    ProcessingOnly = true;

    dataset
    {
        dataitem("GST Reconcilation Lines"; "GST Reconcilation Line")
        {
            dataitem("Periodic GSTR-2A Data"; "Periodic GSTR-2A Data")
            {
                DataItemLink = "GSTIN No." = field("GSTIN No."),
                               Month = field(Month),
                               Year = field(Year);

                trigger OnAfterGetRecord()
                begin
                    "GST Reconcilation Lines"."Error Type" := '';
                    "GST Reconcilation Lines".Modify(true);
                    if Matched <> Matched::"Rec Matched" then
                        if (not "GST Reconcilation Lines".Reconciled) and
                            (Matched = Matched::" ") or
                            (Matched = Matched::"No Line")
                        then begin
                            if "Document No." <> "GST Reconcilation Lines"."External Document No." then
                                "GST Reconcilation Lines"."Error Type" := ExtDocNoTxt
                            else
                                if "GSTIN of Supplier" <> "GST Reconcilation Lines"."GSTIN of Supplier" then
                                    "GST Reconcilation Lines"."Error Type" := VendorGSTRegNoTxt
                                else
                                    if "Document Date" <> "GST Reconcilation Lines"."Document Date" then
                                        "GST Reconcilation Lines"."Error Type" := VendorInvDateTxt
                                    else
                                        if GSTReconcilationMatch.ValidateCompAmtWithPeriodicData(
                                            "GST Reconcilation Lines",
                                            "Periodic GSTR-2A Data")
                                        then
                                            "GST Reconcilation Lines".Reconciled := true;
                            "GST Reconcilation Lines".Modify(true);

                            if "GST Reconcilation Lines".Reconciled then
                                Matched := Matched::"Rec Matched"
                            else
                                if "GST Reconcilation Lines"."Error Type" = ExtDocNoTxt then
                                    Matched := Matched::"No Line"
                                else
                                    if "GST Reconcilation Lines"."Error Type" <> '' then
                                        Matched := Matched::"Error Found";
                            Modify(true);

                            if Matched IN [Matched::"Error Found", Matched::"Rec Matched"] then
                                CurrReport.BREAK();
                        end;
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter(Matched, '<>%1', Matched::"Rec Matched");
                end;
            }
        }
    }

    var
        GSTReconcilationMatch: Codeunit "GST Reconcilation Match";
        ExtDocNoTxt: Label 'External Document No is not Matching with GSTR-2A Data.';
        VendorGSTRegNoTxt: Label 'Vendor GST Registration No. is not matching with GSTR-2A data.';
        VendorInvDateTxt: Label 'Vendor Invoice Date is not matching with GSTR-2A data.';
}
