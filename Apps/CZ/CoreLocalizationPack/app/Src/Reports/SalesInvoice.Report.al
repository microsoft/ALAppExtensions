report 31189 "Sales Invoice CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/SalesInvoice.rdl';
    Caption = 'Sales Invoice';
    PreviewMode = PrintLayout;

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
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
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
            column(VATIdentLbl; VATIdentLbl)
            {
            }
            column(VATPercentLbl; VATPercentLbl)
            {
            }
            column(VATBaseLbl; VATBaseLbl)
            {
            }
            column(VATAmtLbl; VATAmtLbl)
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(VATLbl; VATLbl)
            {
            }
            column(PrepayedLbl; PrepayedLbl)
            {
            }
            column(TotalAfterPrepayedLbl; TotalAfterPrepayedLbl)
            {
            }
            column(PaymentsLbl; PaymentsLbl)
            {
            }
            column(DisplayAdditionalFeeNote; DisplayAdditionalFeeNote)
            {
            }
            column(No_SalesInvoiceHeader; "No.")
            {
            }
            column(VATRegistrationNo_SalesInvoiceHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_SalesInvoiceHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_SalesInvoiceHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_SalesInvoiceHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_SalesInvoiceHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_SalesInvoiceHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_SalesInvoiceHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_SalesInvoiceHeader; "IBAN CZL")
            {
            }
            column(BIC_SalesInvoiceHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(BIC_SalesInvoiceHeader; "SWIFT Code CZL")
            {
            }
            column(PostingDate_SalesInvoiceHeaderCaption; FieldCaption("Posting Date"))
            {
            }
            column(PostingDate_SalesInvoiceHeader; "Posting Date")
            {
            }
            column(VATDate_SalesInvoiceHeaderCaption; FieldCaption("VAT Date CZL"))
            {
            }
            column(VATDate_SalesInvoiceHeader; "VAT Date CZL")
            {
            }
            column(DueDate_SalesInvoiceHeaderCaption; FieldCaption("Due Date"))
            {
            }
            column(DueDate_SalesInvoiceHeader; "Due Date")
            {
            }
            column(DocumentDate_SalesInvoiceHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_SalesInvoiceHeader; "Document Date")
            {
            }
            column(PmntSymbol1; PaymentSymbolLabel[1])
            {
            }
            column(PmntSymbol2; PaymentSymbol[1])
            {
            }
            column(PmntSymbol3; PaymentSymbolLabel[2])
            {
            }
            column(PmntSymbol4; PaymentSymbol[2])
            {
            }
            column(PaymentTerms; PaymentTerms.Description)
            {
            }
            column(PaymentMethod; PaymentMethod.Description)
            {
            }
            column(ReasonCode; ReasonCode.Description)
            {
            }
            column(OrderNo_SalesInvoiceHeaderCaption; FieldCaption("Order No."))
            {
            }
            column(OrderNo_SalesInvoiceHeader; "Order No.")
            {
            }
            column(YourReference_SalesInvoiceHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_SalesInvoiceHeader; "Your Reference")
            {
            }
            column(ShipmentMethod; ShipmentMethod.Description)
            {
            }
            column(CurrencyCode_SalesInvoiceHeader; "Currency Code")
            {
            }
            column(Amount_SalesInvoiceHeaderCaption; FieldCaption(Amount))
            {
            }
            column(Amount_SalesInvoiceHeader; Amount)
            {
            }
            column(AmountIncludingVAT_SalesInvoiceHeaderCaption; FieldCaption("Amount Including VAT"))
            {
            }
            column(AmountIncludingVAT_SalesInvoiceHeader; "Amount Including VAT")
            {
            }
#if not CLEAN19
            column(PrepaymentAmt_SalesInvoiceHeader; PrepaymentAmt)
            {
            }
#endif
            column(CalculatedExchRate; CalculatedExchRate)
            {
            }
            column(ExchRateText; ExchRateText)
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
                    DataItemLinkReference = "Sales Invoice Header";
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
                dataitem("Sales Invoice Line"; "Sales Invoice Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Invoice Header";
                    DataItemTableView = sorting("Document No.", "Line No.") WHERE("Prepayment Line" = CONST(false));
                    column(LineNo_SalesInvoiceLine; "Line No.")
                    {
                    }
                    column(Type_SalesInvoicetLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_SalesInvoiceLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_SalesInvoiceLine; "No.")
                    {
                    }
                    column(Description_SalesInvoiceLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_SalesInvoiceLine; Description)
                    {
                    }
                    column(Quantity_SalesInvoiceLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_SalesInvoiceLine; Quantity)
                    {
                    }
                    column(UnitofMeasure_SalesInvoiceLine; "Unit of Measure")
                    {
                    }
                    column(UnitPrice_SalesInvoiceLineCaption; UnitPriceExclVATLbl)
                    {
                    }
                    column(UnitPrice_SalesInvoiceLine; UnitPriceExclVAT)
                    {
                    }
                    column(LineDiscount_SalesInvoiceLineCaption; FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_SalesInvoiceLine; "Line Discount %")
                    {
                    }
                    column(VAT_SalesInvoiceLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_SalesInvoiceLine; "VAT %")
                    {
                    }
                    column(LineAmount_SalesInvoiceLineCaption; FieldCaption("Line Amount"))
                    {
                    }
                    column(LineAmount_SalesInvoiceLine; "Line Amount")
                    {
                    }
                    column(InvDiscountAmount_SalesInvoiceLineCaption; FieldCaption("Inv. Discount Amount"))
                    {
                    }
                    column(InvDiscountAmount_SalesInvoiceLine; "Inv. Discount Amount")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        UnitPriceExclVAT := 100 * "Sales Invoice Line"."Unit Price" / (100 + "Sales Invoice Line"."VAT %");
                    end;
                }
#if CLEAN19
                dataitem(SalesInvoiceAdvance; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(LetterNo_SalesInvoiceAdvanceCaption; '')
                    {
                    }
                    column(LetterNo_SalesInvoiceAdvance; '')
                    {
                    }
                    column(AmountIncludingVAT_SalesInvoiceAdvance; '')
                    {
                    }
                    column(VATDocLetterNo_SalesInvoiceAdvanceCaption; '')
                    {
                    }
                    column(VATDocLetterNo_SalesInvoiceAdvance; '')
                    {
                    }
                    column(PostingDate_SalesInvoiceAdvance; '')
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, 0);
                    end;
                }
