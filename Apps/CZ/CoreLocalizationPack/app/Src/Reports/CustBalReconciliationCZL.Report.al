// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Customer;
using System.Globalization;
using System.Utilities;

report 11723 "Cust.- Bal. Reconciliation CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CustBalReconciliation.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Customer - Bal. Reconciliation';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Print Statements", Blocked;
            column(CustomerName; Name)
            {
            }
            column(WORKDATE; Format(WorkDate()))
            {
            }
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(CustomerAddress; Address)
            {
            }
            column(CustomerCity; City)
            {
            }
            column(CustomerPostCode; "Post Code")
            {
            }
            column(CompanyInfoAddress; CompanyInformation.Address)
            {
            }
            column(CompanyInfoCity; CompanyInformation.City)
            {
            }
            column(CompanyInfoPostCode; CompanyInformation."Post Code")
            {
            }
            column(CustomerPhoneNo; "Phone No.")
            {
            }
            column(CompanyInfoPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CustomerFaxNo; "Fax No.")
            {
            }
            column(CompanyInfoFaxNo; CompanyInformation."Fax No.")
            {
            }
            column(CustomerEMail; "E-Mail")
            {
            }
            column(CompanyInfoEMail; CompanyInformation."E-Mail")
            {
            }
            column(CustomerVATRegistrationNo; "VAT Registration No.")
            {
            }
            column(CompanyInfoVATRegistrationNo; CompanyInformation."VAT Registration No.")
            {
            }
            column(CustomerRegistrationNo; "Registration Number")
            {
            }
            column(CompanyInfoRegistrationNo; CompanyInformation."Registration No.")
            {
            }
            column(CustomerTaxRegistrationNo; "Tax Registration No. CZL")
            {
            }
            column(CompanyInfoTaxRegistrationNo; CompanyInformation."Tax Registration No. CZL")
            {
            }
            column(CurrReportPAGENOCaption; CurrReportPAGENOCaptionLbl)
            {
            }
            column(CustomerPhoneNoCaption; FieldCaption("Phone No."))
            {
            }
            column(CompanyInfoPhoneNoCaption; CompanyInfoPhoneNoCaptionLbl)
            {
            }
            column(CustomerFaxNoCaption; FieldCaption("Fax No."))
            {
            }
            column(CompanyInfoFaxNoCaption; CompanyInfoFaxNoCaptionLbl)
            {
            }
            column(CompanyInfoEMailCaption; CompanyInfoEMailCaptionLbl)
            {
            }
            column(CustomerVATRegistrationNoCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(CompanyInfoVATRegistrationNoCaption; CompanyInfoVATRegistrationNoCaptionLbl)
            {
            }
            column(InaccordancewithdataofCaption; InaccordancewithdataofCaptionLbl)
            {
            }
            column(DebitCaption; DebitCaptionLbl)
            {
            }
            column(CreditCaption; CreditCaptionLbl)
            {
            }
            column(CustomerRegistrationNoCaption; FieldCaption("Registration Number"))
            {
            }
            column(CompanyInfoRegistrationNoCaption; CompanyInfoRegistrationNoCaptionLbl)
            {
            }
            column(CustomerTaxRegistrationNoCaption; FieldCaption("Tax Registration No. CZL"))
            {
            }
            column(CompanyInfoTaxRegistrationNoCaption; CompanyInfoTaxRegistrationNoCaptionLbl)
            {
            }
            column(CustomerTotalAmountLCY; TotalAmountLCY)
            {
            }
            column(DoNotPrintDetails; (TotalAmountLCY = 0) and TempCVLedgerEntryBuffer.IsEmpty() or (not PrintDetails))
            {
            }
            column(CustomerNo; "No.")
            {
            }
            column(CustomerCaptionLabel; CustomerCaptionTxt)
            {
            }
            column(VendorCaptionLabel; VendorCaptionTxt)
            {
            }
            column(SubjectText; StrSubstNo(SubjectTxt, Format(ReconcileDate)))
            {
            }
            column(HeaderText1; Header1Txt)
            {
            }
            column(HeaderText2; StrSubstNo(Header2Txt, Format(ReconcileDate)))
            {
            }
            column(ConfirmationText1; StrSubstNo(Confirmation1Txt, Format(ReturnDate)))
            {
            }
            column(CityAndDate; StrSubstNo(CityOnDateTxt, CompanyInformation.City, Format(ReconcileDate)))
            {
            }
            column(ConfirmationText2; StrSubstNo(Confirmation2Txt, Format(ReconcileDate)))
            {
            }
            column(AppendixText; AppendixTxt)
            {
            }
            column(ForCompany; StrSubstNo(ForCompanyTxt, CompanyInformation.Name))
            {
            }
            column(ForCompanyConfirms; StrSubstNo(ForCompanyConfirmsTxt, Customer.Name))
            {
            }
            column(AndLabel; andCaptionLbl)
            {
            }
            column(AppendixHeaderText; StrSubstNo(AppendixHeaderTxt, Format(ReconcileDate)))
            {
            }
            column(ResponsibleEmployee; ResponsibleEmployee)
            {
            }
            dataitem(TotalInCurrency; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(DebitAmount; DebitAmount)
                {
                }
                column(CreditAmount; CreditAmount)
                {
                }
                column(FinalBalanceAmount; StrSubstNo(FinalBalanceAmountTxt, GetCurrencyCode(TempCurrency.Code)))
                {
                }
                column(TotalInCurrencyNumber; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempCurrency.FindSet()
                    else
                        TempCurrency.Next();

                    if PrintAmountsInCurrency then begin
                        TotalAmount := CustomerVendorBalanceCZL.CalcCustomerVendorBalance(Customer."No.", VendorNo, TempCurrency.Code, ReconcileDate, false);
                        CalcDebitCredit(TotalAmount);
                    end else
                        CalcDebitCredit(TotalAmountLCY);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, TempCurrency.Count());
                end;
            }
            dataitem(Footer; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(NameCaption; NameCaptionLbl)
                {
                }
                column(SignatureCaption; SignatureCaptionLbl)
                {
                }
                column(SignatureStampCaption; SignatureStampCaptionLbl)
                {
                }
                column(FooterNumber; Number)
                {
                }
            }
            dataitem(Currencies; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(OpenDocumentsCaption; StrSubstNo(OpenDocumentsTxt, GetCurrencyCode(TempCurrency.Code)))
                {
                }
                column(AmountCaption; AmountCaptionLbl)
                {
                }
                column(CurrencyCodeCaption; CurrencyCodeCaptionLbl)
                {
                }
                column(DocumentNoCaption; DocumentNoCaptionLbl)
                {
                }
                column(DocumentTypeCaption; DocumentTypeCaptionLbl)
                {
                }
                column(DocumentDateCaption; DocumentDateCaptionLbl)
                {
                }
                column(RemainingAmountCaption; RemainingAmountCaptionLbl)
                {
                }
                column(DueDateCaption; DueDateCaptionLbl)
                {
                }
                column(RemainingAmtLCYCaption; StrSubstNo(RemainingAmtLCYLbl, GeneralLedgerSetup."LCY Code"))
                {
                }
                column(CurrenciesNumber; Number)
                {
                }
                dataitem(CVLedgEntryBuf; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                    column(CVLedgEntryDocumentDate; Format(TempCVLedgerEntryBuffer."Document Date"))
                    {
                    }
                    column(FORMATCVLedgEntryDocumentType; Format(TempCVLedgerEntryBuffer."Document Type"))
                    {
                    }
                    column(CVLedgEntryCurrencyCode; TempCVLedgerEntryBuffer."Currency Code")
                    {
                    }
                    column(CVLedgEntryDueDate; Format(TempCVLedgerEntryBuffer."Due Date"))
                    {
                    }
                    column(CVLedgEntryAmount; TempCVLedgerEntryBuffer.Amount)
                    {
                    }
                    column(CVLedgEntryRemainingAmount; TempCVLedgerEntryBuffer."Remaining Amount")
                    {
                    }
                    column(CVLedgEntryRemainingAmtLCY; TempCVLedgerEntryBuffer."Remaining Amt. (LCY)")
                    {
                    }
                    column(CVLedgEntryDocumentNo; TempCVLedgerEntryBuffer."Document No.")
                    {
                    }
                    column(CVLedgEntryBufNumber; Number)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempCVLedgerEntryBuffer.Findset()
                        else
                            TempCVLedgerEntryBuffer.Next();
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempCVLedgerEntryBuffer.SetCurrentKey("Document Date");
                        if PrintAmountsInCurrency then
                            TempCVLedgerEntryBuffer.SetRange("Currency Code", TempCurrency.Code);

                        SetRange(Number, 1, TempCVLedgerEntryBuffer.Count());
                    end;
                }
                dataitem(Total; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(TotalCaption; StrSubstNo(TotalTxt, GetCurrencyCode(TempCurrency.Code)))
                    {
                    }
                    column(TotalAmount; TotalAmount)
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        if not PrintAmountsInCurrency or LCYEntriesOnly then
                            CurrReport.Break();
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempCurrency.Findset()
                    else
                        TempCurrency.Next();

                    LCYEntriesOnly := (TempCurrency.Code = '') and (TempCurrency.Count() = 1);
                    if PrintAmountsInCurrency then begin
                        TotalAmount := CustomerVendorBalanceCZL.CalcCustomerVendorBalance(Customer."No.", VendorNo, TempCurrency.Code, ReconcileDate, false);
                        if PrintAmountsInCurrency then
                            TempCVLedgerEntryBuffer.SetRange("Currency Code", TempCurrency.Code);
                        if (TotalAmount = 0) and TempCVLedgerEntryBuffer.IsEmpty() then
                            CurrReport.Skip();
                    end else
                        TotalAmount := TotalAmountLCY;
                end;

                trigger OnPreDataItem()
                begin
                    if (TotalAmountLCY = 0) and TempCVLedgerEntryBuffer.IsEmpty() or (not PrintDetails) then
                        CurrReport.Break();

                    SetRange(Number, 1, TempCurrency.Count());
                end;
            }
            dataitem(TotalLCY; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(TotalLCYCaption; StrSubstNo(TotalTxt, GeneralLedgerSetup."LCY Code"))
                {
                }
                column(TotalAmountLCY; TotalAmountLCY)
                {
                }
                column(TotalLCYNumber; Number)
                {
                }
                trigger OnPreDataItem()
                begin
                    TempCVLedgerEntryBuffer.Reset();
                    if (TotalAmountLCY = 0) and TempCVLedgerEntryBuffer.IsEmpty() or (not PrintDetails) then
                        CurrReport.Break();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                if not CurrReport.Preview() then begin
                    LockTable();
                    Find();
                    "Last Statement No." += 1;
                    Modify();
                    Commit();
                end else
                    "Last Statement No." += 1;

                if IncludeVendBalance then
                    VendorNo := GetLinkedVendorCZL()
                else
                    VendorNo := '';

                TotalAmountLCY := CustomerVendorBalanceCZL.CalcCustomerVendorBalance("No.", VendorNo, '', ReconcileDate, true);
                if PrintOnlyNotZero and (TotalAmountLCY = 0) then
                    CurrReport.Skip();

                CalcDebitCredit(TotalAmountLCY);
                CustomerVendorBalanceCZL.FillCustomerVendorBuffer(TempCurrency, TempCVLedgerEntryBuffer,
                                                                "No.", VendorNo, ReconcileDate, PrintAmountsInCurrency);
                ResponsibleEmployee := GetFormattedResponsibleEmployee();
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
                    field(ReturnDateField; ReturnDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Return Date';
                        ToolTip = 'Specifies the date that the statement must be returned';
                    }
                    field(ReconcileDateField; ReconcileDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Reconcile Date';
                        ToolTip = 'Specifies reconcile date. This date will be used to calculate balance that is before and equal to the reconcile date';
                    }
                    field(IncludeVendBalanceField; IncludeVendBalance)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Vendor Balance';
                        ToolTip = 'Specifies to indicate that vendor balance must be subtracted from customer balance.';
                    }
                    field(PrintDetailsField; PrintDetails)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Details';
                        ToolTip = 'Specifies to indicate that detailed documents will print.';
                    }
                    field(PrintOnlyNotZeroField; PrintOnlyNotZero)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Only Not Zero';
                        ToolTip = 'Specifies if you want to print reconciliation reports for customers who do not have open entries, or their total amount in LCY is zero.';
                    }
                    field(PrintAmountsInCurrencyField; PrintAmountsInCurrency)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Amounts In Currency';
                        ToolTip = 'Specifies to indicate that the report must show customer balance in the original currency.';
                    }
                    field(EmployeeNoField; EmployeeNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Responsible Employee No.';
                        TableRelation = Employee;
                        ToolTip = 'Specifies which emloyee prints the report';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if ReturnDate = 0D then
            Error(EmptyReturnDateErr);
        if ReconcileDate = 0D then
            Error(EmptyReconcileDateErr);

        GeneralLedgerSetup.Get();
        CompanyInformation.Get();
        StatutoryReportingSetupCZL.Get();
        LongReconcileDate := Format(ReconcileDate);

        if not CompanyOfficialCZL.Get(StatutoryReportingSetupCZL."Accounting Manager No.") then
            CompanyOfficialCZL.Init();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        TempCurrency: Record Currency temporary;
        CompanyOfficialCZL: Record "Company Official CZL";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        Employee: Record Employee;
        LanguageMgt: Codeunit Language;
        CustomerVendorBalanceCZL: Codeunit "Customer Vendor Balance CZL";
        ReturnDate: Date;
        ReconcileDate: Date;
        PrintOnlyNotZero: Boolean;
        PrintAmountsInCurrency: Boolean;
        VendorNo: Code[20];
        LongReconcileDate: Text[30];
        DebitAmount: Decimal;
        CreditAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountLCY: Decimal;
        LCYEntriesOnly: Boolean;
        IncludeVendBalance: Boolean;
        PrintDetails: Boolean;
        EmployeeNo: Code[20];
        ResponsibleEmployee: Text;
        EmptyReturnDateErr: Label 'You must specify Return Date';
        EmptyReconcileDateErr: Label 'You must specify Reconcile Date';
        FinalBalanceAmountTxt: Label 'Final balance amount in %1', Comment = '%1 = Currency Code';
        TotalTxt: Label 'Total %1', Comment = '%1 = Currency Code';
        OpenDocumentsTxt: Label 'Open documents in details %1', Comment = '%1 = Currency Code';
        andCaptionLbl: Label 'and';
        CurrReportPAGENOCaptionLbl: Label 'Page';
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoFaxNoCaptionLbl: Label 'Fax No.';
        CompanyInfoEMailCaptionLbl: Label 'E-Mail';
        CompanyInfoVATRegistrationNoCaptionLbl: Label 'VAT Registration No.';
        InaccordancewithdataofCaptionLbl: Label 'In accordance with data of';
        DebitCaptionLbl: Label 'Debit';
        CreditCaptionLbl: Label 'Credit';
        CompanyInfoRegistrationNoCaptionLbl: Label 'Registration No.';
        CompanyInfoTaxRegistrationNoCaptionLbl: Label 'Tax Registration No.';
        NameCaptionLbl: Label '(Name)';
        SignatureCaptionLbl: Label '(Signature)';
        SignatureStampCaptionLbl: Label '(Signature, Stamp)';
        AmountCaptionLbl: Label 'Amount';
        CurrencyCodeCaptionLbl: Label 'Currency Code';
        DocumentNoCaptionLbl: Label 'Document No.';
        DocumentTypeCaptionLbl: Label 'Document Type';
        DocumentDateCaptionLbl: Label 'Document Date';
        RemainingAmountCaptionLbl: Label 'Remaining Amount';
        DueDateCaptionLbl: Label 'Due Date';
        CustomerCaptionTxt: Label 'Customer';
        VendorCaptionTxt: Label 'Vendor';
        SubjectTxt: Label 'Subject: Receivables reconciliation at %1', Comment = '%1 = Reconcile Date';
        Header1Txt: Label 'In accordance with par. 29 of the Act No. 563/1991 Coll. on Accounting as amended';
        Header2Txt: Label 'We ask you to agree and confirm the status of our receivables on %1', Comment = '%1 = Reconcile Date';
        Confirmation1Txt: Label 'Please confirm your balance to %1. If we do not receive your reply within that period, we will consider receivables status approved.', Comment = '%1 = Return Date';
        CityOnDateTxt: Label '%1 on %2:', Comment = '%1 = City, %2 = Reconcile Date';
        ForCompanyTxt: Label 'For company %1:', Comment = '%1 = Company Name';
        ForCompanyConfirmsTxt: Label 'For company %1 confirms:', Comment = '%1 = Customer Name';
        Confirmation2Txt: Label 'The balanceor acknowledges his obligations on %1 to the creditor as to the reason and amount', Comment = '%1 = Reconcile Date';
        AppendixTxt: Label 'from the documents listed in the appendix, which forms an integral part of this document.';
        AppendixHeaderTxt: Label 'Appendix to the reconciliation of receivables on %1 between', Comment = '%1 = Reconcile Date';
        ResponsibleEmployeeLbl: Label 'Responsible Employee: %1', Comment = '%1 = Employee Full Name';
        RemainingAmtLCYLbl: Label 'Remaining Amt. (%1)', Comment = '%1 = LCY Code';

    protected var
        TempCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary;

    procedure CalcDebitCredit(TotalAmt: Decimal)
    begin
        TotalAmount := TotalAmt;
        if TotalAmount < 0 then begin
            CreditAmount := -TotalAmount;
            DebitAmount := 0;
        end else begin
            CreditAmount := 0;
            DebitAmount := TotalAmount;
        end;
    end;


    procedure GetCurrencyCode("Code": Code[10]): Code[10]
    begin
        if Code = '' then
            exit(GeneralLedgerSetup."LCY Code");
        exit(Code);
    end;

    local procedure GetFormattedResponsibleEmployee(): Text
    var
        FormattedEmployee: Text;
    begin
        if EmployeeNo = '' then
            exit;

        if EmployeeNo <> Employee."No." then
            Employee.Get(EmployeeNo);

        FormattedEmployee := Employee.FullName();

        AddFieldInfoToCommaSeparatedText(Employee.FieldCaption("Phone No."), Employee."Phone No.", FormattedEmployee);
        AddFieldInfoToCommaSeparatedText(Employee.FieldCaption("E-Mail"), Employee."E-Mail", FormattedEmployee);

        if FormattedEmployee <> '' then
            FormattedEmployee := StrSubstNo(ResponsibleEmployeeLbl, FormattedEmployee);

        exit(FormattedEmployee);
    end;

    local procedure AddFieldInfoToCommaSeparatedText(FieldCaption: Text; FieldValue: Text; var CommaSeparatedText: Text)
    var
        CommaSeparated1Tok: Label '%1, %2: %3', Locked = true;
        CommaSepareted2Tok: Label '%1: %2', Locked = true;
    begin
        if FieldValue = '' then
            exit;

        if CommaSeparatedText <> '' then
            CommaSeparatedText := StrSubstNo(CommaSeparated1Tok, CommaSeparatedText, FieldCaption, FieldValue)
        else
            CommaSeparatedText := StrSubstNo(CommaSepareted2Tok, FieldCaption, FieldValue);
    end;
}
