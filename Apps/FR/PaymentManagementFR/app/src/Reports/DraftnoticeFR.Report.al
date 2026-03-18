// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using System.Utilities;

report 10837 "Draft notice FR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/Draftnotice.rdlc';
    Caption = 'Draft notice';

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
                SetRange("No.", TransfertNo);
            end;
        }
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(Vendor_No_; "No.")
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
                        column(PaymtHeader_IBAN; PaymtHeader.IBAN)
                        {
                        }
                        column(VendAddr_7_; VendAddr[7])
                        {
                        }
                        column(PaymtHeader_SWIFT_Code; PaymtHeader."SWIFT Code")
                        {
                        }
                        column(VendAddr_6_; VendAddr[6])
                        {
                        }
                        column(CompanyInformation__VAT_Registration_No__; CompanyInformation."VAT Registration No.")
                        {
                        }
                        column(VendAddr_5_; VendAddr[5])
                        {
                        }
                        column(CompanyInformation__Fax_No__; CompanyInformation."Fax No.")
                        {
                        }
                        column(VendAddr_4_; VendAddr[4])
                        {
                        }
                        column(CompanyInformation__Phone_No__; CompanyInformation."Phone No.")
                        {
                        }
                        column(VendAddr_3_; VendAddr[3])
                        {
                        }
                        column(CompanyAddr_6_; CompanyAddr[6])
                        {
                        }
                        column(VendAddr_2_; VendAddr[2])
                        {
                        }
                        column(CompanyAddr_5_; CompanyAddr[5])
                        {
                        }
                        column(VendAddr_1_; VendAddr[1])
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
                        column(STRSUBSTNO_Text002_CopyText_; StrSubstNo(Text002Lbl, CopyText))
                        {
                        }
                        column(PrintCurrencyCode; PrintCurrencyCode())
                        {
                        }
                        column(OutputNo; OutputNo)
                        {
                        }
                        column(Vendor__No__; Vendor."No.")
                        {
                        }
                        column(CopyLoop_Number; CopyLoop.Number)
                        {
                        }
                        column(Bank_Account_Buffer___Agency_Code_; "Bank Account Buffer"."Agency Code")
                        {
                        }
                        column(Bank_Account_Buffer___Customer_No__; "Bank Account Buffer"."Customer No.")
                        {
                        }
                        column(Bank_Account_Buffer___Bank_Branch_No__; "Bank Account Buffer"."Bank Branch No.")
                        {
                        }
                        column(Bank_Account_Buffer___Bank_Account_No__; "Bank Account Buffer"."Bank Account No.")
                        {
                        }
                        column(HeaderText1; HeaderText1)
                        {
                        }
                        column(PrintCurrencyCode_Control1120069; PrintCurrencyCode())
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
                        column(PrintCurrencyCode_Control1120064; PrintCurrencyCode())
                        {
                        }
                        column(DraftAmount; DraftAmount)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalDraftAmount; TotalDraftAmount)
                        {
                        }
                        column(Payment_Line_No_; "No.")
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
                        column(PaymtHeader__IBAN__Caption; PaymtHeader__IBAN__CaptionLbl)
                        {
                        }
                        column(PaymtHeader__SWIFT_Code__Caption; PaymtHeader__SWIFT_Code__CaptionLbl)
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
                        column(Draft_Notice_AmountCaption; Draft_Notice_AmountCaptionLbl)
                        {
                        }
                        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
                        {
                            CalcFields = "Remaining Amount";
                            DataItemLink = "Vendor No." = field("Account No."), "Applies-to ID" = field("Applies-to ID");
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
                            column(Vendor_Ledger_Entry__Currency_Code_; "Currency Code")
                            {
                            }
                            column(ABS__Remaining_Amount___Control1120059; Abs("Remaining Amount"))
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(Vendor_Ledger_Entry__Document_No__; "Document No.")
                            {
                            }
                            column(Vendor_Ledger_Entry_Description; Description)
                            {
                            }
                            column(Vendor_Ledger_Entry__External_Document_No__; "External Document No.")
                            {
                            }
                            column(Vendor_Ledger_Entry__Posting_Date_; Format("Posting Date"))
                            {
                            }
                            column(Vendor_Ledger_Entry__Due_Date_; Format("Due Date"))
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
                            column(Vendor_Ledger_Entry_Entry_No_; "Entry No.")
                            {
                            }
                            column(Vendor_Ledger_Entry_Vendor_No_; "Vendor No.")
                            {
                            }
                            column(Vendor_Ledger_Entry_Applies_to_ID; "Applies-to ID")
                            {
                            }
                            column(Vendor_Ledger_Entry__Document_No__Caption; FieldCaption("Document No."))
                            {
                            }
                            column(Vendor_Ledger_Entry_DescriptionCaption; FieldCaption(Description))
                            {
                            }
                            column(Vendor_Ledger_Entry__External_Document_No__Caption; FieldCaption("External Document No."))
                            {
                            }
                            column(Vendor_Ledger_Entry__Posting_Date_Caption; Vendor_Ledger_Entry__Posting_Date_CaptionLbl)
                            {
                            }
                            column(Vendor_Ledger_Entry__Due_Date_Caption; Vendor_Ledger_Entry__Due_Date_CaptionLbl)
                            {
                            }
                            column(ABS__Remaining_Amount___Control1120059Caption; ABS__Remaining_Amount___Control1120059CaptionLbl)
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
                                    CurrReport.Skip()
                                    ;
                                if "Currency Code" = '' then
                                    "Currency Code" := GLSetup."LCY Code";

                                DraftCounting := DraftCounting + 1;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            PaymtAddr: Record "Payment Address FR";
                            PaymtManagt: Codeunit "Payment Management FR";
                        begin
                            HeaderText1 := StrSubstNo(Text004Lbl, "Bank Account Name", "SWIFT Code",
                                "Agency Code", IBAN, PostingDate);
                            DraftCounting := 0;

                            TotalDraftAmount := TotalDraftAmount + Abs(Amount);

                            if "Payment Address Code" = '' then
                                FormatAddress.Vendor(VendAddr, Vendor)
                            else
                                if PaymtAddr.Get("Account Type"::Vendor, "Account No.", "Payment Address Code") then
                                    PaymtManagt.PaymentAddr(VendAddr, PaymtAddr);

                            DraftAmount := Abs(Amount);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("No.", TransfertNo);
                            SetRange("Account No.", Vendor."No.");

                            TotalDraftAmount := 0;
                            Clear(DraftAmount);
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText := Text001Lbl;
                        OutputNo := OutputNo + 1;
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
                PaymtLine.Reset();
                PaymtLine.SetRange("No.", TransfertNo);
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
        TransfertNo := CopyStr("Payment Lines1".GetFilter("No."), 1, MaxStrLen(TransfertNo));
        if TransfertNo = '' then
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
        VendAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        LoopsNumber: Integer;
        CopiesNumber: Integer;
        CopyText: Text;
        DraftAmount: Decimal;
        TotalDraftAmount: Decimal;
        DraftCounting: Decimal;
        TransfertNo: Code[20];
        HeaderText1: Text;
        PostingDate: Date;
        Text000Lbl: Label 'You must specify a transfer number.';
        Text001Lbl: Label 'COPY';
        Text002Lbl: Label 'Draft notice %1', Comment = '%1 = copy';
        Text004Lbl: Label 'A transfer to your bank account %1 (RIB : %2 %3 %4) has been done on %5.', Comment = '%1 = name, %2 = SWIFT Code, %3 = Agency Code, %4 = IBAN, %5 = Posting Date ';
        HeaderText2Lbl: Label 'This transfer is related to these invoices :';
        OutputNo: Integer;
        Payment_Lines1___No__CaptionLbl: Label 'Draft No.';
        PaymtHeader__IBAN__CaptionLbl: Label 'IBAN', Locked = true;
        PaymtHeader__SWIFT_Code__CaptionLbl: Label 'SWIFT Code';
        CompanyInformation__VAT_Registration_No__CaptionLbl: Label 'VAT Registration No.';
        CompanyInformation__Fax_No__CaptionLbl: Label 'FAX No.';
        CompanyInformation__Phone_No__CaptionLbl: Label 'Phone No.';
        PrintCurrencyCodeCaptionLbl: Label 'Currency Code';
        Draft_Notice_AmountCaptionLbl: Label 'Draft Notice Amount';
        Vendor_Ledger_Entry__Posting_Date_CaptionLbl: Label 'Posting Date';
        Vendor_Ledger_Entry__Due_Date_CaptionLbl: Label 'Due Date';
        ABS__Remaining_Amount___Control1120059CaptionLbl: Label 'Amount';
        ReportCaptionLbl: Label 'Report';
        ReportCaption_Control1120015Lbl: Label 'Report';


    procedure PrintCurrencyCode(): Code[10]
    begin
        if "Payment Lines1"."Currency Code" = '' then
            exit(GLSetup."LCY Code");

        exit("Payment Lines1"."Currency Code");
    end;
}
