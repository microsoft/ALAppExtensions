pageextension 11510 "Swiss QR-Bill Incoming Doc" extends "Incoming Document"
{
    layout
    {
        modify(General)
        {
            Visible = not "Swiss QR-Bill";
        }
        modify(FinancialInformation)
        {
            Visible = not "Swiss QR-Bill";
        }

        addbefore(ErrorMessagesPart)
        {
            group("Swiss QR-Bill General")
            {
                Visible = "Swiss QR-Bill";
                Caption = 'General';

                field("Swiss QR-Bill Description"; Description)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the description of the QR-bill.';
                }
                field("Swiss QR-Bill Attachment"; QRBillAttachmentFileName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attachment';
                    Editable = false;
                    ToolTip = 'Specifies the QR-bill attachment.';

                    trigger OnDrillDown()
                    begin
                        MainAttachmentDrillDown();
                        CurrPage.Update();
                    end;
                }
                field("Swiss QR-Bill Record Link"; QRBillRecordLinkTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Record';
                    Editable = false;
                    ToolTip = 'Specifies the record, document, journal line, or ledger entry that is linked to the QR-bill.';

                    trigger OnDrillDown()
                    begin
                        ShowRecord();
                        CurrPage.Update();
                    end;
                }
                field("Swiss QR-Bill Status"; Status)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the status of the incoming document record.';
                }
                group("Swiss QR-Bill Status Group")
                {
                    ShowCaption = false;

                    field("Swiss QR-Bill Created Date-Time"; "Created Date-Time")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies when the incoming document line was created.';
                    }
                    field("Swiss QR-Bill Created By User Name"; "Created By User Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the name of the user who created the incoming document line.';
                    }
                    field("Swiss QR-Bill Released"; Released)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the incoming document has been approved.';
                        Visible = false;
                    }
                    field("Swiss QR-Bill Released Date Time"; "Released Date-Time")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies when the incoming document was approved.';
                    }
                    field("Swiss QR-Bill Released By User Name"; "Released By User Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the name of the user who approved the incoming document.';
                    }
                    field("Swiss QR-Bill Last Date-Time Modified"; "Last Date-Time Modified")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies when the incoming document line was last modified.';
                    }
                    field("Swiss QR-Bill Last Modified By User Name"; "Last Modified By User Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the name of the user who last modified the incoming document line.';
                    }
                    field("Swiss QR-Bill Posted"; Posted)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the document or journal line that was created for this incoming document has been posted.';
                    }
                    field("Swiss QR-Bill Posted Date-Time"; "Posted Date-Time")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies when the related document or journal line was posted.';
                    }
                }
            }
            group("Swiss QR-Bill Payment Details")
            {
                Visible = "Swiss QR-Bill";
                Caption = 'Financial Information';

                field("Swiss QR-Bill Amount Incl VAT"; "Amount Incl. VAT")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the amount including VAT for the whole document.';
                }
                field("Swiss QR-Bill Currency"; "Currency Code")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency code on the incoming document.';
                }
                field("Swiss QR-Bill Reference Type"; "Swiss QR-Bill Reference Type")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the payment reference type on the incoming document.';
                }
                field("Swiss QR-Bill Reference No."; "Swiss QR-Bill Reference No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the payment reference number on the incoming document.';
                }
                field("Swiss QR-Bill External Doc No"; "Vendor Invoice No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the vendor invoice number on the incoming document.';
                }
                field("Swiss QR-Bill Unstr Msg"; "Swiss QR-Bill Unstr. Message")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the unstructured message on the incoming document.';
                }
                field("Swiss QR-Bill Billing Info"; "Swiss QR-Bill Bill Info")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the billing information on the incoming document.';
                    StyleExpr = true;
                    Style = StandardAccent;

                    trigger OnDrillDown()
                    var
                        SwissQRBillBillingInfo: Codeunit "Swiss QR-Bill Billing Info";
                    begin
                        SwissQRBillBillingInfo.DrillDownBillingInfo("Swiss QR-Bill Bill Info");
                    end;
                }
            }
            group("Swiss QR-Bill Creditor Details")
            {
                Visible = "Swiss QR-Bill";
                Caption = 'Creditor Details';

                field("Swiss QR-Bill Vendor IBAN"; "Vendor IBAN")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'IBAN/QR-IBAN';
                    ToolTip = 'Specifies the IBAN or QR-IBAN account of the vendor on the incoming document.';

                    trigger OnDrillDown()
                    begin
                        SwissQRBillIncomingDoc.DrillDownVendorIBAN("Vendor IBAN");
                    end;
                }
                field("Swiss QR-Bill Vendor VAT Reg. No"; "Vendor VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'VAT Registration No.';
                    ToolTip = 'Specifies the VAT registration number of the vendor on the incoming document.';
                }
                field("Swiss QR-Bill Creditor Name"; "Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    Caption = 'Name';
                    ToolTip = 'Specifies the vendor name on the incoming document.';
                }
                field("Swiss QR-Bill Creditor Addr1"; "Swiss QR-Bill Vendor Address 1")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the address line 1 of the vendor on the incoming document.';
                }
                field("Swiss QR-Bill Creditor Addr2"; "Swiss QR-Bill Vendor Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the address line 2 of the vendor on the incoming document.';
                }
                field("Swiss QR-Bill Creditor Postal Code"; "Swiss QR-Bill Vendor Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the postal code of the vendor on the incoming document.';
                }
                field("Swiss QR-Bill Creditor City"; "Swiss QR-Bill Vendor City")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the city of the vendor on the incoming document.';
                }
                field("Swiss QR-Bill Creditor Country"; "Swiss QR-Bill Vendor Country")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the country of the vendor on the incoming document.';
                }
            }
            group("Swiss QR-Bill Debitor Details")
            {
                Visible = "Swiss QR-Bill";
                Caption = 'Debitor Details';

                field("Swiss QR-Bill Debitor Name"; "Swiss QR-Bill Debitor Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the name of the debitor on the incoming document.';
                }
                field("Swiss QR-Bill Debitor Addr1"; "Swiss QR-Bill Debitor Address1")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the address line 1 of the debitor on the incoming document.';
                }
                field("Swiss QR-Bill Debitor Addr2"; "Swiss QR-Bill Debitor Address2")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the address line 2 of the debitor on the incoming document.';
                }
                field("Swiss QR-Bill Debitor Postal Code"; "Swiss QR-Bill Debitor PostCode")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the postal code of the debitor on the incoming document.';
                }
                field("Swiss QR-Bill Debitor City"; "Swiss QR-Bill Debitor City")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the city of the debitor on the incoming document.';
                }
                field("Swiss QR-Bill Debitor Country"; "Swiss QR-Bill Debitor Country")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the country of the debitor on the incoming document.';
                }
            }
            group("Swiss QR-Bill Matching Details")
            {
                Visible = "Swiss QR-Bill";
                Caption = 'Matching Details';

                field("Swiss QR-Bill Vendor No."; "Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Caption = 'Vendor No.';
                    ToolTip = 'Specifies the vendor number on the incoming document.';
                    Editable = not Posted;

                    trigger OnValidate()
                    begin
                        RefreshSelectedVendorName();
                        "Vendor Bank Account No." := '';
                        RefreshSelectedVendorIBANMatch();
                    end;
                }
                field("Swiss QR-Bill Vendor Name"; QRBillSelectedVendorName)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    Caption = 'Vendor Name';
                    ToolTip = 'Specifies the vendor name on the incoming document.';
                }
                field("Swiss QR-Bill Vendor Bank Account No."; "Vendor Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Caption = 'Vendor Bank Account';
                    ToolTip = 'Specifies the vendor bank account on the incoming document.';
                    TableRelation = "Vendor Bank Account".Code where("Vendor No." = field("Vendor No."));
                    Editable = not Posted;

                    trigger OnValidate()
                    begin
                        RefreshSelectedVendorIBANMatch();
                    end;
                }
                field("Swiss QR-Bill Vendor IBAN Match"; QRBillSelectedVendorIBANMatch)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'IBAN Matches';
                    ToolTip = 'Specifies that the vendor bank account QR-IBAN/IBAN value corresponds to the creditor''s IBAN/QR-IBAN on the incoming document.';
                }
            }
        }
    }

    actions
    {
        modify(CreateDocument) { Visible = not "Swiss QR-Bill"; }
        modify(CreateGenJnlLine) { Visible = not "Swiss QR-Bill"; }
        modify(CreateManually) { Visible = not "Swiss QR-Bill"; }
        modify(ReplaceMainAttachment) { Visible = not "Swiss QR-Bill"; }
        modify(DataExchangeTypes) { Visible = not "Swiss QR-Bill"; }
        modify(OCR) { Visible = not "Swiss QR-Bill"; }
        modify(OCRSetup) { Visible = not "Swiss QR-Bill"; }

        addlast(processing)
        {
            group("Swiss QR-Bill")
            {
                Caption = 'QR-Bill';
                ToolTip = 'QR-Bill processing.';

                action("Swiss QR-Bill Scan")
                {
                    Caption = 'Scan QR-Bill';
                    ToolTip = 'Update the incoming document record from the scanning of QR-bill with an input scanner, or from manual (copy/paste) of the decoded QR-Code text value into a field.';
                    ApplicationArea = All;
                    Image = CreateDocument;

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.ImportQRBillToIncomingDoc(Rec, false);
                    end;
                }
                action("Swiss QR-Bill Import")
                {
                    ApplicationArea = All;
                    Caption = 'Import Scanned QR-Bill File';
                    ToolTip = 'Update the incoming document record by importing a scanned QR-bill that is saved as a text file.';
                    Image = Import;

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.ImportQRBillToIncomingDoc(Rec, true);
                    end;
                }
                action("Swiss QR-Bill Create Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Create Journal Line';
                    ToolTip = 'Creates a new journal line from the incoming QR-bill document.';
                    Enabled = "Swiss QR-Bill";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Image = CreateDocument;
                    Visible = "Swiss QR-Bill";

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.CreateJournalAction(Rec);
                    end;
                }
                action("Swiss QR-Bill Create Purchase Invoice")
                {
                    ApplicationArea = All;
                    Caption = 'Create Purchase Invoice';
                    ToolTip = 'Creates a new purchase invoice from the incoming QR-bill document.';
                    Enabled = "Swiss QR-Bill";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Image = CreateDocument;
                    Visible = "Swiss QR-Bill";

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.CreatePurchaseInvoiceAction(Rec);
                    end;
                }
            }
        }
    }

    var
        SwissQRBillIncomingDoc: Codeunit "Swiss QR-Bill Incoming Doc";
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        QRBillAttachmentFileName: Text;
        QRBillRecordLinkTxt: Text;
        QRBillSelectedVendorName: Text;
        QRBillSelectedVendorIBANMatch: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        DummyIncomingDocument: Record "Incoming Document";
    begin
        QRBillAttachmentFileName := GetMainAttachmentFileName();
        QRBillRecordLinkTxt := GetRecordLinkText();
        if "Swiss QR-Bill" then
            CurrPage.Caption(SwissQRBillMgt.GetQRBillCaption())
        else
            CurrPage.Caption(DummyIncomingDocument.TableCaption());
        RefreshSelectedVendorName();
        RefreshSelectedVendorIBANMatch();
    end;

    local procedure RefreshSelectedVendorName()
    var
        Vendor: Record Vendor;
    begin
        QRBillSelectedVendorName := '';
        if "Vendor No." <> '' then
            if Vendor.Get("Vendor No.") then
                QRBillSelectedVendorName := Vendor.Name;
    end;

    local procedure RefreshSelectedVendorIBANMatch()
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        QRBillSelectedVendorIBANMatch := false;
        if ("Vendor No." <> '') and ("Vendor Bank Account No." <> '') and ("Vendor IBAN" <> '') then
            if Vendor.Get("Vendor No.") then
                if VendorBankAccount.Get("Vendor No.", "Vendor Bank Account No.") then
                    QRBillSelectedVendorIBANMatch := DelChr(VendorBankAccount.IBAN) = DelChr("Vendor IBAN");
    end;
}
