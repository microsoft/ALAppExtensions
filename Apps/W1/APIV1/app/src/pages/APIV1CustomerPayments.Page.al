page 20058 "APIV1 - Customer Payments"
{
    APIVersion = 'v1.0';
    Caption = 'customerPayments', Locked = true;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    PageType = API;
    EntityName = 'customerPayment';
    EntitySetName = 'customerPayments';
    SourceTable = "Gen. Journal Line";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(journalDisplayName; GlobalJournalDisplayNameTxt)
                {
                    ApplicationArea = All;
                    Caption = 'JournalDisplayName', Locked = true;

                    trigger OnValidate()
                    begin
                        Error(CannotEditBatchNameErr);
                    end;
                }
                field(lineNumber; "Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'LineNumber', Locked = true;
                }
                field(customerId; "Customer Id")
                {
                    ApplicationArea = All;
                    Caption = 'CustomerId', Locked = true;

                    trigger OnValidate()
                    begin
                        if "Customer Id" = BlankGUID then begin
                            "Account No." := '';
                            exit;
                        end;

                        if not Customer.GetBySystemId("Customer Id") then
                            Error(CustomerIdDoesNotMatchACustomerErr);

                        "Account No." := Customer."No.";
                    end;
                }
                field(customerNumber; "Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'CustomerNumber', Locked = true;
                    TableRelation = Customer;

                    trigger OnValidate()
                    begin
                        if Customer."No." <> '' then begin
                            if Customer."No." <> "Account No." then
                                Error(CustomerValuesDontMatchErr);
                            exit;
                        end;

                        if "Account No." = '' then begin
                            "Customer Id" := BlankGUID;
                            exit;
                        end;

                        if not Customer.Get("Account No.") then
                            Error(CustomerNumberDoesNotMatchACustomerErr);

                        "Customer Id" := Customer.SystemId;
                    end;
                }
                field(contactId; "Contact Graph Id")
                {
                    ApplicationArea = All;
                    Caption = 'ContactId', Locked = true;
                }
                field(postingDate; "Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'PostingDate', Locked = true;
                }
                field(documentNumber; "Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'DocumentNumber', Locked = true;
                }
                field(externalDocumentNumber; "External Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'ExternalDocumentNumber', Locked = true;
                }
                field(amount; Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount', Locked = true;
                }
                field(appliesToInvoiceId; AppliesToInvoiceIdText)
                {
                    ApplicationArea = All;
                    Caption = 'AppliesToInvoiceId', Locked = true;
                    ToolTip = 'Specifies the Applies-To Invoice Id field of the customer payment.';

                    trigger OnValidate()
                    var
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                    begin
                        "Applies-to Invoice Id" := AppliesToInvoiceIdText;
                        if "Applies-to Invoice Id" = BlankGUID then begin
                            AppliesToInvoiceNumberText := '';
                            exit;
                        end;

                        SalesInvoiceHeader.Reset();
                        if not SalesInvoiceAggregator.GetSalesInvoiceHeaderFromId(Format(AppliesToInvoiceIdText), SalesInvoiceHeader) then
                            Error(AppliesToInvoiceIdDoesNotMatchAnInvoiceErr);

                        AppliesToInvoiceNumberText := SalesInvoiceHeader."No.";

                        if "Account No." = '' then
                            if SalesInvoiceHeader."Bill-to Customer No." <> '' then
                                "Account No." := SalesInvoiceHeader."Bill-to Customer No."
                            else
                                "Account No." := SalesInvoiceHeader."Sell-to Customer No.";
                    end;
                }
                field(appliesToInvoiceNumber; AppliesToInvoiceNumberText)
                {
                    ApplicationArea = All;
                    Caption = 'AppliesToInvoiceNumber', Locked = true;
                    ToolTip = 'Specifies the Applies-To Invoice Id field of the customer payment.';

                    trigger OnValidate()
                    var
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                        BlankGUID: Guid;
                    begin
                        "Applies-to Doc. No." := AppliesToInvoiceNumberText;

                        if SalesInvoiceHeader."No." <> '' then begin
                            if SalesInvoiceHeader."No." <> AppliesToInvoiceNumberText then
                                Error(AppliesToDocValuesDontMatchErr);
                            exit;
                        end;

                        if SalesInvoiceHeader.Get(AppliesToInvoiceNumberText) then begin
                            AppliesToInvoiceIdText := SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader);
                            if "Account No." = '' then
                                if SalesInvoiceHeader."Bill-to Customer No." <> '' then
                                    "Account No." := SalesInvoiceHeader."Bill-to Customer No."
                                else
                                    "Account No." := SalesInvoiceHeader."Sell-to Customer No.";
                        end else
                            AppliesToInvoiceIdText := BlankGUID;
                    end;
                }
                field(description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description', Locked = true;
                }
                field(comment; Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comment', Locked = true;
                }
                field(dimensions; DimensionsJSON)
                {
                    ApplicationArea = All;
                    Caption = 'Dimensions', Locked = true;
                    ODataEDMType = 'Collection(DIMENSION)';
                    ToolTip = 'Specifies Journal Line Dimensions.';

                    trigger OnValidate()
                    begin
                        DimensionsSet := PreviousDimensionsJSON <> DimensionsJSON;
                    end;
                }
                field(lastModifiedDateTime; "Last Modified DateTime")
                {
                    ApplicationArea = All;
                    Caption = 'LastModifiedDateTime', Locked = true;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not FiltersChecked then begin
            CheckFilters();
            FiltersChecked := true;
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
    begin
        ProcessAppliesToInvoiceNumberAndId();

        TempGenJournalLine.Reset();
        TempGenJournalLine.Copy(Rec);

        Clear(Rec);
        GraphMgtCustomerPayments.SetCustomerPaymentsTemplateAndBatch(
          Rec, LibraryAPIGeneralJournal.GetBatchNameFromId(TempGenJournalLine.GetFilter("Journal Batch Id")));
        LibraryAPIGeneralJournal.InitializeLine(
          Rec, TempGenJournalLine."Line No.", TempGenJournalLine."Document No.", TempGenJournalLine."External Document No.");
        TransferGeneratedFieldsFromInitializeLine(TempGenJournalLine);

        GraphMgtCustomerPayments.SetCustomerPaymentsValues(Rec, TempGenJournalLine);

        UpdateDimensions(true);

        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        ProcessAppliesToInvoiceNumberAndId();

        GenJournalLine.GetBySystemId(SystemId);

        if "Line No." = GenJournalLine."Line No." then
            Modify(true)
        else begin
            GenJournalLine.TransferFields(Rec, false);
            GenJournalLine.Rename("Journal Template Name", "Journal Batch Name", "Line No.");
            TransferFields(GenJournalLine, true);
        end;

        UpdateDimensions(false);

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CheckFilters();

        ClearCalculatedFields();

        "Document Type" := "Document Type"::Payment;
        "Account Type" := "Account Type"::Customer;
        "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;
    end;

    trigger OnOpenPage()
    begin
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(Rec);
    end;

    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GraphMgtCustomerPayments: Codeunit "Graph Mgt - Customer Payments";
        LibraryAPIGeneralJournal: Codeunit "Library API - General Journal";
        GlobalJournalDisplayNameTxt: Text;
        DimensionsJSON: Text;
        PreviousDimensionsJSON: Text;
        AppliesToInvoiceNumberText: Code[20];
        AppliesToInvoiceIdText: Guid;
        FiltersNotSpecifiedErr: Label 'You must specify a journal batch ID or a journal ID to get a journal line.', Locked = true;
        CannotEditBatchNameErr: Label 'The Journal Batch Display Name isn''t editable.', Locked = true;
        CustomerValuesDontMatchErr: Label 'The customer values do not match to a specific Customer.', Locked = true;
        CustomerIdDoesNotMatchACustomerErr: Label 'The "customerId" does not match to a Customer.', Locked = true;
        CustomerNumberDoesNotMatchACustomerErr: Label 'The "customerNumber" does not match to a Customer.', Locked = true;
        AppliesToDocValuesDontMatchErr: Label 'The AppliesToInvoice values do not match to the same Invoice.', Locked = true;
        AppliesToInvoiceIdDoesNotMatchAnInvoiceErr: Label 'The "appliesToInvoiceId" should be the ID of an Open, Paid, Corrective, or Canceled Invoice.', Locked = true;
        FiltersChecked: Boolean;
        DimensionsSet: Boolean;
        BlankGUID: Guid;

    local procedure TransferGeneratedFieldsFromInitializeLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Document No." = '' then
            GenJournalLine."Document No." := "Document No.";
    end;

    local procedure SetCalculatedFields()
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        GlobalJournalDisplayNameTxt := "Journal Batch Name";
        AppliesToInvoiceNumberText := "Applies-to Doc. No.";
        AppliesToInvoiceIdText := "Applies-to Invoice Id";
        DimensionsJSON := GraphMgtComplexTypes.GetDimensionsJSON("Dimension Set ID");
        PreviousDimensionsJSON := DimensionsJSON;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(GlobalJournalDisplayNameTxt);
        Clear(AppliesToInvoiceIdText);
        Clear(AppliesToInvoiceNumberText);
        Clear(DimensionsJSON);
        Clear(PreviousDimensionsJSON);
        Clear(DimensionsSet);
    end;

    local procedure ProcessAppliesToInvoiceNumberAndId()
    begin
        if AppliesToInvoiceNumberText <> '' then
            "Applies-to Doc. No." := AppliesToInvoiceNumberText;
        "Applies-to Invoice Id" := AppliesToInvoiceIdText;
    end;

    local procedure CheckFilters()
    begin
        if (GetFilter("Journal Batch Id") = '') and
           (GetFilter(SystemId) = '')
        then
            Error(FiltersNotSpecifiedErr);
    end;

    local procedure UpdateDimensions(LineExists: Boolean)
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        DimensionManagement: Codeunit DimensionManagement;
        NewDimensionSetId: Integer;
    begin
        if not DimensionsSet then
            exit;

        GraphMgtComplexTypes.GetDimensionSetFromJSON(DimensionsJSON, "Dimension Set ID", NewDimensionSetId);
        if "Dimension Set ID" <> NewDimensionSetId then begin
            "Dimension Set ID" := NewDimensionSetId;
            DimensionManagement.UpdateGlobalDimFromDimSetID(NewDimensionSetId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            if LineExists then
                Modify();
        end;
    end;
}

