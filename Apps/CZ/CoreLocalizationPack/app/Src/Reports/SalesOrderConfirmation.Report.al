report 31187 "Sales Order Confirmation CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/SalesOrderConfirmation.rdl';
    Caption = 'Sales Order Confirmation';
    PreviewMode = PrintLayout;
    WordMergeDataItem = "Sales Header";

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
        dataitem("Sales Header"; "Sales Header")
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
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(UoMLbl; UoMLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
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
            column(No_SalesHeader; "No.")
            {
            }
            column(VATRegistrationNo_SalesHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_SalesHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_SalesHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_SalesHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_SalesHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_SalesHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_SalesHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_SalesHeader; "IBAN CZL")
            {
            }
            column(BIC_SalesHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(BIC_SalesHeader; "SWIFT Code CZL")
            {
            }
            column(OrderDate_SalesHeaderCaption; FieldCaption("Order Date"))
            {
            }
            column(OrderDate_SalesHeader; "Order Date")
            {
            }
            column(ShipmentDate_SalesHeaderCaption; FieldCaption("Shipment Date"))
            {
            }
            column(ShipmentDate_SalesHeader; "Shipment Date")
            {
            }
            column(PaymentTerms; PaymentTerms.Description)
            {
            }
            column(PaymentMethod; PaymentMethod.Description)
            {
            }
            column(YourReference_SalesHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_SalesHeader; "Your Reference")
            {
            }
            column(ShipmentMethod; ShipmentMethod.Description)
            {
            }
            column(CurrencyCode_SalesHeader; "Currency Code")
            {
            }
            column(Amount_SalesHeaderCaption; FieldCaption(Amount))
            {
            }
            column(Amount_SalesHeader; Amount)
            {
            }
            column(AmountIncludingVAT_SalesHeaderCaption; FieldCaption("Amount Including VAT"))
            {
            }
            column(AmountIncludingVAT_SalesHeader; "Amount Including VAT")
            {
            }
            column(DueDate_SalesHeaderCaption; FieldCaption("Due Date"))
            {
            }
            column(DueDateFormat_SalesHeader; FormatDate("Due Date"))
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
                    DataItemLink = Code = field("Salesperson Code");
                    DataItemLinkReference = "Sales Header";
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
                dataitem("Sales Line"; "Sales Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Header";
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Order));

                    trigger OnPreDataItem()
                    begin
                        CurrReport.Break();
                    end;
                }
                dataitem(RoundLoop; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(LineNo_SalesLine; "Sales Line"."Line No.")
                    {
                    }
                    column(Type_SalesLine; Format("Sales Line".Type, 0, 2))
                    {
                    }
                    column(No_SalesLineCaption; "Sales Line".FieldCaption("No."))
                    {
                    }
                    column(No_SalesLine; "Sales Line"."No.")
                    {
                    }
                    column(Description_SalesLineCaption; "Sales Line".FieldCaption(Description))
                    {
                    }
                    column(Description_SalesLine; "Sales Line".Description)
                    {
                    }
                    column(Quantity_SalesLineCaption; "Sales Line".FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_SalesLine; "Sales Line".Quantity)
                    {
                    }
                    column(UnitofMeasure_SalesLine; "Sales Line"."Unit of Measure")
                    {
                    }
                    column(UnitPrice_SalesLineCaption; "Sales Line".FieldCaption("Unit Price"))
                    {
                    }
                    column(UnitPrice_SalesLine; "Sales Line"."Unit Price")
                    {
                    }
                    column(LineDiscount_SalesLineCaption; "Sales Line".FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_SalesLine; "Sales Line"."Line Discount %")
                    {
                    }
                    column(VAT_SalesLineCaption; "Sales Line".FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_SalesLine; "Sales Line"."VAT %")
                    {
                    }
                    column(LineAmount_SalesLineCaption; "Sales Line".FieldCaption("Line Amount"))
                    {
                    }
                    column(LineAmount_SalesLine; "Sales Line"."Line Amount")
                    {
                    }
                    column(InvDiscountAmount_SalesLineCaption; "Sales Line".FieldCaption("Inv. Discount Amount"))
                    {
                    }
                    column(InvDiscountAmount_SalesLine; "Sales Line"."Inv. Discount Amount")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempSalesLine.FindSet()
                        else
                            TempSalesLine.Next();

                        "Sales Line" := TempSalesLine;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempSalesLine.Count);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLinkReference = "Sales Header";
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
                    trigger OnPreDataItem()
                    begin
                        SetRange("User ID", UserId);
                    end;
                }
                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        Codeunit.Run(Codeunit::"Sales-Printed", "Sales Header");
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
            var
                TempVATAmountLine: Record "VAT Amount Line" temporary;
                SalesPost: Codeunit "Sales-Post";
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Sales Header");
                FormatDocumentFields("Sales Header");

                Clear(TempSalesLine);
                TempSalesLine.DeleteAll();
                SalesPost.GetSalesLines("Sales Header", TempSalesLine, 0);
                TempSalesLine.CalcVATAmountLines(0, "Sales Header", TempSalesLine, TempVATAmountLine);
                Amount := TempVATAmountLine.GetTotalVATBase();
                "Amount Including VAT" := TempVATAmountLine.GetTotalAmountInclVAT();

                if not IsReportInPreviewMode() then begin
                    if ArchiveDocument then
                        ArchiveManagement.StoreSalesDocument("Sales Header", LogInteraction);
                    if LogInteraction then begin
                        CalcFields("No. of Archived Versions");
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", Database::Contact, "Bill-to Contact No."
                              , "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", Database::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
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
                        ToolTip = 'Specifies if you want the program to record the order confirmation you print as Interactions and add them to the Interaction Log Entry table.';

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
            ArchiveDocument := "Sales & Receivables Setup"."Archive Orders";
            InitLogInteraction();
            LogInteractionEnable := LogInteraction;
        end;
    }
    trigger OnInitReport()
    begin
        "Sales & Receivables Setup".Get();
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        ShipmentMethod: Record "Shipment Method";
        TempSalesLine: Record "Sales Line" temporary;
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        ArchiveDocument: Boolean;
        LogInteractionEnable: Boolean;
        DocumentLbl: Label 'Order Confirmation';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        ShipmentMethodLbl: Label 'Shipment Method';
        SalespersonLbl: Label 'Salesperson';
        UoMLbl: Label 'UoM';
        CreatorLbl: Label 'Posted by';
        SubtotalLbl: Label 'Subtotal';
        DiscPercentLbl: Label 'Discount %';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        GreetingLbl: Label 'Hello';
        ClosingLbl: Label 'Sincerely';
        BodyLbl: Label 'Thank you for your business. Your order confirmation is attached to this message.';
        DocumentNoLbl: Label 'No.';

    procedure InitializeRequest(NoOfCopiesFrom: Integer; ArchiveDocumentFrom: Boolean; LogInteractionFrom: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        ArchiveDocument := ArchiveDocumentFrom;
        LogInteraction := LogInteractionFrom;
    end;

    local procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Ord. Cnfrmn.") <> '';
    end;

    local procedure FormatDocumentFields(SalesHeader: Record "Sales Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesHeader."Payment Terms Code", SalesHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesHeader."Shipment Method Code", SalesHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, SalesHeader."Payment Method Code", SalesHeader."Language Code");
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(SalesHeader."Language Code");
    end;

    local procedure FormatAddressFields(SalesHeader: Record "Sales Header")
    begin
        FormatAddress.SalesHeaderBillTo(CustAddr, SalesHeader);
        FormatAddress.SalesHeaderShipTo(ShipToAddr, CustAddr, SalesHeader);
    end;

    local procedure FormatDate(DateValue: Date): Text
    begin
        exit(Format(DateValue, 0, '<Day>.<Month>.<Year4>'));
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
