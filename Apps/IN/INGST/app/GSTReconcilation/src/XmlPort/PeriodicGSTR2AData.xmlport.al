// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

xmlport 18280 "Periodic GSTR-2A Data"
{
    Caption = 'Periodic GSTR-2A Data';
    Direction = Both;
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Periodic GSTR-2A Data"; "Periodic GSTR-2A Data")
            {
                AutoSave = false;
                XmlName = 'GSTR2AData';

                fieldelement(GSTIN; "Periodic GSTR-2A Data"."GSTIN No.")
                {
                }
                fieldelement(State; "Periodic GSTR-2A Data"."State Code")
                {
                }
                fieldelement(Month; "Periodic GSTR-2A Data".Month)
                {
                }
                fieldelement(Year; "Periodic GSTR-2A Data".Year)
                {
                }
                fieldelement(DocumentTypeLike; "Periodic GSTR-2A Data"."Document Type")
                {
                }
                fieldelement(GSTINOfSupplier; "Periodic GSTR-2A Data"."GSTIN of Supplier")
                {
                }
                fieldelement(DocumentNo; "Periodic GSTR-2A Data"."Document No.")
                {
                }
                fieldelement(DocumentDate; "Periodic GSTR-2A Data"."Document Date")
                {
                }
                fieldelement(TaxableValue; "Periodic GSTR-2A Data"."Taxable Value")
                {
                }
                fieldelement(CompAmt1; "Periodic GSTR-2A Data"."Component 1 Amount")
                {
                }
                fieldelement(CompAmt2; "Periodic GSTR-2A Data"."Component 2 Amount")
                {
                }
                fieldelement(CompAmt3; "Periodic GSTR-2A Data"."Component 3 Amount")
                {
                }
                fieldelement(CompAmt4; "Periodic GSTR-2A Data"."Component 4 Amount")
                {
                }
                fieldelement(CompAmt5; "Periodic GSTR-2A Data"."Component 5 Amount")
                {
                }
                fieldelement(CompAmt6; "Periodic GSTR-2A Data"."Component 6 Amount")
                {
                }
                fieldelement(CompAmt7; "Periodic GSTR-2A Data"."Component 7 Amount")
                {
                }
                fieldelement(CompAmt8; "Periodic GSTR-2A Data"."Component 8 Amount")
                {
                }
                fieldelement(POS; "Periodic GSTR-2A Data".POS)
                {
                    MinOccurs = Zero;
                }
                fieldelement(RevisedGSTINofSupplier; "Periodic GSTR-2A Data"."Revised GSTIN of Supplier")
                {
                    MinOccurs = Zero;
                }
                fieldelement(RevisedDocumentNo; "Periodic GSTR-2A Data"."Revised Document No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(RevisedDocumentDate; "Periodic GSTR-2A Data"."Revised Document Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(RevisedDocumentValue; "Periodic GSTR-2A Data"."Revised Document Value")
                {
                    MinOccurs = Zero;
                }
                fieldelement(RevisedGoodsServicesLike; "Periodic GSTR-2A Data"."Revised Goods/Services")
                {
                    MinOccurs = Zero;
                }
                fieldelement(RevisedHSNSACLike; "Periodic GSTR-2A Data"."Revised HSN/SAC")
                {
                    MinOccurs = Zero;
                }
                fieldelement(RevisedTaxableValue; "Periodic GSTR-2A Data"."Revised Taxable Value")
                {
                    MinOccurs = Zero;
                }
                fieldelement(TypeofNote; "Periodic GSTR-2A Data"."Type of Note")
                {
                    MinOccurs = Zero;
                }
                fieldelement(DebitCreditNoteNo; "Periodic GSTR-2A Data"."Debit/Credit Note No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(DebitCreditNoteDate; "Periodic GSTR-2A Data"."Debit/Credit Note Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(DifferentialValue; "Periodic GSTR-2A Data"."Differential Value")
                {
                    MinOccurs = Zero;
                }
                fieldelement(DateofPaymenttoDeductee; "Periodic GSTR-2A Data"."Date of Payment to Deductee")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ValueonTDShasbeenDeducted; "Periodic GSTR-2A Data"."Value on TDS has been Deducted")
                {
                    MinOccurs = Zero;
                }
                fieldelement(MerchIDallocByecomport; "Periodic GSTR-2A Data"."Merch. ID alloc. By e-com port")
                {
                    MinOccurs = Zero;
                }
                fieldelement(GrossValueofSupplies; "Periodic GSTR-2A Data"."Gross Value of Supplies")
                {
                    MinOccurs = Zero;
                }
                fieldelement(TaxValueonTCShasDeducted; "Periodic GSTR-2A Data"."Tax Value on TCS has Deducted")
                {
                    MinOccurs = Zero;
                }

                trigger OnBeforeInsertRecord()
                var
                    PeriodicGSTR2AData: Record "Periodic GSTR-2A Data";
                    PeriodicGSTR2AData2: Record "Periodic GSTR-2A Data";
                begin
                    PeriodicGSTR2AData.Init();
                    PeriodicGSTR2AData."GSTIN No." := "Periodic GSTR-2A Data"."GSTIN No.";
                    PeriodicGSTR2AData."State Code" := "Periodic GSTR-2A Data"."State Code";
                    PeriodicGSTR2AData.Month := "Periodic GSTR-2A Data".Month;
                    PeriodicGSTR2AData.Year := "Periodic GSTR-2A Data".Year;
                    PeriodicGSTR2AData."Document Type" := "Periodic GSTR-2A Data"."Document Type";
                    PeriodicGSTR2AData."GSTIN of Supplier" := "Periodic GSTR-2A Data"."GSTIN of Supplier";
                    PeriodicGSTR2AData."Document No." := "Periodic GSTR-2A Data"."Document No.";
                    PeriodicGSTR2AData."Document Date" := "Periodic GSTR-2A Data"."Document Date";
                    PeriodicGSTR2AData."Taxable Value" := "Periodic GSTR-2A Data"."Taxable Value";
                    PeriodicGSTR2AData."Component 1 Amount" := "Periodic GSTR-2A Data"."Component 1 Amount";
                    PeriodicGSTR2AData."Component 2 Amount" := "Periodic GSTR-2A Data"."Component 2 Amount";
                    PeriodicGSTR2AData."Component 3 Amount" := "Periodic GSTR-2A Data"."Component 3 Amount";
                    PeriodicGSTR2AData."Component 4 Amount" := "Periodic GSTR-2A Data"."Component 4 Amount";
                    PeriodicGSTR2AData."Component 5 Amount" := "Periodic GSTR-2A Data"."Component 5 Amount";
                    PeriodicGSTR2AData."Component 6 Amount" := "Periodic GSTR-2A Data"."Component 6 Amount";
                    PeriodicGSTR2AData."Component 7 Amount" := "Periodic GSTR-2A Data"."Component 7 Amount";
                    PeriodicGSTR2AData."Component 8 Amount" := "Periodic GSTR-2A Data"."Component 8 Amount";
                    PeriodicGSTR2AData.POS := "Periodic GSTR-2A Data".POS;
                    PeriodicGSTR2AData."Revised GSTIN of Supplier" := "Periodic GSTR-2A Data"."Revised GSTIN of Supplier";
                    PeriodicGSTR2AData."Revised Document No." := "Periodic GSTR-2A Data"."Revised Document No.";
                    PeriodicGSTR2AData."Revised Document Date" := "Periodic GSTR-2A Data"."Revised Document Date";
                    PeriodicGSTR2AData."Revised Document Value" := "Periodic GSTR-2A Data"."Revised Document Value";
                    PeriodicGSTR2AData."Revised Goods/Services" := "Periodic GSTR-2A Data"."Revised Goods/Services";
                    PeriodicGSTR2AData."Revised HSN/SAC" := "Periodic GSTR-2A Data"."Revised HSN/SAC";
                    PeriodicGSTR2AData."Revised Taxable Value" := "Periodic GSTR-2A Data"."Revised Taxable Value";
                    PeriodicGSTR2AData."Type of Note" := "Periodic GSTR-2A Data"."Type of Note";
                    PeriodicGSTR2AData."Debit/Credit Note No." := "Periodic GSTR-2A Data"."Debit/Credit Note No.";
                    PeriodicGSTR2AData."Debit/Credit Note Date" := "Periodic GSTR-2A Data"."Debit/Credit Note Date";
                    PeriodicGSTR2AData."Differential Value" := "Periodic GSTR-2A Data"."Differential Value";
                    PeriodicGSTR2AData."Date of Payment to Deductee" := "Periodic GSTR-2A Data"."Date of Payment to Deductee";
                    PeriodicGSTR2AData."Value on TDS has been Deducted" := "Periodic GSTR-2A Data"."Value on TDS has been Deducted";
                    PeriodicGSTR2AData."Merch. ID alloc. By e-com port" := "Periodic GSTR-2A Data"."Merch. ID alloc. By e-com port";
                    PeriodicGSTR2AData."Gross Value of Supplies" := "Periodic GSTR-2A Data"."Gross Value of Supplies";
                    PeriodicGSTR2AData."Tax Value on TCS has Deducted" := "Periodic GSTR-2A Data"."Tax Value on TCS has Deducted";

                    PeriodicGSTR2AData2.Reset();
                    PeriodicGSTR2AData2.SetRange("Document No.", "Periodic GSTR-2A Data"."Document No.");
                    if PeriodicGSTR2AData2.FindFirst() then begin
                        PeriodicGSTR2AData2."Taxable Value" += "Periodic GSTR-2A Data"."Taxable Value";
                        PeriodicGSTR2AData2."Component 1 Amount" += "Periodic GSTR-2A Data"."Component 1 Amount";
                        PeriodicGSTR2AData2."Component 2 Amount" += "Periodic GSTR-2A Data"."Component 2 Amount";
                        PeriodicGSTR2AData2."Component 3 Amount" += "Periodic GSTR-2A Data"."Component 3 Amount";
                        PeriodicGSTR2AData2."Component 4 Amount" += "Periodic GSTR-2A Data"."Component 4 Amount";
                        PeriodicGSTR2AData2."Component 5 Amount" += "Periodic GSTR-2A Data"."Component 5 Amount";
                        PeriodicGSTR2AData2."Component 6 Amount" += "Periodic GSTR-2A Data"."Component 6 Amount";
                        PeriodicGSTR2AData2."Component 7 Amount" += "Periodic GSTR-2A Data"."Component 7 Amount";
                        PeriodicGSTR2AData2."Component 8 Amount" += "Periodic GSTR-2A Data"."Component 8 Amount";
                        PeriodicGSTR2AData2.Modify();
                    end else
                        PeriodicGSTR2AData.Insert();
                end;
            }
        }
    }

    trigger OnPostXmlPort()
    begin
        Message(SuccessMsg);
    end;

    trigger OnPreXmlPort()
    begin
        PeriodicGSTR2AData.DeleteAll();
    end;

    var
        PeriodicGSTR2AData: Record "Periodic GSTR-2A Data";
        SuccessMsg: Label 'File has been imported successfully.';
}

