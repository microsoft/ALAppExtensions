// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using Microsoft.Sales.Receivables;

page 18664 "Update TDS Cert. Details"
{
    Caption = 'Update TDS Cert. Details';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Cust. Ledger Entry";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, when the entry was created.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the customer number from whom TDS certificate is received.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the posting date of the customer ledger entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document of the customer ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the customer ledger entry.';
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the customer ledger entry.';
                }
                field("Financial Year"; Rec."Financial Year")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the financial year for which TDS certificate has been received.';
                }
                field("TDS Certificate Receivable"; Rec."TDS Certificate Receivable")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the financial year for which TDS certificate has been received.';
                }
                field("TDS Certificate Received"; Rec."TDS Certificate Received")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Mark in this field specify the same entry in the Rectify TDS Cert. Details window.';

                    trigger OnValidate()
                    begin
                        if Rec."TDS Certificate Received" then
                            Rec.Mark := true
                        else
                            Rec.Mark := false;
                    end;
                }
                field("TDS Section Code"; Rec."TDS Section Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Choose the TDS section code from the lookup list for which TDS certificate has been received.';
                }
                field("Certificate No."; Rec."Certificate No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the certificate number as per the certificate received.';
                }
                field("TDS Certificate Rcpt Date"; Rec."TDS Certificate Rcpt Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which TDS certificate has been received.';
                }
                field("TDS Certificate Amount"; Rec."TDS Certificate Amount")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the TDS certificate amount as per the TDS certificate.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update TDS Cert. Details")
            {
                Caption = 'Update TDS Cert. Details';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Select to open the Update TDS Cert. Details page.';
                Image = RefreshVATExemption;

                trigger OnAction()
                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                begin
                    if Rec.FindSet() then
                        repeat
                            if Rec."TDS Certificate Received" then begin
                                CustLedgerEntry.Reset();
                                CustLedgerEntry.SetCurrentKey("Customer No.", "TDS Section Code", "Certificate No.", "TDS Certificate Received");
                                CustLedgerEntry.SetRange("Customer No.", CustomerNo);
                                CustLedgerEntry.SetRange("Certificate No.", CertificateNo);
                                if CustLedgerEntry.FindFirst() then
                                    if (CustLedgerEntry."TDS Certificate Rcpt Date" <> CertificateDate) or (CustLedgerEntry."TDS Certificate Amount" <> CertificateAmount) or
                                       (CustLedgerEntry."Financial Year" <> FinancialYear) or (CustLedgerEntry."TDS Section Code" <> TDSSectionCode)
                                    then
                                        Error(CertificateDetailErr, CertificateNo);

                                CustLedgerEntry.Reset();
                                CustLedgerEntry.Get(Rec."Entry No.");
                                CustLedgerEntry."Certificate No." := CertificateNo;
                                CustLedgerEntry."TDS Certificate Rcpt Date" := CertificateDate;
                                CustLedgerEntry."TDS Certificate Amount" := CertificateAmount;
                                CustLedgerEntry."Financial Year" := FinancialYear;
                                CustLedgerEntry."TDS Section Code" := TDSSectionCode;
                                CustLedgerEntry."Certificate Received" := true;
                                CustLedgerEntry.Modify()
                            end;
                        until Rec.Next() = 0;
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetCurrentKey("Customer No.", "TDS Section Code", "Certificate No.", "TDS Certificate Received");
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetFilter("Certificate No.", '%1', '');
        CustLedgerEntry.SetRange("TDS Certificate Received", true);
        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry."TDS Certificate Received" := false;
                CustLedgerEntry."Certificate Received" := false;
                CustLedgerEntry.Modify();
            until (CustLedgerEntry.Next() = 0);
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Customer No.", CustomerNo);
        Rec.SetRange("TDS Certificate Receivable", true);
        Rec.SetRange("Certificate Received", false);
        Rec.FilterGroup(0);
    end;

    var
        CertificateNo: Code[20];
        CertificateDate: Date;
        CustomerNo: Code[20];
        CertificateAmount: Decimal;
        FinancialYear: Integer;
        TDSSectionCode: Code[10];
        CertificateDetailErr: Label 'Certificate Details for Certificate No. %1 should be same as entered earlier.', Comment = '%1 = Certificate No.';

    procedure SetCertificateDetail(
        NewCertificateNo: Code[20];
        NewCertificateDate: Date;
        NewCustomerNo: Code[20];
        NewCertificateAmount: Decimal;
        NewFinancialYear: Integer;
        NewTDSSectionCode: Code[10])
    begin
        CertificateNo := NewCertificateNo;
        CertificateDate := NewCertificateDate;
        CustomerNo := NewCustomerNo;
        CertificateAmount := NewCertificateAmount;
        FinancialYear := NewFinancialYear;
        TDSSectionCode := NewTDSSectionCode;
    end;
}
