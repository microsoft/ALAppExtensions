// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31185 "Purchase Order CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PurchaseOrder.rdl';
    Caption = 'Purchase Order';
    PreviewMode = PrintLayout;
    WordMergeDataItem = "Purchase Header";

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
            column(BankAccountNo_CompanyInformation; "Bank Account No.")
            {
            }
            column(IBAN_CompanyInformation; IBAN)
            {
            }
            column(SWIFTCode_CompanyInformation; "SWIFT Code")
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
                    dataitem(UserCreator; "User Setup")
                    {
                        DataItemTableView = sorting("User ID");
                        dataitem(EmployeeCreator; Employee)
                        {
                            DataItemLink = "No." = field("Employee No. CZL");
                            DataItemTableView = sorting("No.");
                            column(CreatedByLbl; CreatedByLbl)
                            {
                            }
                            column(FullName_EmployeeCreator; FullName())
                            {
                            }
                            column(PhoneNo_EmployeeCreator; "Phone No.")
                            {
                            }
                            column(CompanyEMail_EmployeeCreator; "Company E-Mail")
                            {
                            }
                        }
                        trigger OnPreDataItem()
                        begin
                            SetRange("User ID", UserId);
                        end;
                    }
                }
            }
            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
            end;
        }
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
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
            column(ShipToLbl; ShipToLbl)
            {
            }
            column(PaymentTermsLbl; PaymentTermsLbl)
            {
            }
            column(PaymentMethodLbl; PaymentMethodLbl)
            {
            }
            column(ShipmentMethodLbl; ShipmentMethodLbl)
            {
            }
            column(PurchaserLbl; PurchaserLbl)
            {
            }
            column(UoMLbl; UoMLbl)
            {
            }
#if not CLEAN22
            column(CreatorLbl; CreatedByLbl)
            {
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by column CreatedByLbl.';
            }
