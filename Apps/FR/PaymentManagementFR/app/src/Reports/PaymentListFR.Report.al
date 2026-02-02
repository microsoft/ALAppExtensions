// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

report 10845 "Payment List FR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/PaymentList.rdlc';
    Caption = 'Payment List';

    dataset
    {
        dataitem("Payment Line"; "Payment Line FR")
        {
            DataItemTableView = sorting("No.", "Line No.");
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Payment lines';
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(USERID; UserId)
            {
            }
            column(Payment_Line__No__; "No.")
            {
            }
            column(Payment_Line__No___Control1120011; "No.")
            {
            }
            column(Payment_Line_Amount; Amount)
            {
            }
            column(Payment_Line__Account_Type_; "Account Type")
            {
            }
            column(Payment_Line__Account_No__; "Account No.")
            {
            }
            column(Payment_Line__Posting_Group_; "Posting Group")
            {
            }
            column(Payment_Line__Due_Date_; Format("Due Date"))
            {
            }
            column(Payment_Line_Line_No_; "Line No.")
            {
            }
            column(Payments_LinesCaption; Payments_LinesCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Payment_Line__No___Control1120011Caption; FieldCaption("No."))
            {
            }
            column(Payment_Line_AmountCaption; FieldCaption(Amount))
            {
            }
            column(Payment_Line__Account_Type_Caption; FieldCaption("Account Type"))
            {
            }
            column(Payment_Line__Account_No__Caption; FieldCaption("Account No."))
            {
            }
            column(Payment_Line__Posting_Group_Caption; FieldCaption("Posting Group"))
            {
            }
            column(Payment_Line__Due_Date_Caption; Payment_Line__Due_Date_CaptionLbl)
            {
            }
            column(Payment_Line__No__Caption; FieldCaption("No."))
            {
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Payments_LinesCaptionLbl: Label 'Payments Lines';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Payment_Line__Due_Date_CaptionLbl: Label 'Due Date';
}

