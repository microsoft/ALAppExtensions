page 11511 "Swiss QR-Bill Manual Print"
{
    Caption = 'Create manual QR-Bill';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "Swiss QR-Bill Buffer";
    SourceTableTemporary = true;
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(SourceDocument; SourceDocumentText)
                {
                    ApplicationArea = All;
                    Caption = 'Source Document';
                    ToolTip = 'Specifies the source document.';
                    Editable = false;
                    Importance = Promoted;
                }
                field(QRBillLayoutCode; "QR-Bill Layout")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the QR-bill layout code.';
                    LookupPageId = "Swiss QR-Bill Layout";
                    Editable = not "Source Record Printed";
                }
                field(FileName; "File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the QR-bill PDF file name.';
                    Importance = Promoted;
                }
                field(LanguageCode; "Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the language code for printing QR-bill captions.';
                }
            }
            group("Payment Information")
            {
                field(IBANType; "IBAN Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the IBAN type.';
                    Editable = not "Source Record Printed";

                    trigger OnValidate()
                    begin
                        "QR-Bill Layout" := '';
                    end;
                }
                field(IBANValue; IBAN)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the IBAN value.';
                    Editable = false;
                }
                field(AmountField; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount.';
                    Editable = not "Source Record Printed";
                    Importance = Promoted;
                }
                field(CurrencyField; Currency)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency code.';
                    Editable = not "Source Record Printed";
                    Importance = Promoted;
                }
                field(PaymentReferenceType; "Payment Reference Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment reference type.';
                    Editable = not "Source Record Printed";

                    trigger OnValidate()
                    begin
                        "QR-Bill Layout" := '';
                    end;
                }
                field(PaymentReference; "Payment Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment reference number.';
                }
            }
            group("Creditor Information")
            {
                Editable = false;
                field(CreditorNameField; "Creditor Name")
                {
                    ToolTip = 'Specifies the creditor''s name.';
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field(CreditorAddress1Field; "Creditor Street Or AddrLine1")
                {
                    ToolTip = 'Specifies the creditor''s street or address line 1.';
                    ApplicationArea = All;
                }
                field(CreditorAddress2Field; "Creditor BuildNo Or AddrLine2")
                {
                    ToolTip = 'Specifies the creditor''s building number or address line 2.';
                    ApplicationArea = All;
                }
                field(CreditorPostalCodeField; "Creditor Postal Code")
                {
                    ToolTip = 'Specifies the creditor''s postal code.';
                    ApplicationArea = All;
                }
                field(CreditorCityField; "Creditor City")
                {
                    ToolTip = 'Specifies the creditor''s city.';
                    ApplicationArea = All;
                }
                field(CreditorCountryField; "Creditor Country")
                {
                    ToolTip = 'Specifies the creditor''s country.';
                    ApplicationArea = All;
                }
                field(CreditorIBAN; CreditorIBANValue)
                {
                    Caption = 'IBAN';
                    ToolTip = 'Specifies the creditor''s IBAN.';
                    ApplicationArea = All;
                }
                field(CreditorQRIBAN; CreditorQRIBANValue)
                {
                    Caption = 'QR-IBAN';
                    ToolTip = 'Specifies the creditor''s QR-IBAN.';
                    ApplicationArea = All;
                }
            }
            group("Debitor Information")
            {
                Editable = not "Source Record Printed";

                field(UltimateDebitorNoField; UltimateDebitorCustomer."No.")
                {
                    Caption = 'Customer';
                    ToolTip = 'Specifies the debitor''s number.';
                    ApplicationArea = All;
                    TableRelation = Customer;

                    trigger OnValidate()
                    begin
                        if UltimateDebitorCustomer."No." <> '' then
                            UltimateDebitorCustomer.Find()
                        else
                            Clear(UltimateDebitorCustomer);
                        SetUltimateDebitorInfo(UltimateDebitorCustomer);
                    end;
                }
                field(UltimateDebitorNameField; "UDebtor Name")
                {
                    ToolTip = 'Specifies the debitor''s name.';
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field(UltimateDebitorAddress1Field; "UDebtor Street Or AddrLine1")
                {
                    ToolTip = 'Specifies the debitor''s street or address line 1.';
                    ApplicationArea = All;
                }
                field(UltimateDebitorAddress2Field; "UDebtor BuildNo Or AddrLine2")
                {
                    ToolTip = 'Specifies the debitor''s building number or address line 2.';
                    ApplicationArea = All;
                }
                field(UltimateDebitorPostalCodeField; "UDebtor Postal Code")
                {
                    ToolTip = 'Specifies the debitor''s postal code.';
                    ApplicationArea = All;
                }
                field(UltimateDebitorCityField; "UDebtor City")
                {
                    ToolTip = 'Specifies the debitor''s city.';
                    ApplicationArea = All;
                }
                field(UltimateDebitorCountryField; "UDebtor Country")
                {
                    ToolTip = 'Specifies the debitor''s country.';
                    ApplicationArea = All;
                }
            }
            group(AdditionalInfo)
            {
                Caption = 'Additional Information';
                field(UnstructuredMessage; "Unstructured Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the message.';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        "QR-Bill Layout" := '';
                    end;
                }
                field(BillingInformation; "Billing Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the billing information.';
                    Importance = Additional;
                    Editable = not "Source Record Printed";

                    trigger OnValidate()
                    begin
                        "QR-Bill Layout" := '';
                    end;

                    trigger OnDrillDown()
                    var
                        SwissQRBillBillingInfo: Codeunit "Swiss QR-Bill Billing Info";
                    begin
                        SwissQRBillBillingInfo.DrillDownBillingInfo("Billing Information");
                    end;
                }
                group(AltProc1)
                {
                    Caption = 'Alternate Procedure 1';

                    field(AltProcedureName1; "Alt. Procedure Name 1")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the first alternate procedure name.';
                        Importance = Additional;

                        trigger OnValidate()
                        begin
                            "QR-Bill Layout" := '';
                        end;
                    }
                    field(AltProcedureValue1; "Alt. Procedure Value 1")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the first alternate procedure value.';
                        Importance = Additional;
                        Editable = "Alt. Procedure Name 1" <> '';

                        trigger OnValidate()
                        begin
                            "QR-Bill Layout" := '';
                        end;
                    }
                }
                group(AltProc2)
                {
                    Caption = 'Alternate Procedure 2';

                    field(AltProcedureName2; "Alt. Procedure Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the second alternate procedure name.';
                        Importance = Additional;

                        trigger OnValidate()
                        begin
                            "QR-Bill Layout" := '';
                        end;
                    }
                    field(AltProcedureValue2; "Alt. Procedure Value 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the second alternate procedure value.';
                        Importance = Additional;
                        Editable = "Alt. Procedure Name 2" <> '';

                        trigger OnValidate()
                        begin
                            "QR-Bill Layout" := '';
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FromDocument)
            {
                ApplicationArea = All;
                Caption = 'Select Document';
                ToolTip = 'Opens the page to select a posted document and set it up as a source for QR-bill printing.';

                trigger OnAction()
                var
                    SwissQRBillPrintSelectDoc: Page "Swiss QR-Bill Print Select Doc";
                begin
                    SwissQRBillPrintSelectDoc.LookupMode(true);
                    if SwissQRBillPrintSelectDoc.RunModal() = Action::LookupOK then
                        if SwissQRBillPrintSelectDoc.GetSelectedLedgerEntry() <> 0 then
                            LoadFromCustLedgerEntry(SwissQRBillPrintSelectDoc.GetSelectedLedgerEntry());
                end;
            }
            action(EditPrinted)
            {
                ApplicationArea = All;
                Caption = 'Edit Printed';
                ToolTip = 'Enables editing of the document that has already been printed and has been assigned a reference number.';
                Enabled = "Source Record Printed";

                trigger OnAction()
                begin
                    if Confirm(EnableEditQst) then
                        EnableEditingOfAlreadyPrinted();
                end;
            }
        }
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = All;
                Caption = 'Print';
                ToolTip = 'Prints the QR-bill.';

                trigger OnAction()
                begin
                    SwissQRBillMgt.PrintFromBuffer(Rec);
                    Validate("IBAN Type", "IBAN Type");
                    LoadFromCustLedgerEntry("Customer Ledger Entry No.");
                end;
            }
        }
    }

    var
        UltimateDebitorCustomer: Record Customer;
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        SourceDocumentText: Text;
        CreditorIBANValue: Text;
        CreditorQRIBANValue: Text;
        AlreadyPrintedNotifyLbl: Label 'The selected source doument is already printed and has an assigned reference number. Only additinal information can be edited. Use Edit Printed action to edit and print the document with a new reference number.';
        EnableEditQst: Label 'You are about to generate a new reference number for the document. New number will be automatically assigned during printing. This can lead to a wrong payment reconciliation. Do you want to continue?';

    trigger OnOpenPage()
    var
        CompanyInformation: Record "Company Information";
    begin
        InitBuffer('');
        CompanyInformation.Get();
        CreditorIBANValue := SwissQRBillMgt.FormatIBAN(CompanyInformation.IBAN);
        CreditorQRIBANValue := SwissQRBillMgt.FormatIBAN(CompanyInformation."Swiss QR-Bill IBAN");
        Insert();
    end;

    local procedure NotifySourceDocIsAlreadyPrinted()
    var
        AlreadyPrintedNotification: Notification;
    begin
        AlreadyPrintedNotification.Id := GetAlreadyPrintedNotificationGUID();
        AlreadyPrintedNotification.Recall();
        if "Source Record Printed" then begin
            AlreadyPrintedNotification.Message := AlreadyPrintedNotifyLbl;
            AlreadyPrintedNotification.Scope := NotificationScope::LocalScope;
            AlreadyPrintedNotification.Send();
        end;
    end;

    local procedure GetAlreadyPrintedNotificationGUID(): Guid
    begin
        exit('2eba8e6f-551e-43dc-a7b7-86168393513e');
    end;

    local procedure LoadFromCustLedgerEntry(EntryNo: Integer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgerEntry.Get(EntryNo) then begin
            SetSourceRecord(CustLedgerEntry."Entry No.");
            UltimateDebitorCustomer.Get(CustLedgerEntry."Customer No.");
            SourceDocumentText := CustLedgerEntry.Description;
            NotifySourceDocIsAlreadyPrinted();
            CurrPage.Update();
        end;
    end;
}
