// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using Microsoft.Sales.Customer;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Sales.Receivables;

page 18663 "Update TDS Certificate Details"
{
    Caption = 'Update TDS Certificate Details';
    PageType = Card;
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            field(CustomerNo; CustomerNo)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer No.';
                TableRelation = Customer;
                ToolTip = 'Specify the customer number from whom TDS certificate is received.';
            }
            field(CertificateNo; CertificateNo)
            {
                Caption = 'Certificate No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the certificate number as per the certificate received.';
            }
            field(CertificateDate; CertificateDate)
            {
                Caption = 'Date of Receipt';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the date on which certificate was received.';
            }
            field(CertificateAmount; CertificateAmount)
            {
                Caption = 'Certificate TDS  Amount';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the TDS certificate amount as per the TDS certificate.';
                MinValue = 0;
            }
            field(FinancialYear; FinancialYear)
            {
                Caption = 'Financial Year';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the financial year for which TDS certificate has been received.';

                trigger OnValidate()
                var
                    FinYearErr: Label '%1 is not a valid Financial year.', Comment = '%1= Financial Year';
                begin
                    if FinancialYear <= 0 then
                        Error(FinYearErr, FinancialYear);
                end;
            }
            field(TDSSection; TDSSection)
            {
                Caption = 'TDS Section Code';
                ApplicationArea = Basic, Suite;
                TableRelation = "TDS Section";
                ToolTip = 'Choose the TDS section code from the lookup list for which TDS certificate has been received.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Assign TDS Cert. Details")
            {
                Caption = 'Assign TDS Cert. Details';
                ToolTip = 'Select to open the Assign TDS Cert. Details page.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = Basic, Suite;
                Image = Apply;

                trigger OnAction()
                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    AssignTDSCertDetails: Page "Assign TDS Cert. Details";
                begin
                    CustLedgerEntry.Reset();
                    CustLedgerEntry.SetRange("Customer No.", CustomerNo);
                    AssignTDSCertDetails.SetTableView(CustLedgerEntry);
                    AssignTDSCertDetails.Run();
                end;
            }
            action("Update TDS Cert. Details")
            {
                Caption = 'Update TDS Cert. Details';
                ToolTip = 'Select to open the Update TDS Cert. Details page.';
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Image = Change;

                trigger OnAction()
                var
                    TDSCertificateEntries: Page "Update TDS Cert. Details";
                begin
                    if CustomerNo = '' then
                        Error(CustomerNoEmptyErr);
                    if CertificateNo = '' then
                        Error(CertificateNoEmptyErr);
                    if CertificateDate = 0D then
                        Error(DateofReceiptEmptyErr);
                    if CertificateAmount <= 0 then
                        Error(CertificateAmuntEmptyErr);
                    if FinancialYear = 0 then
                        Error(FinancialYearEmptyErr);
                    if TDSSection = '' then
                        Error(TDSSectionEmptyErr);

                    TDSCertificateEntries.SetCertificateDetail(CertificateNo, CertificateDate, CustomerNo, CertificateAmount, FinancialYear,
                      TDSSection);
                    TDSCertificateEntries.Run();
                end;
            }
            action("Rectify TDS Cert. Details")
            {
                Caption = 'Rectify TDS Cert. Details';
                ToolTip = 'Select to open the Rectify TDS Cert. Details page.';
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Image = Change;

                trigger OnAction()
                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    RectifyTDSCertDetails: Page "Rectify TDS Cert. Details";
                begin
                    CustLedgerEntry.Reset();
                    CustLedgerEntry.FilterGroup(2);
                    CustLedgerEntry.SetRange("Customer No.", CustomerNo);
                    CustLedgerEntry.FilterGroup(0);
                    RectifyTDSCertDetails.SetTableView(CustLedgerEntry);
                    RectifyTDSCertDetails.Run();
                end;
            }
        }
    }

    var
        CustomerNo: Code[20];
        CertificateNo: Code[20];
        CertificateDate: Date;
        CertificateAmount: Decimal;
        FinancialYear: Integer;
        TDSSection: Code[10];
        CustomerNoEmptyErr: Label 'Please enter Customer No.';
        CertificateNoEmptyErr: Label 'Please enter Certificate No.';
        DateofReceiptEmptyErr: Label 'Please enter Date of Receipt.';
        CertificateAmuntEmptyErr: Label 'Please enter TDS Certificate Amount.';
        FinancialYearEmptyErr: Label 'Please enter Financial Year.';
        TDSSectionEmptyErr: Label 'Please enter TDS Section Code.';
}
