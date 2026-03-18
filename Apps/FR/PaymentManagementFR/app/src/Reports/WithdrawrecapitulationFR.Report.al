// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using System.Utilities;

report 10853 "Withdraw recapitulation FR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/Withdrawrecapitulation.rdlc';
    Caption = 'Withdraw recapitulation';

    dataset
    {
        dataitem("Payment Lines1"; "Payment Line FR")
        {
            DataItemTableView = sorting("No.", "Line No.");
            MaxIteration = 1;
            PrintOnlyIfDetail = true;
            column(Payment_Lines1_No_; "No.")
            {
            }
            column(Payment_Lines1_Line_No_; "Line No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(PaymtHeader__No__; PaymtHeader."No.")
                    {
                    }
                    column(STRSUBSTNO_Text005_CopyText_; StrSubstNo(Text005Lbl, CopyText))
                    {
                    }
                    column(CompanyAddr_1_; CompanyAddr[1])
                    {
                    }
                    column(CompanyAddr_2_; CompanyAddr[2])
                    {
                    }
                    column(CompanyAddr_3_; CompanyAddr[3])
                    {
                    }
                    column(CompanyAddr_4_; CompanyAddr[4])
                    {
                    }
                    column(CompanyAddr_5_; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr_6_; CompanyAddr[6])
                    {
                    }
                    column(CompanyInformation__Phone_No__; CompanyInformation."Phone No.")
                    {
                    }
                    column(CompanyInformation__Fax_No__; CompanyInformation."Fax No.")
                    {
                    }
                    column(CompanyInformation__VAT_Registration_No__; CompanyInformation."VAT Registration No.")
                    {
                    }
                    column(FORMAT_PostingDate_0_4_; Format(PostingDate, 0, 4))
                    {
                    }
                    column(BankAccountAddr_4_; BankAccountAddr[4])
                    {
                    }
                    column(BankAccountAddr_5_; BankAccountAddr[5])
                    {
                    }
                    column(BankAccountAddr_6_; BankAccountAddr[6])
                    {
                    }
                    column(BankAccountAddr_7_; BankAccountAddr[7])
                    {
                    }
                    column(BankAccountAddr_3_; BankAccountAddr[3])
                    {
                    }
                    column(BankAccountAddr_2_; BankAccountAddr[2])
                    {
                    }
                    column(BankAccountAddr_1_; BankAccountAddr[1])
                    {
                    }
                    column(PrintCurrencyCode; PrintCurrencyCode())
                    {
                    }
                    column(PaymtHeader__Bank_Branch_No__; PaymtHeader."Bank Branch No.")
                    {
                    }
                    column(PaymtHeader__Agency_Code_; PaymtHeader."Agency Code")
                    {
                    }
                    column(PaymtHeader__Bank_Account_No__; PaymtHeader."Bank Account No.")
                    {
                    }
                    column(PaymtHeader__RIB_Key_; PaymtHeader."RIB Key")
                    {
                    }
                    column(PaymtHeader__National_Issuer_No__; PaymtHeader."National Issuer No.")
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PaymtHeader_IBAN; PaymtHeader.IBAN)
                    {
                    }
                    column(PaymtHeader__SWIFT_Code_; PaymtHeader."SWIFT Code")
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    column(PaymtHeader__No__Caption; PaymtHeader__No__CaptionLbl)
                    {
                    }
                    column(CompanyInformation__Phone_No__Caption; CompanyInformation__Phone_No__CaptionLbl)
                    {
                    }
                    column(CompanyInformation__Fax_No__Caption; CompanyInformation__Fax_No__CaptionLbl)
                    {
                    }
                    column(CompanyInformation__VAT_Registration_No__Caption; CompanyInformation__VAT_Registration_No__CaptionLbl)
                    {
                    }
                    column(PrintCurrencyCodeCaption; PrintCurrencyCodeCaptionLbl)
                    {
                    }
                    column(PaymtHeader__Bank_Branch_No__Caption; PaymtHeader__Bank_Branch_No__CaptionLbl)
                    {
                    }
                    column(PaymtHeader__Agency_Code_Caption; PaymtHeader__Agency_Code_CaptionLbl)
                    {
                    }
                    column(PaymtHeader__Bank_Account_No__Caption; PaymtHeader__Bank_Account_No__CaptionLbl)
                    {
                    }
                    column(PaymtHeader__RIB_Key_Caption; PaymtHeader__RIB_Key_CaptionLbl)
                    {
                    }
                    column(PaymtHeader__National_Issuer_No__Caption; PaymtHeader__National_Issuer_No__CaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    column(PaymtHeader_IBANCaption; PaymtHeader_IBANCaptionLbl)
                    {
                    }
                    column(PaymtHeader__SWIFT_Code_Caption; PaymtHeader__SWIFT_Code_CaptionLbl)
                    {
                    }
                    dataitem("Payment Lines"; "Payment Line FR")
                    {
                        DataItemLink = "No." = field("No.");
                        DataItemLinkReference = "Payment Lines1";
                        DataItemTableView = sorting("No.", "Line No.");
                        column(ABS_Amount_; Abs(Amount))
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrintCurrencyCode_Control1120060; PrintCurrencyCode())
                        {
                        }
                        column(Customer_Name; Customer.Name)
                        {
                        }
                        column(Payment_Lines__Bank_Branch_No__; "Bank Branch No.")
                        {
                        }
                        column(ABS_Amount__Control1120031; Abs(Amount))
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Payment_Lines__Bank_Account_Name_; "Bank Account Name")
                        {
                        }
                        column(Payment_Lines__Account_No__; "Account No.")
                        {
                        }
                        column(PrintCurrencyCode_Control1120061; PrintCurrencyCode())
                        {
                        }
                        column(Payment_Lines__Agency_Code_; "Agency Code")
                        {
                        }
                        column(Payment_Lines__Bank_Account_No__; "Bank Account No.")
                        {
                        }
                        column(Payment_Lines__SWIFT_Code_; "SWIFT Code")
                        {
                        }
                        column(Payment_Lines_IBAN; IBAN)
                        {
                        }
                        column(ABS_Amount__Control1120036; Abs(Amount))
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrintCurrencyCode_Control1120063; PrintCurrencyCode())
                        {
                        }
                        column(WithdrawAmount; WithdrawAmount)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrintWithdrawCounting; PrintWithdrawCounting())
                        {
                        }
                        column(PrintCurrencyCode_Control1120064; PrintCurrencyCode())
                        {
                        }
                        column(FORMAT_PostingDate_0_4__Control1120034; Format(PostingDate, 0, 4))
                        {
                        }
                        column(CompanyInformation_City; CompanyInformation.City)
                        {
                        }
                        column(WithdrawCounting; WithdrawCounting)
                        {
                        }
                        column(Text001; Text001Lbl)
                        {
                        }
                        column(Text002; Text002Lbl)
                        {
                        }
                        column(Payment_Lines_No_; "No.")
                        {
                        }
                        column(Payment_Lines_Line_No_; "Line No.")
                        {
                        }
                        column(Payment_Lines__Account_No__Caption; FieldCaption("Account No."))
                        {
                        }
                        column(Customer_NameCaption; Customer_NameCaptionLbl)
                        {
                        }
                        column(Payment_Lines__Bank_Account_Name_Caption; FieldCaption("Bank Account Name"))
                        {
                        }
                        column(ABS_Amount__Control1120031Caption; ABS_Amount__Control1120031CaptionLbl)
                        {
                        }
                        column(Bank_AccountCaption; Bank_AccountCaptionLbl)
                        {
                        }
                        column(Payment_Lines__SWIFT_Code_Caption; Payment_Lines__SWIFT_Code_CaptionLbl)
                        {
                        }
                        column(Payment_Lines_IBANCaption; Payment_Lines_IBANCaptionLbl)
                        {
                        }
                        column(ReportCaption; ReportCaptionLbl)
                        {
                        }
                        column(ReportCaption_Control1120015; ReportCaption_Control1120015Lbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }
                        column(Done_at__Caption; Done_at__CaptionLbl)
                        {
                        }
                        column(On__Caption; On__CaptionLbl)
                        {
                        }
                        column(Signature__Caption; Signature__CaptionLbl)
                        {
                        }
                        column(DirectDebitMandateID_PaymentLines; "Direct Debit Mandate ID")
                        {
                        }
                        column(DirectDebitMandateID_PaymentLines_Caption; FieldCaption("Direct Debit Mandate ID"))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            Customer.SetRange("No.", "Account No.");
                            if not Customer.FindFirst() then
                                Error(Text004Lbl, "Account No.");

                            WithdrawAmount := Abs(Amount);
                            WithdrawCounting := 1;
                        end;

                        trigger OnPreDataItem()
                        begin
                            Clear(WithdrawAmount);
                            Clear(WithdrawCounting);
                            SetRange("Account Type", "Account Type"::Customer);
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText := Text003Lbl;
                        OutputNo += 1;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    OutputNo := 1;
                    LoopsNumber := Abs(CopiesNumber) + 1;
                    CopyText := '';
                    SetRange(Number, 1, LoopsNumber);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                PaymtHeader.Get("No.");
                PostingDate := PaymtHeader."Posting Date";

                PaymtManagt.PaymentBankAcc(BankAccountAddr, PaymtHeader);
            end;

            trigger OnPreDataItem()
            begin
                SetRange("No.", WithDrawNo);
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
                    field(Copies_Number; CopiesNumber)
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

    trigger OnPreReport()
    begin
        WithDrawNo := CopyStr("Payment Lines1".GetFilter("No."), 1, MaxStrLen(WithDrawNo));
        if WithDrawNo = '' then
            Error(Text006Lbl);

        CompanyInformation.Get();
        FormatAddress.Company(CompanyAddr, CompanyInformation);
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        PaymtHeader: Record "Payment Header FR";
        PaymtManagt: Codeunit "Payment Management FR";
        FormatAddress: Codeunit "Format Address";
        BankAccountAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        LoopsNumber: Integer;
        CopiesNumber: Integer;
        CopyText: Text;
        WithdrawAmount: Decimal;
        WithdrawCounting: Decimal;
        WithDrawNo: Code[20];
        PostingDate: Date;
        Text003Lbl: Label 'COPY';
        Text004Lbl: Label 'Customer %1 does not exist.', Comment = '%1 = Account No.';
        Text005Lbl: Label 'Withdraw Recapitulation %1', Comment = '%1 = copy';
        Text006Lbl: Label 'You must specify a withdraw number.';
        OutputNo: Integer;
        PaymtHeader__No__CaptionLbl: Label 'Withdraw No.';
        CompanyInformation__Phone_No__CaptionLbl: Label 'Phone No.';
        CompanyInformation__Fax_No__CaptionLbl: Label 'Fax No.';
        CompanyInformation__VAT_Registration_No__CaptionLbl: Label 'VAT Registration No.';
        PrintCurrencyCodeCaptionLbl: Label 'Currency Code';
        PaymtHeader__Bank_Branch_No__CaptionLbl: Label 'Bank Branch No.';
        PaymtHeader__Agency_Code_CaptionLbl: Label 'Agency Code';
        PaymtHeader__Bank_Account_No__CaptionLbl: Label 'Bank Account No.';
        PaymtHeader__RIB_Key_CaptionLbl: Label 'RIB Key';
        PaymtHeader__National_Issuer_No__CaptionLbl: Label 'National Issuer No.';
        PageCaptionLbl: Label 'Page';
        PaymtHeader_IBANCaptionLbl: Label 'IBAN', Locked = true;
        PaymtHeader__SWIFT_Code_CaptionLbl: Label 'SWIFT Code';
        Text001Lbl: Label ' WITHDRAWS';
        Text002Lbl: Label ' WITHDRAW';
        Customer_NameCaptionLbl: Label 'Name';
        ABS_Amount__Control1120031CaptionLbl: Label 'Amount';
        Bank_AccountCaptionLbl: Label 'Bank Account';
        Payment_Lines__SWIFT_Code_CaptionLbl: Label 'SWIFT Code';
        Payment_Lines_IBANCaptionLbl: Label 'IBAN', Locked = true;
        ReportCaptionLbl: Label 'Report';
        ReportCaption_Control1120015Lbl: Label 'Report';
        TotalCaptionLbl: Label 'Total';
        Done_at__CaptionLbl: Label 'Done at :';
        On__CaptionLbl: Label 'On :';
        Signature__CaptionLbl: Label 'Signature :';


    procedure PrintWithdrawCounting(): Text[30]
    begin
        if WithdrawCounting > 1 then
            exit(Format(WithdrawCounting) + Text001Lbl);

        exit(Format(WithdrawCounting) + Text002Lbl);
    end;


    procedure InitRequest(InitWithdrawNo: Code[20]; InitCopies: Integer)
    begin
        WithDrawNo := InitWithdrawNo;
        CopiesNumber := InitCopies;
    end;


    procedure PrintCurrencyCode(): Code[10]
    begin
        if "Payment Lines1"."Currency Code" = '' then begin
            GLSetup.Get();
            exit(GLSetup."LCY Code");
        end;
        exit("Payment Lines1"."Currency Code");
    end;
}

