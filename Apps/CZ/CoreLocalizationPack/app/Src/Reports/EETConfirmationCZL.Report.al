// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;

report 31121 "EET Confirmation CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/EETConfirmation.rdl';
    Caption = 'EET Confirmation';

    dataset
    {
        dataitem(EETEntryCZL; "EET Entry CZL")
        {
            column(EntryNo_EETEntry; EETEntryCZL."Entry No.")
            {
            }
            column(CompanyName_EETEntry; CompanyInformation.Name)
            {
            }
            column(VATRegNo_EETEntry; CompanyInformation."VAT Registration No.")
            {
            }
            column(RegNo_EETEntry; CompanyInformation."Registration No.")
            {
            }
            column(CompanyAddr1_EETEntry; CompanyAddr[1])
            {
            }
            column(CompanyAddr2_EETEntry; CompanyAddr[2])
            {
            }
            column(CompanyAddr3_EETEntry; CompanyAddr[3])
            {
            }
            column(CompanyAddr4_EETEntry; CompanyAddr[4])
            {
            }
            column(CompanyAddr5_EETEntry; CompanyAddr[5])
            {
            }
            column(SalesRegime_EETEntry; Format(EETEntryCZL."Sales Regime"))
            {
            }
            column(ReceiptSerialNo_EETEntry; "Receipt Serial No.")
            {
            }
            column(DocumentNo_EETEntry; "Document No.")
            {
            }
            column(Description_EETEntry; Description)
            {
            }
            column(TotalSalesAmount_EETEntry; "Total Sales Amount")
            {
            }
            column(SecurityCodeBKP_EETEntry; "Taxpayer's Security Code")
            {
            }
            column(FiscalIdentificationCode_EETEntry; "Fiscal Identification Code")
            {
            }
            column(CreationDatetime_EETEntry; "Created At")
            {
            }
            column(CashRegisterCode_EETEntry; "Cash Register Code")
            {
            }
            column(BusinessPremissesId_EETEntry; GetBusinessPremisesId())
            {
            }
            column(SalesRegimeText_EETEntry; GetSalesRegimeText())
            {
            }
            column(SignatureCodePKP_EETEntry; GetSignatureCode())
            {
            }
        }
    }

    labels
    {
        TotalLbl = 'Total:';
        BusPremisesLbl = 'Business Premises:';
        CashRegisterLbl = 'Cash Register:';
        ReceiptSerialNoLbl = 'Receipt Serial No.:';
        BKPLbl = 'BKP:';
        FIKLbl = 'FIK:';
        PKPLbl = 'PKP:';
        IssueDatetimeLbl = 'Issue Datetime:';
        TotalSalesAmountLbl = 'Total Sales Amount:';
        SalesRegimeLbl = 'EET regime:';
        VATRegNoLbl = 'VAT Reg. No.:';
        RegNoLbl = 'Reg. No.:';
        DocumentNoLbl = 'Document No.:';
        DescriptionLbl = 'Description:';
    }

    trigger OnPreReport()
    begin
        Clear(CompanyAddr);
        CompanyInformation.Get();
        FormatAddress.Company(CompanyAddr, CompanyInformation);
    end;

    var
        CompanyInformation: Record "Company Information";
        FormatAddress: Codeunit "Format Address";
        CompanyAddr: array[8] of Text[100];
}