#else
#pragma warning disable AL0432
                dataitem(SalesInvoiceAdvance; "Sales Invoice Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Invoice Header";
                    DataItemTableView = sorting("Document No.", "Line No.") WHERE("Prepayment Line" = CONST(true), "Letter No." = FILTER(<> ''));
                    column(LetterNo_SalesInvoiceAdvanceCaption; FieldCaption("Letter No."))
                    {
                    }
                    column(LetterNo_SalesInvoiceAdvance; "Letter No.")
                    {
                    }
                    column(AmountIncludingVAT_SalesInvoiceAdvance; "Amount Including VAT")
                    {
                    }
                    column(VATDocLetterNo_SalesInvoiceAdvanceCaption; FieldCaption("VAT Doc. Letter No."))
                    {
                    }
                    column(VATDocLetterNo_SalesInvoiceAdvance; "VAT Doc. Letter No.")
                    {
                    }
                    column(PostingDate_SalesInvoiceAdvance; SalesInvoiceHeader."Posting Date")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if "VAT Doc. Letter No." <> '' then
                            if not SalesInvoiceHeader.Get("VAT Doc. Letter No.") then
                                SalesInvoiceHeader.Init();
                    end;
                }
#pragma warning restore AL0432
#endif
                dataitem(VATCounter; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(VATAmtLineVATIdentifier; TempVATAmountLine."VAT Identifier")
                    {
                    }
                    column(VATAmtLineVATPer; TempVATAmountLine."VAT %")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                    {
                        AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATBaseLCY; TempVATAmountLine."VAT Base (LCY) CZL")
                    {
                        AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmtLCY; TempVATAmountLine."VAT Amount (LCY) CZL")
                    {
                        AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem(VATClauseEntryCounter; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(VATClauseIdentifier; TempVATAmountLine."VAT Identifier")
                    {
                    }
                    column(VATClauseDescription; VATClause.Description)
                    {
                    }
                    column(VATClauseDescription2; VATClause."Description 2")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                        if not VATClause.Get(TempVATAmountLine."VAT Clause Code") then
                            CurrReport.Skip();
                        VATClause.GetDescription("Sales Invoice Header");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem(LineFee; "Integer")
                {
                    DataItemTableView = sorting(Number) ORDER(Ascending) WHERE(Number = FILTER(1 ..));
                    column(LineFeeCaptionLbl; TempLineFeeNoteonReportHist.ReportText)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TempLineFeeNoteonReportHist.FindSet() then
                                CurrReport.Break()
                        end else
                            if TempLineFeeNoteonReportHist.Next() = 0 then
                                CurrReport.Break();
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not DisplayAdditionalFeeNote then
                            CurrReport.Break();
                        SetRange(Number, 1, TempLineFeeNoteonReportHist.Count);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Sales Invoice Header";
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
                        Codeunit.Run(Codeunit::"Sales Inv.-Printed", "Sales Invoice Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + Customer."Invoice Copies" + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }
            trigger OnAfterGetRecord()
            var
                SalesInvLine: Record "Sales Invoice Line";
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");

                FormatAddressFields("Sales Invoice Header");
                FormatDocumentFields("Sales Invoice Header");
                if not Customer.Get("Bill-to Customer No.") then
                    Clear(Customer);

                SalesInvLine.CalcVATAmountLines("Sales Invoice Header", TempVATAmountLine);
                TempVATAmountLine.UpdateVATEntryLCYAmountsCZL("Sales Invoice Header");
                if ("Currency Factor" <> 0) and ("Currency Factor" <> 1) then begin
                    CurrencyExchangeRate.FindCurrency("Posting Date", "Currency Code", 1);
                    CalculatedExchRate := Round(1 / "Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                    ExchRateText := StrSubstNo(ExchRateLbl, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                                        CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                end else
                    CalculatedExchRate := 1;

                SalesInvLine.SetRange("Document No.", "No.");
#if not CLEAN19
#pragma warning disable AL0432
                SalesInvLine.SetFilter("Letter No.", '%1', '');
#pragma warning restore AL0432
#endif
                SalesInvLine.CalcSums(Amount, "Amount Including VAT");
                Amount := SalesInvLine.Amount;
                "Amount Including VAT" := SalesInvLine."Amount Including VAT";
#if not CLEAN19
#pragma warning disable AL0432
                SalesInvLine.SetFilter("Letter No.", '<>%1', '');
                SalesInvLine.CalcSums("Amount Including VAT");
                PrepaymentAmt := SalesInvLine."Amount Including VAT";
#pragma warning restore AL0432
#endif

                GetLineFeeNoteOnReportHist("No.");

                if LogInteraction and not IsReportInPreviewMode() then
                    if "Bill-to Contact No." <> '' then
                        SegManagement.LogDocument(
                          4, "No.", 0, 0, Database::Contact, "Bill-to Contact No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '')
                    else
                        SegManagement.LogDocument(
                          4, "No.", 0, 0, Database::Customer, "Bill-to Customer No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '');

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
                    field(LogInteractionCZL; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the sales invoice you print as Interactions and add them to the Interaction Log Entry table.';
                    }
                    field(DisplayAdditionalFeeNoteCZL; DisplayAdditionalFeeNote)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Additional Fee Note';
                        ToolTip = 'Specifies when the additional fee note is to be show';
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
    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempLineFeeNoteonReportHist: Record "Line Fee Note on Report Hist." temporary;
        Customer: Record Customer;
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        ShipmentMethod: Record "Shipment Method";
        ReasonCode: Record "Reason Code";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        VATClause: Record "VAT Clause";
#if not CLEAN19
        SalesInvoiceHeader: Record "Sales Invoice Header";
#endif
        Language: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        ExchRateText: Text[50];
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        PaymentSymbol: array[2] of Text;
        PaymentSymbolLabel: array[2] of Text;
        DocumentLbl: Label 'Invoice';
        CalculatedExchRate: Decimal;
#if not CLEAN19
        PrepaymentAmt: Decimal;
#endif
        UnitPriceExclVAT: Decimal;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        ExchRateLbl: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1 = Calculated Exchange Rate, %2 = LCY Code, %3 = Exchange Rate, %4 = Currency Code';
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
        VATIdentLbl: Label 'VAT Recapitulation';
        VATPercentLbl: Label 'VAT %';
        VATBaseLbl: Label 'VAT Base';
        VATAmtLbl: Label 'VAT Amount';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        PrepayedLbl: Label 'Prepayed Advances';
        TotalAfterPrepayedLbl: Label 'Total after Prepayed Advances';
        PaymentsLbl: Label 'Payments List';
        UnitPriceExclVATLbl: Label 'Unit Price Excl. VAT';
        [InDataSet]
        LogInteractionEnable: Boolean;
        DisplayAdditionalFeeNote: Boolean;

    procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractTmplCode(4) <> '';
    end;

    local procedure GetLineFeeNoteOnReportHist(SalesInvoiceHeaderNo: Code[20])
    var
        LineFeeNoteonReportHist: Record "Line Fee Note on Report Hist.";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        LanguageCustomer: Record Customer;
    begin
        TempLineFeeNoteonReportHist.DeleteAll();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not CustLedgerEntry.FindFirst() then
            exit;
        if not LanguageCustomer.Get(CustLedgerEntry."Customer No.") then
            exit;

        LineFeeNoteonReportHist.SetRange("Cust. Ledger Entry No", CustLedgerEntry."Entry No.");
        LineFeeNoteonReportHist.SetRange("Language Code", LanguageCustomer."Language Code");
        if LineFeeNoteonReportHist.FindSet() then
            repeat
                TempLineFeeNoteonReportHist.Init();
                TempLineFeeNoteonReportHist.Copy(LineFeeNoteonReportHist);
                TempLineFeeNoteonReportHist.Insert();
            until LineFeeNoteonReportHist.Next() = 0
        else begin
            LineFeeNoteonReportHist.SetRange("Language Code", Language.GetUserLanguageCode());
            if LineFeeNoteonReportHist.FindSet() then
                repeat
                    TempLineFeeNoteonReportHist.Init();
                    TempLineFeeNoteonReportHist.Copy(LineFeeNoteonReportHist);
                    TempLineFeeNoteonReportHist.Insert();
                until LineFeeNoteonReportHist.Next() = 0;
        end;
    end;

    local procedure FormatDocumentFields(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesInvoiceHeader."Payment Terms Code", SalesInvoiceHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesInvoiceHeader."Shipment Method Code", SalesInvoiceHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, SalesInvoiceHeader."Payment Method Code", SalesInvoiceHeader."Language Code");
        if SalesInvoiceHeader."Reason Code" = '' then
            ReasonCode.Init()
        else
            ReasonCode.Get(SalesInvoiceHeader."Reason Code");
        FormatDocumentMgtCZL.SetPaymentSymbols(
          PaymentSymbol, PaymentSymbolLabel,
          SalesInvoiceHeader."Variable Symbol CZL", SalesInvoiceHeader.FieldCaption(SalesInvoiceHeader."Variable Symbol CZL"),
          SalesInvoiceHeader."Constant Symbol CZL", SalesInvoiceHeader.FieldCaption(SalesInvoiceHeader."Constant Symbol CZL"),
          SalesInvoiceHeader."Specific Symbol CZL", SalesInvoiceHeader.FieldCaption(SalesInvoiceHeader."Specific Symbol CZL"));
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(SalesInvoiceHeader."Language Code");
    end;

    local procedure FormatAddressFields(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        FormatAddress.SalesInvBillTo(CustAddr, SalesInvoiceHeader);
        FormatAddress.SalesInvShipTo(ShipToAddr, CustAddr, SalesInvoiceHeader);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
