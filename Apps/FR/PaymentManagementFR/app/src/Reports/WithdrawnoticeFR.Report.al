// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Utilities;

report 10852 "Withdraw notice FR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/Withdrawnotice.rdlc';
    Caption = 'Withdraw notice';

    dataset
    {
        dataitem("Payment Lines1"; "Payment Line FR")
        {
            DataItemTableView = sorting("No.", "Line No.") where(Marked = const(true));
            column(Payment_Lines1_No_; "No.")
            {
            }
            column(Payment_Lines1_Line_No_; "Line No.")
            {
            }

            trigger OnAfterGetRecord()
            begin
                PaymtHeader.Get("No.");
                PaymtHeader.CalcFields("Payment Class Name");
                PostingDate := PaymtHeader."Posting Date";

                BankAccountBuffer.Init();
                BankAccountBuffer."Customer No." := "Account No.";
                BankAccountBuffer."Bank Branch No." := "Bank Branch No.";
                BankAccountBuffer."Agency Code" := "Agency Code";
                BankAccountBuffer."Bank Account No." := "Bank Account No.";
                if not BankAccountBuffer.Insert() then;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("No.", WithdrawNo);
            end;
        }
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(Customer_No_; "No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem("Bank Account Buffer"; "Bank Account Buffer FR")
                {
                    DataItemTableView = sorting("Customer No.", "Bank Branch No.", "Agency Code", "Bank Account No.");
                    column(Bank_Account_Buffer_Customer_No_; "Customer No.")
                    {
                    }
                    column(Bank_Account_Buffer_Bank_Branch_No_; "Bank Branch No.")
                    {
                    }
                    column(Bank_Account_Buffer_Agency_Code; "Agency Code")
                    {
                    }
                    column(Bank_Account_Buffer_Bank_Account_No_; "Bank Account No.")
                    {
                    }
                    dataitem("Payment Line"; "Payment Line FR")
                    {
                        DataItemLink = "Account No." = field("Customer No."), "Bank Branch No." = field("Bank Branch No."), "Agency Code" = field("Agency Code"), "Bank Account No." = field("Bank Account No.");
                        DataItemLinkReference = "Bank Account Buffer";
                        DataItemTableView = sorting("No.", "Account No.", "Bank Branch No.", "Agency Code", "Bank Account No.", "Payment Address Code") where(Marked = const(true));
                        column(FORMAT_PostingDate_0_4_; Format(PostingDate, 0, 4))
                        {
                        }
                        column(Payment_Lines1___No__; "Payment Lines1"."No.")
                        {
                        }
                        column(PaymtHeader__Bank_Account_No__; PaymtHeader."Bank Account No.")
                        {
                        }
                        column(PaymtHeader__Agency_Code_; PaymtHeader."Agency Code")
                        {
                        }
                        column(CustAddr_7_; CustAddr[7])
                        {
                        }
                        column(PaymtHeader__Bank_Branch_No__; PaymtHeader."Bank Branch No.")
                        {
                        }
                        column(CustAddr_6_; CustAddr[6])
                        {
                        }
                        column(CompanyInformation__VAT_Registration_No__; CompanyInformation."VAT Registration No.")
                        {
                        }
                        column(CustAddr_5_; CustAddr[5])
                        {
                        }
                        column(CompanyInformation__Fax_No__; CompanyInformation."Fax No.")
                        {
                        }
                        column(CustAddr_4_; CustAddr[4])
                        {
                        }
                        column(CompanyInformation__Phone_No__; CompanyInformation."Phone No.")
                        {
                        }
                        column(CustAddr_3_; CustAddr[3])
                        {
                        }
                        column(CompanyAddr_6_; CompanyAddr[6])
                        {
                        }
                        column(CustAddr_2_; CustAddr[2])
                        {
                        }
                        column(CompanyAddr_5_; CompanyAddr[5])
                        {
                        }
                        column(CustAddr_1_; CustAddr[1])
                        {
                        }
                        column(CompanyAddr_4_; CompanyAddr[4])
                        {
                        }
                        column(CompanyAddr_3_; CompanyAddr[3])
                        {
                        }
                        column(CompanyAddr_2_; CompanyAddr[2])
                        {
                        }
                        column(CompanyAddr_1_; CompanyAddr[1])
                        {
                        }
                        column(STRSUBSTNO_Text003_CopyText_; StrSubstNo(Text003Lbl, CopyText))
                        {
                        }
                        column(PrintCurrencyCode; PrintCurrencyCode())
                        {
                        }
                        column(CustomerNO; Customer."No.")
                        {
                        }
                        column(PageCaption; StrSubstNo(Text005Lbl, ' '))
                        {
                        }
                        column(OutputNo; OutputNo)
                        {
                        }
                        column(CopyLoop_Number; CopyLoop.Number)
                        {
                        }
                        column(HeaderText1; HeaderText1)
                        {
                        }
                        column(Payment_Line___No__; "No.")
                        {
                        }
                        column(TotalWithdrawAmount; TotalWithdrawAmount)
                        {
                        }
                        column(PrintCurrencyCode_Control1120000; PrintCurrencyCode())
                        {
                        }
                        column(ABS_Amount_; Abs(Amount))
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Payment_Line__Due_Date_; Format("Due Date"))
                        {
                        }
                        column(PostingDate; Format(PostingDate))
                        {
                        }
                        column(Payment_Line__External_Document_No__; "External Document No.")
                        {
                        }
                        column(PaymtHeader__Payment_Class_Name_; PaymtHeader."Payment Class Name")
                        {
                        }
                        column(Payment_Line__Document_No__; "Document No.")
                        {
                        }
                        column(WithdrawAmount; WithdrawAmount)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrintCurrencyCode_Control1120019; PrintCurrencyCode())
                        {
                        }
                        column(Payment_Line_Line_No_; "Line No.")
                        {
                        }
                        column(Payment_Line_Payment_Address_Code; "Payment Address Code")
                        {
                        }
                        column(Payment_Line_Account_No_; "Account No.")
                        {
                        }
                        column(Payment_Line_Bank_Branch_No_; "Bank Branch No.")
                        {
                        }
                        column(Payment_Line_Agency_Code; "Agency Code")
                        {
                        }
                        column(Payment_Line_Bank_Account_No_; "Bank Account No.")
                        {
                        }
                        column(Payment_Line_Applies_to_ID; "Applies-to ID")
                        {
                        }
                        column(Payment_Lines1___No__Caption; Payment_Lines1___No__CaptionLbl)
                        {
                        }
                        column(PaymtHeader__Bank_Account_No__Caption; PaymtHeader__Bank_Account_No__CaptionLbl)
                        {
                        }
                        column(PaymtHeader__Agency_Code_Caption; PaymtHeader__Agency_Code_CaptionLbl)
                        {
                        }
                        column(PaymtHeader__Bank_Branch_No__Caption; PaymtHeader__Bank_Branch_No__CaptionLbl)
                        {
                        }
                        column(CompanyInformation__VAT_Registration_No__Caption; CompanyInformation__VAT_Registration_No__CaptionLbl)
                        {
                        }
                        column(CompanyInformation__Fax_No__Caption; CompanyInformation__Fax_No__CaptionLbl)
                        {
                        }
                        column(CompanyInformation__Phone_No__Caption; CompanyInformation__Phone_No__CaptionLbl)
                        {
                        }
                        column(PrintCurrencyCodeCaption; PrintCurrencyCodeCaptionLbl)
                        {
                        }
                        column(Withdraw_Notice_AmountCaption; Withdraw_Notice_AmountCaptionLbl)
                        {
                        }
                        column(DirectDebitMandateID_PaymentLine; "Direct Debit Mandate ID")
                        {
                        }
                        column(IBAN_PaymentLine; IBAN)
                        {
                        }
                        column(SWIFTCode_PaymentLine; "SWIFT Code")
                        {
                        }
                        dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                        {
                            CalcFields = "Remaining Amount";
                            DataItemLink = "Customer No." = field("Account No."), "Applies-to ID" = field("Applies-to ID");
                            DataItemLinkReference = "Payment Line";
                            DataItemTableView = sorting("Document No.");
                            column(HeaderText2; HeaderText2Lbl)
                            {
                            }
                            column(ABS__Remaining_Amount__; Abs("Remaining Amount"))
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(PrintCurrencyCode_Control1120060; PrintCurrencyCode())
                            {
                            }
                            column(Cust__Ledger_Entry__Currency_Code_; "Currency Code")
                            {
                            }
                            column(ABS__Remaining_Amount___Control1120031; Abs("Remaining Amount"))
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(Cust__Ledger_Entry__Due_Date_; Format("Due Date"))
                            {
                            }
                            column(Cust__Ledger_Entry__Posting_Date_; Format("Posting Date"))
                            {
                            }
                            column(Cust__Ledger_Entry__External_Document_No__; "External Document No.")
                            {
                            }
                            column(Cust__Ledger_Entry_Description; Description)
                            {
                            }
                            column(Cust__Ledger_Entry__Document_No__; "Document No.")
                            {
                            }
                            column(Cust__Led_Entry___Entry_No__; "Cust. Ledger Entry"."Entry No.")
                            {
                            }
                            column(ABS__Remaining_Amount___Control1120036; Abs("Remaining Amount"))
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(PrintCurrencyCode_Control1120063; PrintCurrencyCode())
                            {
                            }
                            column(Cust__Ledger_Entry_Customer_No_; "Customer No.")
                            {
                            }
                            column(Cust__Ledger_Entry_Applies_to_ID; "Applies-to ID")
                            {
                            }
                            column(Cust__Ledger_Entry_DescriptionCaption; FieldCaption(Description))
                            {
                            }
                            column(Cust__Ledger_Entry__External_Document_No__Caption; FieldCaption("External Document No."))
                            {
                            }
                            column(Cust__Ledger_Entry__Posting_Date_Caption; Cust__Ledger_Entry__Posting_Date_CaptionLbl)
                            {
                            }
                            column(Cust__Ledger_Entry__Due_Date_Caption; Cust__Ledger_Entry__Due_Date_CaptionLbl)
                            {
                            }
                            column(ABS__Remaining_Amount___Control1120031Caption; ABS__Remaining_Amount___Control1120031CaptionLbl)
                            {
                            }
                            column(Cust__Ledger_Entry__Document_No__Caption; FieldCaption("Document No."))
                            {
                            }
                            column(ReportCaption; ReportCaptionLbl)
                            {
                            }
                            column(ReportCaption_Control1120015; ReportCaption_Control1120015Lbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if "Payment Line"."Applies-to ID" = '' then
                                    CurrReport.Skip();
                                if "Currency Code" = '' then
                                    "Currency Code" := GLSetup."LCY Code";

                                WithdrawCounting := WithdrawCounting + 1;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            PaymtAddr: Record "Payment Address FR";
                            PaymtManagt: Codeunit "Payment Management FR";
                        begin
                            HeaderText1 := StrSubstNo(Text004Lbl, "Bank Account Name", "Bank Branch No.",
                                "Agency Code", "Bank Account No.", PostingDate);

                            if PaymentAddressCodeOld <> "Payment Address Code" then begin
                                WithdrawCounting := 0;
                                PaymentAddressCodeOld := "Payment Address Code";
                            end;

                            TotalWithdrawAmount += Abs(Amount);

                            if "Payment Address Code" = '' then
                                FormatAddress.Customer(CustAddr, Customer)
                            else
                                if PaymtAddr.Get("Account Type"::Customer, "Account No.", "Payment Address Code") then
                                    PaymtManagt.PaymentAddr(CustAddr, PaymtAddr);

                            WithdrawAmount := Abs(Amount);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("No.", WithdrawNo);
                            SetRange("Account No.", Customer."No.");

                            TotalWithdrawAmount := 0;
                            Clear(WithdrawAmount);
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText := Text001Lbl;
                        OutputNo += 1;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    LoopsNumber := Abs(CopiesNumber) + 1;
                    CopyText := '';
                    SetRange(Number, 1, LoopsNumber);

                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                PaymtLine.Reset();
                PaymtLine.SetRange("No.", WithdrawNo);
                PaymtLine.SetRange("Account No.", "No.");
                if not PaymtLine.FindFirst() then
                    CurrReport.Skip();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NumberOfCopies; CopiesNumber)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Number of copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        BankAccountBuffer.DeleteAll();
    end;

    trigger OnPreReport()
    begin
        WithdrawNo := CopyStr("Payment Lines1".GetFilter("No."), 1, MaxStrLen(WithdrawNo));
        if WithdrawNo = '' then
            Error(Text000Lbl);

        CompanyInformation.Get();
        FormatAddress.Company(CompanyAddr, CompanyInformation);
        GLSetup.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        PaymtHeader: Record "Payment Header FR";
        PaymtLine: Record "Payment Line FR";
        BankAccountBuffer: Record "Bank Account Buffer FR";
        FormatAddress: Codeunit "Format Address";
        CustAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        LoopsNumber: Integer;
        CopiesNumber: Integer;
        OutputNo: Integer;
        CopyText: Text;
        PaymentAddressCodeOld: Code[10];
        WithdrawAmount: Decimal;
        TotalWithdrawAmount: Decimal;
        WithdrawCounting: Decimal;
        WithdrawNo: Code[20];
        HeaderText1: Text;
        PostingDate: Date;
        Text000Lbl: Label 'You must specify a withdraw number.';
        Text001Lbl: Label 'COPY';
        Text003Lbl: Label 'Withdraw %1', Comment = '%1 = Withdraw - report title. Can be "Withdraw" or "Withdraw COPY"';
        Text004Lbl: Label 'A withdraw on your bank account %1 (RIB : %2 %3 %4) has been done on %5.', Comment = '%1 = Name, %2 = Bank Branch No., %3 = Agency Code, %4 = Bank Account No., %5 = Posting Date';
        HeaderText2Lbl: Label 'This withdraw is related to these invoices :';
        Text005Lbl: Label 'Page %1', Comment = '%1 = caption';
        Payment_Lines1___No__CaptionLbl: Label 'Withdraw No.';
        PaymtHeader__Bank_Account_No__CaptionLbl: Label 'Bank Account No.';
        PaymtHeader__Agency_Code_CaptionLbl: Label 'Agency Code';
        PaymtHeader__Bank_Branch_No__CaptionLbl: Label 'Bank Branch No.';
        CompanyInformation__VAT_Registration_No__CaptionLbl: Label 'VAT Registration No.';
        CompanyInformation__Fax_No__CaptionLbl: Label 'FAX No.';
        CompanyInformation__Phone_No__CaptionLbl: Label 'Phone No.';
        PrintCurrencyCodeCaptionLbl: Label 'Currency Code';
        Withdraw_Notice_AmountCaptionLbl: Label 'Withdraw Notice Amount';
        Cust__Ledger_Entry__Posting_Date_CaptionLbl: Label 'Posting Date';
        Cust__Ledger_Entry__Due_Date_CaptionLbl: Label 'Due Date';
        ABS__Remaining_Amount___Control1120031CaptionLbl: Label 'Amount';
        ReportCaptionLbl: Label 'Report';
        ReportCaption_Control1120015Lbl: Label 'Report';


    procedure PrintCurrencyCode(): Code[10]
    begin
        if "Payment Lines1"."Currency Code" = '' then
            exit(GLSetup."LCY Code");

        exit("Payment Lines1"."Currency Code");
    end;
}
