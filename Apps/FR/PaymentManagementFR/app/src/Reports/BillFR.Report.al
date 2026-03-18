// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;

report 10834 "Bill FR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/Bill.rdlc';
    Caption = 'Bill';

    dataset
    {
        dataitem("Payment Line"; "Payment Line FR")
        {
            DataItemTableView = where("Account Type" = filter(Customer), Marked = const(true));
            RequestFilterHeading = 'Payment lines';
            column(CustAdr_6_; CustAdr[6])
            {
            }
            column(CustAdr_7_; CustAdr[7])
            {
            }
            column(CustAdr_5_; CustAdr[5])
            {
            }
            column(CustAdr_4_; CustAdr[4])
            {
            }
            column(CustAdr_2_; CustAdr[2])
            {
            }
            column(CustAdr_3_; CustAdr[3])
            {
            }
            column(CustAdr_1_; CustAdr[1])
            {
            }
            column(Payment_Line__Agency_Code_; "Agency Code")
            {
            }
            column(Payment_Line__Bank_Branch_No__; "Bank Branch No.")
            {
            }
            column(Payment_Line__Bank_Account_No__; "Bank Account No.")
            {
            }
            column(CONVERTSTR_FORMAT__RIB_Key__2_______0__; ConvertStr(Format("RIB Key", 2), ' ', '0'))
            {
            }
            column(Payment_Line__Bank_Account_Name_; "Bank Account Name")
            {
            }
            column(FORMAT_Amount_0___Precision_2___Standard_Format_0___; '****' + Format(Amount, 0, '<Precision,2:><Standard Format,0>'))
            {
            }
            column(FORMAT_Amount_0___Precision_2___Standard_Format_0____Control1120051; '****' + Format(Amount, 0, '<Precision,2:><Standard Format,0>'))
            {
            }
            column(Payment_Line__Drawee_Reference_; "Drawee Reference")
            {
            }
            column(IssueCity; Issue_City)
            {
            }
            column(IssueDate; Format(Issue_Date))
            {
            }
            column(Payment_Line__Due_Date_; Format("Due Date"))
            {
            }
            column(Payment_Line__Bank_City_; "Bank City")
            {
            }
            column(PostingDate; Format(PostingDate))
            {
            }
            column(AmountText; AmountText)
            {
            }
            column(FORMAT_AmountText_; Format(AmountText))
            {
            }
            column(Payment_Line_No_; "No.")
            {
            }
            column(Payment_Line_Line_No_; "Line No.")
            {
            }
            column(ACCEPTANCE_or_ENDORSMENTCaption; ACCEPTANCE_or_ENDORSMENTCaptionLbl)
            {
            }
            column(of_DRAWEECaption; of_DRAWEECaptionLbl)
            {
            }
            column(Stamp_Allow_and_SignatureCaption; Stamp_Allow_and_SignatureCaptionLbl)
            {
            }
            column(ADDRESSCaption; ADDRESSCaptionLbl)
            {
            }
            column(NAME_andCaption; NAME_andCaptionLbl)
            {
            }
            column(Value_in__Caption; Value_in__CaptionLbl)
            {
            }
            column(DRAWEE_R_I_B_Caption; DRAWEE_R_I_B_CaptionLbl)
            {
            }
            column(DOMICILIATIONCaption; DOMICILIATIONCaptionLbl)
            {
            }
            column(TOCaption; TOCaptionLbl)
            {
            }
            column(ONCaption; ONCaptionLbl)
            {
            }
            column(AMOUNT_FOR_CONTROLCaption; AMOUNT_FOR_CONTROLCaptionLbl)
            {
            }
            column(CREATION_DATECaption; CREATION_DATECaptionLbl)
            {
            }
            column(DUE_DATECaption; DUE_DATECaptionLbl)
            {
            }
            column(DRAWEE_REF_Caption; DRAWEE_REF_CaptionLbl)
            {
            }
            column(BILLCaption; BILLCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            var
                CustPaymentAddr: Record "Payment Address FR";
                Cust: Record Customer;
                FormatAddress: Codeunit "Format Address";
            begin
                CustPaymentAddr.Init();

                PaymtHeader.Get("No.");
                PostingDate := PaymtHeader."Posting Date";

                Amount := -Amount;

                GLSetup.Get();
                if Issue_Date = 0D then
                    Issue_Date := WorkDate();

                if CustPaymentAddr.Get("Account Type", "Account No.", "Payment Address Code") then
                    PaymtManagt.PaymentAddr(CustAdr, CustPaymentAddr)
                else begin
                    Cust.Get("Account No.");
                    FormatAddress.Customer(CustAdr, Cust);
                end;

                if "Currency Code" = '' then
                    AmountText := Text001Lbl + ' â‚¬'
                else
                    AmountText := Text001Lbl + ' ' + "Currency Code";
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
                    field(IssueDate; Issue_Date)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issue date';
                        ToolTip = 'Specifies the name of the city where the bill will be issued.';
                    }
                    field(IssueCity; Issue_City)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issue city';
                        ToolTip = 'Specifies the name of the city where the bill will be issued.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            CompanyInfo.Get();
            Issue_City := CompanyInfo.City;
            Issue_Date := WorkDate();
        end;
    }

    labels
    {
        Against_this_BILL_noted_as_NO_CHARGES_please_pay_the_indicated_sum_below_for_order_ofCaption = 'Against this BILL noted as NO CHARGES Please pay the indicated sum below for order of :';
    }

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        PaymtHeader: Record "Payment Header FR";
        PaymtManagt: Codeunit "Payment Management FR";
        CustAdr: array[8] of Text[100];
        Issue_City: Text[30];
        Issue_Date: Date;
        PostingDate: Date;
        Text001Lbl: Label 'Amount';
        AmountText: Text[30];
        ACCEPTANCE_or_ENDORSMENTCaptionLbl: Label 'ACCEPTANCE or ENDORSMENT';
        of_DRAWEECaptionLbl: Label 'of DRAWEE', Comment = 'NAME and ADDRESS of DRAWEE';
        Stamp_Allow_and_SignatureCaptionLbl: Label 'Stamp Allow and Signature';
        ADDRESSCaptionLbl: Label 'ADDRESS', Comment = 'Translate address and uppecase the result';
        NAME_andCaptionLbl: Label 'NAME and';
        Value_in__CaptionLbl: Label 'Value in :';
        DRAWEE_R_I_B_CaptionLbl: Label 'DRAWEE R.I.B.';
        DOMICILIATIONCaptionLbl: Label 'DOMICILIATION', Comment = 'Translate domiciliation and uppecase the result';
        TOCaptionLbl: Label 'TO';
        ONCaptionLbl: Label 'ON';
        AMOUNT_FOR_CONTROLCaptionLbl: Label 'AMOUNT FOR CONTROL';
        CREATION_DATECaptionLbl: Label 'CREATION DATE';
        DUE_DATECaptionLbl: Label 'DUE DATE';
        DRAWEE_REF_CaptionLbl: Label 'DRAWEE REF.';
        BILLCaptionLbl: Label 'BILL';
}