#endif
            column(SubtotalLbl; SubtotalLbl)
            {
            }
            column(DiscPercentLbl; DiscPercentLbl)
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(VATLbl; VATLbl)
            {
            }
            column(GreetingLbl; GreetingLbl)
            {
            }
            column(BodyLbl; BodyLbl)
            {
            }
            column(ClosingLbl; ClosingLbl)
            {
            }
            column(DocumentNoLbl; DocumentNoLbl)
            {
            }
            column(No_PurchaseHeader; "No.")
            {
            }
            column(VATRegistrationNo_PurchaseHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_PurchaseHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_PurchaseHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_PurchaseHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_PurchaseHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_PurchaseHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_PurchaseHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_PurchaseHeader; "IBAN CZL")
            {
            }
            column(BIC_PurchaseHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(BIC_PurchaseHeader; "SWIFT Code CZL")
            {
            }
            column(DocumentDate_PurchaseHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_PurchaseHeader; Format("Document Date"))
            {
            }
            column(ExpectedReceiptDate_PurchaseHeaderCaption; FieldCaption("Expected Receipt Date"))
            {
            }
            column(ExpectedReceiptDate_PurchaseHeader; Format("Expected Receipt Date"))
            {
            }
            column(OrderDate_PurchaseHeaderCaption; FieldCaption("Order Date"))
            {
            }
            column(OrderDate_PurchaseHeader; Format("Order Date"))
            {
            }
            column(PaymentTerms; PaymentTerms.Description)
            {
            }
            column(PaymentMethod; PaymentMethod.Description)
            {
            }
            column(YourReference_PurchaseHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_PurchaseHeader; "Your Reference")
            {
            }
            column(ShipmentMethod; ShipmentMethod.Description)
            {
            }
            column(CurrencyCode_PurchaseHeader; "Currency Code")
            {
            }
            column(Amount_PurchaseHeaderCaption; FieldCaption(Amount))
            {
            }
            column(Amount_PurchaseHeader; Amount)
            {
            }
            column(AmountIncludingVAT_PurchaseHeaderCaption; FieldCaption("Amount Including VAT"))
            {
            }
            column(AmountIncludingVAT_PurchaseHeader; "Amount Including VAT")
            {
            }
            column(DocFooterText; DocFooterText)
            {
            }
            column(VendAddr1; VendAddr[1])
            {
            }
            column(VendAddr2; VendAddr[2])
            {
            }
            column(VendAddr3; VendAddr[3])
            {
            }
            column(VendAddr4; VendAddr[4])
            {
            }
            column(VendAddr5; VendAddr[5])
            {
            }
            column(VendAddr6; VendAddr[6])
            {
            }
            column(ShipToAddr1; ShipToAddr[1])
            {
            }
            column(ShipToAddr2; ShipToAddr[2])
            {
            }
            column(ShipToAddr3; ShipToAddr[3])
            {
            }
            column(ShipToAddr4; ShipToAddr[4])
            {
            }
            column(ShipToAddr5; ShipToAddr[5])
            {
            }
            column(ShipToAddr6; ShipToAddr[6])
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(CopyNo; Number)
                {
                }
                dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
                {
                    DataItemLink = Code = field("Purchaser Code");
                    DataItemLinkReference = "Purchase Header";
                    DataItemTableView = sorting(Code);
                    column(Name_SalespersonPurchaser; Name)
                    {
                    }
                    column(EMail_SalespersonPurchaser; "E-Mail")
                    {
                    }
                    column(PhoneNo_SalespersonPurchaser; "Phone No.")
                    {
                    }
                }
                dataitem("Purchase Line"; "Purchase Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Purchase Header";
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Order));
                    column(LineNo_PurchaseLine; "Line No.")
                    {
                    }
                    column(Type_PurchaseLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_PurchaseLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_PurchaseLine; "No.")
                    {
                    }
                    column(VendorItemNo_PurchaseLine; "Vendor Item No.")
                    {
                    }
                    column(Description_PurchaseLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_PurchaseLine; Description)
                    {
                    }
                    column(Quantity_PurchaseLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_PurchaseLine; Quantity)
                    {
                    }
                    column(UnitofMeasure_PurchaseLine; "Unit of Measure")
                    {
                    }
                    column(DirectUnitCost_PurchaseLineCaption; FieldCaption("Direct Unit Cost"))
                    {
                    }
                    column(DirectUnitCost_PurchaseLine; "Direct Unit Cost")
                    {
                    }
                    column(LineDiscount_PurchaseLineCaption; FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_PurchaseLine; "Line Discount %")
                    {
                    }
                    column(VAT_PurchaseLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_PurchaseLine; "VAT %")
                    {
                    }
                    column(LineAmount_PurchaseLineCaption; FieldCaption("Line Amount"))
                    {
                    }
                    column(LineAmount_PurchaseLine; "Line Amount")
                    {
                    }
                    column(InvDiscountAmount_PurchaseLineCaption; FieldCaption("Inv. Discount Amount"))
                    {
                    }
                    column(InvDiscountAmount_PurchaseLine; "Inv. Discount Amount")
                    {
                    }
                }
#if not CLEAN22
                dataitem("User Setup"; "User Setup")
                {
                    DataItemTableView = sorting("User ID");
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Replaced by dataitem UserCreator.';
                    dataitem(Employee; Employee)
                    {
                        DataItemLink = "No." = field("Employee No. CZL");
                        DataItemTableView = sorting("No.");
                        ObsoleteState = Pending;
                        ObsoleteTag = '22.0';
                        ObsoleteReason = 'Replaced by dataitem EmployeeCreator.';
                        column(FullName_Employee; FullName())
                        {
                            ObsoleteState = Pending;
                            ObsoleteTag = '22.0';
                            ObsoleteReason = 'Replaced by column FullName_EmployeeCreator.';
                        }
                        column(PhoneNo_Employee; "Phone No.")
                        {
                            ObsoleteState = Pending;
                            ObsoleteTag = '22.0';
                            ObsoleteReason = 'Replaced by column PhoneNo_EmployeeCreator.';
                        }
                        column(CompanyEMail_Employee; "Company E-Mail")
                        {
                            ObsoleteState = Pending;
                            ObsoleteTag = '22.0';
                            ObsoleteReason = 'Replaced by column CompanyEMail_EmployeeCreator.';
                        }
                    }
                    trigger OnPreDataItem()
                    begin
                        SetRange("User ID", UserId);
                    end;
                }
