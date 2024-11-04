// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31182 "Reminder CZL"
{
    Caption = 'Reminder';
    PreviewMode = PrintLayout;
    DefaultRenderingLayout = "Reminder.rdl";
    WordMergeDataItem = "Issued Reminder Header";

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(RegistrationNo_CompanyInformation; "Registration No.")
            {
            }
            column(VATRegistrationNo_CompanyInformation; "VAT Registration No.")
            {
            }
            column(HomePage_CompanyInformation; "Home Page")
            {
            }
            column(Picture_CompanyInformation; Picture)
            {
            }
            dataitem("Sales & Receivables Setup"; "Sales & Receivables Setup")
            {
                DataItemTableView = sorting("Primary Key");
                column(LogoPositiononDocuments_SalesReceivablesSetup; Format("Logo Position on Documents", 0, 2))
                {
                }
                dataitem("General Ledger Setup"; "General Ledger Setup")
                {
                    DataItemTableView = sorting("Primary Key");
                    column(LCYCode_GeneralLedgerSetup; "LCY Code")
                    {
                    }
                }
            }
            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
            end;
        }
        dataitem("Issued Reminder Header"; "Issued Reminder Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(DocumentLbl; DocumentLbl)
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(CopyLbl; CopyLbl)
            {
            }
            column(VendorLbl; VendLbl)
            {
            }
            column(CustomerLbl; CustLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(No_IssuedReminderHeader; "No.")
            {
            }
            column(VATRegistrationNo_IssuedReminderHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_IssuedReminderHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_IssuedReminderHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_IssuedReminderHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_IssuedReminderHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_IssuedReminderHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_IssuedReminderHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_IssuedReminderHeader; "IBAN CZL")
            {
            }
            column(SWIFTCode_IssuedReminderHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(SWIFTCode_IssuedReminderHeader; "SWIFT Code CZL")
            {
            }
            column(CustomerNo_IssuedReminderHeaderCaption; FieldCaption("Customer No."))
            {
            }
            column(CustomerNo_IssuedReminderHeader; "Customer No.")
            {
            }
            column(PostingDate_IssuedReminderHeaderCaption; FieldCaption("Posting Date"))
            {
            }
            column(PostingDate_IssuedReminderHeader; Format("Posting Date"))
            {
            }
            column(DocumentDate_IssuedReminderHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_IssuedReminderHeader; Format("Document Date"))
            {
            }
            column(CurrencyCode_IssuedReminderHeader; "Currency Code")
            {
            }
            column(Contact_IssuedReminderHeader; Contact)
            {
            }
            column(DocFooterText; DocFooterText)
            {
            }
            column(CustAddr1; CustAddr[1])
            {
            }
            column(CustAddr2; CustAddr[2])
            {
            }
            column(CustAddr3; CustAddr[3])
            {
            }
            column(CustAddr4; CustAddr[4])
            {
            }
            column(CustAddr5; CustAddr[5])
            {
            }
            column(CustAddr6; CustAddr[6])
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(CopyNo; Number)
                {
                }
                dataitem("Issued Reminder Line"; "Issued Reminder Line")
                {
                    DataItemLink = "Reminder No." = field("No.");
                    DataItemLinkReference = "Issued Reminder Header";
                    DataItemTableView = sorting("Reminder No.", "Line No.");
                    column(TotalLbl; TotalLbl)
                    {
                    }
                    column(DocumentDate_IssuedReminderLineCaption; FieldCaption("Document Date"))
                    {
                    }
                    column(DocumentDate_IssuedReminderLine; Format("Document Date"))
                    {
                    }
                    column(DocumentType_IssuedReminderLineCaption; FieldCaption("Document Type"))
                    {
                    }
                    column(DocumentType_IssuedReminderLine; "Document Type")
                    {
                    }
                    column(DocumentNo_IssuedReminderLineCaption; FieldCaption("Document No."))
                    {
                    }
                    column(DocumentNo_IssuedReminderLine; "Document No.")
                    {
                    }
                    column(DueDate_IssuedReminderLineCaption; FieldCaption("Due Date"))
                    {
                    }
                    column(DueDate_IssuedReminderLine; Format("Due Date"))
                    {
                    }
                    column(OriginalAmount_IssuedReminderLineCaption; FieldCaption("Original Amount"))
                    {
                    }
                    column(OriginalAmount_IssuedReminderLine; "Original Amount")
                    {
                    }
                    column(RemainingAmount_IssuedReminderLineCaption; FieldCaption("Remaining Amount"))
                    {
                    }
                    column(RemainingAmount_IssuedReminderLine; "Remaining Amount")
                    {
                    }
                    column(Description_IssuedReminderLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_IssuedReminderLine; Description)
                    {
                    }
                    column(Type_IssuedReminderLine; Format(Type, 0, 2))
                    {
                    }
                    column(LineType_IssuedReminderLine; Format("Line Type", 0, 2))
                    {
                    }
                    column(LineNo_IssuedReminderLine; "Line No.")
                    {
                    }
                    column(AmountInclVAT; AmountInclVAT)
                    {
                    }
                    column(LineAmountText; LineAmountText)
                    {
                    }
                    column(InterestAmountLbl; InterestAmountLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        RemainingAmount: Decimal;
                        ReminderInterestAmount: Decimal;
                    begin
                        LineAmountText := '';
                        ReminderInterestAmount := 0;
                        RemainingAmount := "Remaining Amount";
                        AmountInclVAT := Amount + "VAT Amount";

                        case Type of
                            Type::"G/L Account":
                                RemainingAmount := AmountInclVAT;
                            Type::"Line Fee":
                                RemainingAmount := AmountInclVAT;
                            Type::"Customer Ledger Entry":
                                ReminderInterestAmount := AmountInclVAT;
                        end;

                        LineAmount := ReminderInterestAmount + RemainingAmount;
                        TotalLineAmount += LineAmount;

                        if LineAmount = 0 then
                            LineAmountText := ''
                        else
                            LineAmountText := Format(LineAmount);
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter("Line Type", '<>%1&<>%2', "Line Type"::"Not Due", "Line Type"::"On Hold");
                        SetRange("Detailed Interest Rates Entry", false);
                    end;
                }
                dataitem(NotDueLine; "Issued Reminder Line")
                {
                    DataItemLink = "Reminder No." = field("No.");
                    DataItemLinkReference = "Issued Reminder Header";
                    DataItemTableView = sorting("Reminder No.", "Line No.");
                    column(DocumentDate_NotDueLine; Format("Document Date"))
                    {
                    }
                    column(DocumentType_NotDueLine; "Document Type")
                    {
                    }
                    column(DocumentNo_NotDueLine; "Document No.")
                    {
                    }
                    column(DueDate_NotDueLine; Format("Due Date"))
                    {
                    }
                    column(OriginalAmount_NotDueLine; "Original Amount")
                    {
                    }
                    column(RemainingAmount_NotDueLine; "Remaining Amount")
                    {
                    }
                    column(Description_NotDueLine; Description)
                    {
                    }
                    column(Type_NotDueLine; Format(Type, 0, 2))
                    {
                    }
                    column(LineType_NotDueLine; Format("Line Type", 0, 2))
                    {
                    }
                    column(LineNo_NotDueLine; "Line No.")
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        if not ShowNotDueAmounts then
                            CurrReport.Break();

                        SetFilter("Line Type", '%1|%2', "Line Type"::"Not Due", "Line Type"::"On Hold");
                    end;
                }
                dataitem(LineSum; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(GreetingLbl; GreetingLbl)
                    {
                    }
                    column(AmtDueLbl; AmtDueTxt)
                    {
                    }
                    column(BodyLbl; BodyLbl)
                    {
                    }
                    column(ClosingLbl; ClosingLbl)
                    {
                    }
                    column(TotalLineAmount; TotalLineAmount)
                    {
                    }
                    column(GreetingText; GreetingTxt)
                    {
                    }
                    column(BodyText; BodyTxt)
                    {
                    }
                    column(ClosingText; ClosingTxt)
                    {
                    }
                    column(DescriptionText; DescriptionTxt)
                    {
                    }
                    trigger OnPreDataItem()
                    var
                        ReminderCommunication: Codeunit "Reminder Communication";
                    begin
                        ReminderCommunication.PopulateEmailText("Issued Reminder Header", "Company Information", GreetingTxt, AmtDueTxt, BodyTxt, ClosingTxt, DescriptionTxt, TotalLineAmount);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Issued Reminder Header";
                    DataItemTableView = sorting("User ID");
                    dataitem(Employee; Employee)
                    {
                        DataItemLink = "No." = field("Employee No. CZL");
                        DataItemTableView = sorting("No.");
                        column(FullName_Employee; FullName())
                        {
                        }
                        column(PhoneNo_Employee; "Phone No.")
                        {
                        }
                        column(CompanyEMail_Employee; "Company E-Mail")
                        {
                        }
                    }
                }
                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        "Issued Reminder Header".IncrNoPrinted();
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;

                trigger OnAfterGetRecord()
                begin
                    TotalLineAmount := 0;
                end;
            }

            trigger OnPreDataItem()
            begin
                AmtDueTxt := '';
            end;

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddress.IssuedReminder(CustAddr, "Issued Reminder Header");
                DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText("Language Code");

                if LogInteraction and not IsReportInPreviewMode() then
                    SegManagement.LogDocument(
                      8, "No.", 0, 0, Database::Customer, "Customer No.", '', '', "Posting Description", '');

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";

                if Format("Due Date") <> '' then
                    AmtDueTxt := StrSubstNo(AmtDueLbl, "Due Date");
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
                    field(NoOfCopiesCZL; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                    field(LogInteractionCZL; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the reminder you print as Interactions and add them to the Interaction Log Entry table.';
                    }
                    field(ShowNotDueAmountsCZL; ShowNotDueAmounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Not Due Amounts';
                        ToolTip = 'Specifies if you want to show amounts that are not due from customers.';
                    }
                }
            }
        }
        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction();
            LogInteractionEnable := LogInteraction;
        end;
    }

    rendering
    {
        layout("Reminder.rdl")
        {
            Type = RDLC;
            LayoutFile = './Src/Reports/Reminder.rdl';
            Caption = 'Reminder (RDL)';
            Summary = 'The Reminder (RDL) provides a detailed layout.';
        }
        layout("ReminderEmail.docx")
        {
            Type = Word;
            LayoutFile = './Src/Reports/ReminderEmail.docx';
            Caption = 'Reminder Email (Word)';
            Summary = 'The Reminder Email (Word) provides an email body layout.';
        }
    }

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        LogInteractionEnable: Boolean;
        TotalLbl: Label 'Total';
        DocumentLbl: Label 'Reminder';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        CreatorLbl: Label 'Created by';
        InterestAmountLbl: Label 'Interest Amount';
        GreetingLbl: Label 'Hello';
        AmtDueLbl: Label 'You are receiving this email to formally notify you that payment owed by you is past due. The payment was due on %1. Enclosed is a copy of invoice with the details of remaining amount.', Comment = '%1 = A due date';
        BodyLbl: Label 'If you have already made the payment, please disregard this email. Thank you for your business.';
        ClosingLbl: Label 'Sincerely';

    protected var
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        ShowNotDueAmounts: Boolean;
        AmtDueTxt: Text;
        GreetingTxt: Text;
        BodyTxt: Text;
        ClosingTxt: Text;
        DescriptionTxt: Text;
        LineAmountText: Text;
        AmountInclVAT: Decimal;
        LineAmount: Decimal;
        TotalLineAmount: Decimal;

    procedure InitializeRequest(NoOfCopiesFrom: Integer; LogInteractionFrom: Boolean; ShowNotDueAmountsFrom: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        LogInteraction := LogInteractionFrom;
        ShowNotDueAmounts := ShowNotDueAmountsFrom;
    end;

    local procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Rmdr.") <> '';
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
