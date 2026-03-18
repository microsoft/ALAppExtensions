// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Vendor;

xmlport 147659 "SL Vendor Posting Group Data"
{
    Caption = 'Vendor Posting Group data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Vendor Posting Group"; "Vendor Posting Group")
            {
                AutoSave = false;
                XmlName = 'BCVendorPostingGroup';

                textelement(Code)
                {
                }
                textelement(PayablesAccount)
                {
                }
                textelement(ServiceChargeAcc)
                {
                }
                textelement(PaymentDiscDebitAcc)
                {
                }
                textelement(InvoiceRoundingAccount)
                {
                }
                textelement(DebitCurrApplnRndgAcc)
                {
                }
                textelement(CreditCurrApplnRndgAcc)
                {
                }
                textelement(DebitRoundingAccount)
                {
                }
                textelement(CreditRoundingAccount)
                {
                }
                textelement(PaymentDiscCreditAcc)
                {
                }
                textelement(PaymentToleranceDebitAcc)
                {
                }
                textelement(PaymentToleranceCreditAcc)
                {
                }
                textelement(Description)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    VendorPostingGroup: Record "Vendor Posting Group";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    VendorPostingGroup.Code := Code;
                    VendorPostingGroup."Payables Account" := PayablesAccount;
                    VendorPostingGroup."Service Charge Acc." := ServiceChargeAcc;
                    VendorPostingGroup."Payment Disc. Debit Acc." := PaymentDiscDebitAcc;
                    VendorPostingGroup."Invoice Rounding Account" := InvoiceRoundingAccount;
                    VendorPostingGroup."Debit Curr. Appln. Rndg. Acc." := DebitCurrApplnRndgAcc;
                    VendorPostingGroup."Credit Curr. Appln. Rndg. Acc." := CreditCurrApplnRndgAcc;
                    VendorPostingGroup."Debit Rounding Account" := DebitRoundingAccount;
                    VendorPostingGroup."Credit Rounding Account" := CreditRoundingAccount;
                    VendorPostingGroup."Payment Disc. Credit Acc." := PaymentDiscCreditAcc;
                    VendorPostingGroup."Payment Tolerance Debit Acc." := PaymentToleranceDebitAcc;
                    VendorPostingGroup."Payment Tolerance Credit Acc." := PaymentToleranceCreditAcc;
                    VendorPostingGroup.Description := Description;
                    VendorPostingGroup.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        VendorPostingGroup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        VendorPostingGroup: Record "Vendor Posting Group";
}
