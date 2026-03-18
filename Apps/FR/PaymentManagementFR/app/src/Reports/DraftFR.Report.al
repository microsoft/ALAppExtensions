// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;

report 10836 "Draft FR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/Draft.rdlc';
    Caption = 'Draft';

    dataset
    {
        dataitem("Payment Line"; "Payment Line FR")
        {
            DataItemTableView = where("Account Type" = filter(Vendor), Marked = const(true));
            RequestFilterHeading = 'Payment lines';
            column(CompanyAddr_6_; CompanyAddr[6])
            {
            }
            column(CompanyAddr_7_; CompanyAddr[7])
            {
            }
            column(CompanyAddr_5_; CompanyAddr[5])
            {
            }
            column(CompanyAddr_4_; CompanyAddr[4])
            {
            }
            column(CompanyAddr_2_; CompanyAddr[2])
            {
            }
            column(CompanyAddr_3_; CompanyAddr[3])
            {
            }
            column(CompanyAddr_1_; CompanyAddr[1])
            {
            }
            column(PaymtHeader__Bank_Post_Code_; PaymtHeader."Bank Post Code")
            {
            }
            column(CONVERTSTR_FORMAT_PaymtHeader__RIB_Key__2_______0__; ConvertStr(Format(PaymtHeader."RIB Key", 2), ' ', '0'))
            {
            }
            column(PostingDate; Format(PostingDate))
            {
            }
            column(FORMAT_Amount_0___Precision_2___Standard_Format_0___; '****' + Format(Amount, 0, '<Precision,2:><Standard Format,0>'))
            {
            }
            column(FORMAT_Amount_0___Precision_2___Standard_Format_0____Control1120051; '****' + Format(Amount, 0, '<Precision,2:><Standard Format,0>'))
            {
            }
            column(BillReference; BillReference)
            {
            }
            column(IssueCity; Issue_City)
            {
            }
            column(AmountText; AmountText)
            {
            }
            column(IssueDate; Format(Issue_Date))
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
            column(PaymtHeader__Bank_Name_; PaymtHeader."Bank Name")
            {
            }
            column(Payment_Line__Due_Date_; Format("Due Date"))
            {
            }
            column(Payment_Line_No_; "No.")
            {
            }
            column(Payment_Line_Line_No_; "Line No.")
            {
            }
            column(OK_FOR_ENDORSMENTCaption; OK_FOR_ENDORSMENTCaptionLbl)
            {
            }
            column(of_SUBSCRIBERCaption; of_SUBSCRIBERCaptionLbl)
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
            column(SUBSCRIBER_S_R_I_B_Caption; SUBSCRIBER_S_R_I_B_CaptionLbl)
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
            column(DRAFTCaption; DRAFTCaptionLbl)
            {
            }
            column(SUBSCRIBER_REF_Caption; SUBSCRIBER_REF_CaptionLbl)
            {
            }
            column(DRAFTCaption_Control1120002; DRAFTCaption_Control1120002Lbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                GLSetup.Get();

                PaymtHeader.Get("No.");

                PostingDate := PaymtHeader."Posting Date";

                GLSetup.Get();
                if Issue_Date = 0D then
                    Issue_Date := WorkDate();

                FormatAddress.Company(CompanyAddr, CompanyInfo);

                if "Currency Code" = '' then
                    AmountText := Text001Lbl + ' â‚¬'
                else
                    AmountText := Text001Lbl + ' ' + "Currency Code";
            end;

            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                CompanyInfo.TestField("Default Bank Account No.");
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
                        ToolTip = 'Specifies the name of the city where the promissory note will be issued.';
                    }
                    field(IssueCity; Issue_City)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issue city';
                        ToolTip = 'Specifies the name of the city where the promissory note will be issued.';
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
        Against_the_present_DRAFT_noted_as_NO_CHARGES__we_will_pay_the_indicated_sum_below_toCaption = 'Against the present DRAFT noted as NO CHARGES, we will pay the indicated sum below to :';
    }

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        PaymtHeader: Record "Payment Header FR";
        FormatAddress: Codeunit "Format Address";
        CompanyAddr: array[8] of Text[100];
        Issue_City: Text[30];
        Issue_Date: Date;
        BillReference: Code[10];
        PostingDate: Date;
        Text001Lbl: Label 'Amount';
        AmountText: Text[30];
        OK_FOR_ENDORSMENTCaptionLbl: Label 'OK FOR ENDORSMENT';
        of_SUBSCRIBERCaptionLbl: Label 'of SUBSCRIBER', Comment = 'NAME and ADDRESS of SUBSCRIBER';
        Stamp_Allow_and_SignatureCaptionLbl: Label 'Stamp Allow and Signature';
        ADDRESSCaptionLbl: Label 'ADDRESS';
        NAME_andCaptionLbl: Label 'NAME and';
        Value_in__CaptionLbl: Label 'Value in :';
        SUBSCRIBER_S_R_I_B_CaptionLbl: Label 'SUBSCRIBER''S R.I.B.';
        DOMICILIATIONCaptionLbl: Label 'DOMICILIATION', Comment = 'Translate domiciliation and uppecase the result';
        TOCaptionLbl: Label 'TO';
        ONCaptionLbl: Label 'ON';
        AMOUNT_FOR_CONTROLCaptionLbl: Label 'AMOUNT FOR CONTROL';
        CREATION_DATECaptionLbl: Label 'CREATION DATE';
        DUE_DATECaptionLbl: Label 'DUE DATE';
        DRAFTCaptionLbl: Label 'DRAFT';
        SUBSCRIBER_REF_CaptionLbl: Label 'SUBSCRIBER REF.';
        DRAFTCaption_Control1120002Lbl: Label 'DRAFT', Comment = 'Translate draft and uppecase the result';
}