#endif
                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        Codeunit.Run(Codeunit::"Purch.Header-Printed", "Purchase Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Purchase Header");
                FormatDocumentFields("Purchase Header");
                if not Vendor.Get("Buy-from Vendor No.") then
                    Clear(Vendor);

                if not IsReportInPreviewMode() then begin
                    if ArchiveDocument then
                        ArchiveManagement.StorePurchDocument("Purchase Header", LogInteraction);

                    if LogInteraction then begin
                        CalcFields("No. of Archived Versions");
                        SegManagement.LogDocument(
                          13, "No.", "Doc. No. Occurrence", "No. of Archived Versions", Database::Vendor, "Buy-from Vendor No.",
                          "Purchaser Code", '', "Posting Description", '');
                    end;
                end;

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";
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
                    field(NoOfCopiesCZL; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                    field(ArchiveDocumentCZL; ArchiveDocument)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archive Document';
                        ToolTip = 'Specifies if the document will be archived';

                        trigger OnValidate()
                        begin
                            if not ArchiveDocument then
                                LogInteraction := false;
                        end;
                    }
                    field(LogInteractionCZL; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the order you print as Interactions and add them to the Interaction Log Entry table.';

                        trigger OnValidate()
                        begin
                            if LogInteraction then
                                ArchiveDocument := true;
                        end;
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
            ArchiveDocument := PurchasesPayablesSetup."Archive Orders";
            InitLogInteraction();
            LogInteractionEnable := LogInteraction;
        end;
    }
    trigger OnInitReport()
    begin
        PurchasesPayablesSetup.Get();
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        Vendor: Record Vendor;
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        ShipmentMethod: Record "Shipment Method";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        CompanyAddr: array[8] of Text[100];
        VendAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        ArchiveDocument: Boolean;
        LogInteractionEnable: Boolean;
        DocumentLbl: Label 'Order';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        ShipmentMethodLbl: Label 'Shipment Method';
        PurchaserLbl: Label 'Purchaser';
        UoMLbl: Label 'UoM';
        CreatedByLbl: Label 'Created by';
        SubtotalLbl: Label 'Subtotal';
        DiscPercentLbl: Label 'Discount %';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        GreetingLbl: Label 'Hello';
        ClosingLbl: Label 'Sincerely';
        BodyLbl: Label 'The purchase order is attached to this message.';
        DocumentNoLbl: Label 'No.';

    procedure InitializeRequest(NoOfCopiesFrom: Integer; ArchiveDocumentFrom: Boolean; LogInteractionFrom: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        ArchiveDocument := ArchiveDocumentFrom;
        LogInteraction := LogInteractionFrom;
    end;

    local procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Purch. Ord.") <> '';
    end;

    local procedure FormatDocumentFields(PurchaseHeader: Record "Purchase Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, PurchaseHeader."Payment Terms Code", PurchaseHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, PurchaseHeader."Shipment Method Code", PurchaseHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, PurchaseHeader."Payment Method Code", PurchaseHeader."Language Code");
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(PurchaseHeader."Language Code");
    end;

    local procedure FormatAddressFields(PurchaseHeader: Record "Purchase Header")
    begin
        FormatAddress.SetLanguageCode(PurchaseHeader."Language Code");
        FormatAddress.PurchHeaderBuyFrom(VendAddr, PurchaseHeader);
        FormatAddress.PurchHeaderShipTo(ShipToAddr, PurchaseHeader);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
