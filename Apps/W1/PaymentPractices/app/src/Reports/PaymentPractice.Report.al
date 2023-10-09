// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

report 685 "Payment Practice"
{
    ApplicationArea = All;
    DefaultRenderingLayout = PaymentPractice_PeriodLayout;

    dataset
    {
        dataitem(PaymentPracticeHeader; "Payment Practice Header")
        {
            column(Header_Caption; TableCaption()) { }
            column(Header_No; "No.") { }
            column(Starting_Date; Format("Starting Date")) { }
            column(Starting_Date_Caption; FieldCaption("Starting Date")) { }
            column(Ending_Date; Format("Ending Date")) { }
            column(Ending_Date_Caption; FieldCaption("Ending Date")) { }
            column(Aggregation_Type; "Aggregation Type") { }
            column(Aggregation_Type_Caption; FieldCaption("Aggregation Type")) { }
            column(Header_Type; "Header Type") { }
            column(Header_Type_Caption; FieldCaption("Header Type")) { }
            column(Average_Agreed_Payment_Period; "Average Agreed Payment Period") { }
            column(Average_Agreed_Payment_Period_Caption; FieldCaption("Average Agreed Payment Period")) { }
            column(Average_Actual_Payment_Period; "Average Actual Payment Period") { }
            column(Average_Actual_Payment_Period_Caption; FieldCaption("Average Actual Payment Period")) { }
            column(Pct_Paid_on_Time; "Pct Paid on Time") { }
            column(Pct_Paid_on_Time_Caption; FieldCaption("Pct Paid on Time")) { }

            dataitem(PaymentPracticeLine; "Payment Practice Line")
            {
                DataItemLink = "Header No." = field("No.");
                DataItemLinkReference = PaymentPracticeHeader;
                DataItemTableView = sorting("Header No.", "Line No.");

                column(Line_Company_Size_Code; "Company Size Code") { }
                column(Line_Company_Size_Code_Caption; FieldCaption("Company Size Code")) { }
                column(Line_Source_Type; "Source Type") { }
                column(Line_Source_Type_Caption; FieldCaption("Source Type")) { }
                column(Line_Payment_Period_Code; "Payment Period Code") { }
                column(Line_Payment_Period_Code_Caption; FieldCaption("Payment Period Code")) { }
                column(Line_Average_Agreed_Payment_Period; "Average Agreed Payment Period") { }
                column(Line_Average_Agreed_Payment_Period_Caption; FieldCaption("Average Agreed Payment Period")) { }
                column(Line_Average_Actual_Payment_Period; "Average Actual Payment Period") { }
                column(Line_Average_Actual_Payment_Period_Caption; FieldCaption("Average Actual Payment Period")) { }
                column(Line_Pct_Paid_on_Time; "Pct Paid on Time") { }
                column(Line_Pct_Paid_on_Time_Caption; FieldCaption("Pct Paid on Time")) { }
                column(Line_Pct_Paid_in_Period; "Pct Paid in Period") { }
                column(Line_Pct_Paid_in_Period_Caption; FieldCaption("Pct Paid in Period")) { }
                column(Line_Pct_Paid_in_Period__Amount_; "Pct Paid in Period (Amount)") { }
                column(Line_Pct_Paid_in_Period__Amount__Caption; FieldCaption("Pct Paid in Period (Amount)")) { }
                column(Line_Payment_Period_Description; "Payment Period Description") { }
                column(Line_Payment_Period_Description_Caption; FieldCaption("Payment Period Description")) { }
            }
        }
    }

    rendering
    {
        layout(PaymentPractice_PeriodLayout)
        {
            Type = Word;
            Caption = 'Payment Practice by Period';
            Summary = 'Payment Practice by Period';
            LayoutFile = 'src/Reports/Payment Practice by Period.docx';
        }
        layout(PaymentPractice_VendorSizeLayout)
        {
            Type = Word;
            Caption = 'Payment Practice by Vendor Size';
            Summary = 'Payment Practice by Vendor Size';
            LayoutFile = 'src/Reports/Payment Practice by Vendor Size.docx';
        }
    }
}
