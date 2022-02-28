page 30049 "APIV2 - JournalLines"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Journal Line';
    EntitySetCaption = 'Journal Lines';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    PageType = API;
    EntityName = 'journalLine';
    EntitySetName = 'journalLines';
    SourceTable = "Gen. Journal Line";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(journalId; "Journal Batch Id")
                {
                    Caption = 'Journal Id';
                }
                field(journalDisplayName; GlobalJournalDisplayNameTxt)
                {
                    Caption = 'Journal Display Name';

                    trigger OnValidate()
                    begin
                        Error(CannotEditBatchNameErr);
                    end;
                }
                field(lineNumber; "Line No.")
                {
                    Caption = 'Line No.';
                }
                field(accountType; "Account Type")
                {
                    Caption = 'Account Type';
                }
                field(accountId; "Account Id")
                {
                    Caption = 'Account Id';

                    trigger OnValidate()
                    begin
                        if "Account Id" = BlankGUID then begin
                            "Account No." := '';
                            exit;
                        end;
                        if "Account Type" = "Account Type"::"G/L Account" then begin
                            if not GLAccount.GetBySystemId("Account Id") then
                                Error(AccountIdDoesNotMatchAnAccountErr);
                            "Account No." := GLAccount."No.";
                        end;
                        if "Account Type" = "Account Type"::"Bank Account" then
                            if BankAccount.GetBySystemId("Account Id") then
                                "Account No." := BankAccount."No."
                            else
                                Error(AccountIdDoesNotMatchAnAccountErr);
                    end;
                }
                field(accountNumber; "Account No.")
                {
                    Caption = 'Account No.';

                    trigger OnValidate()
                    begin
                        case "Account Type" of
                            "Account Type"::"G/L Account":
                                UpdateAccountIdForGLAccount();
                            "Account Type"::"Bank Account":
                                UpdateAccountIdForBankAccount();
                        end;
                    end;
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentNumber; "Document No.")
                {
                    Caption = 'Document No.';
                }
                field(externalDocumentNumber; "External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(amount; Amount)
                {
                    Caption = 'Amount';
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
                field(comment; Comment)
                {
                    Caption = 'Comment';
                }
                field(taxCode; TaxCode)
                {
                    Caption = 'Tax Code';

                    trigger OnValidate()
                    var
                        GeneralLedgerSetup: Record "General Ledger Setup";
                    begin
                        if GeneralLedgerSetup.UseVat() then
                            Rec."VAT Prod. Posting Group" := TaxCode
                        else
                            Rec."Tax Group Code" := TaxCode;
                    end;
                }

                field(balanceAccountType; "Bal. Account Type")
                {
                    Caption = 'Balance Account Type';
                }
                field(balancingAccountId; "Balance Account Id")
                {
                    Caption = 'Balancing Account Id';

                    trigger OnValidate()
                    begin
                        if "Balance Account Id" = BlankGUID then begin
                            "Bal. Account No." := '';
                            exit;
                        end;
                        if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then begin
                            if not GLAccount.GetBySystemId("Balance Account Id") then
                                Error(BalAccountIdDoesNotMatchAnAccountErr);
                            "Bal. Account No." := GLAccount."No.";
                        end;
                        if "Bal. Account Type" = "Bal. Account Type"::"Bank Account" then
                            if not BankAccount.GetBySystemId("Balance Account Id") then
                                Error(BalAccountIdDoesNotMatchAnAccountErr);
                        "Bal. Account No." := BankAccount."No."
                    end;


                }
                field(balancingAccountNumber; "Bal. Account No.")
                {
                    Caption = 'Balancing Account No.';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = Field(SystemId), "Document Type" = const(Journal);
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("Journal Line");
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
        GenJournalBatch: Record "Gen. Journal Batch";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
    begin
        if IsNullGuid(Rec."Journal Batch Id") then
            CheckFilters();

        TempGenJournalLine.Reset();
        TempGenJournalLine.Copy(Rec);

        Clear(Rec);
        if IsNullGuid(TempGenJournalLine."Journal Batch Id") then
            GenJournalBatch.GetBySystemId(TempGenJournalLine.GetFilter("Journal Batch Id"))
        else
            GenJournalBatch.GetBySystemId(TempGenJournalLine."Journal Batch Id");

        GraphMgtJournalLines.SetJournalLineTemplateAndBatchV2(Rec, GenJournalBatch);
        LibraryAPIGeneralJournal.InitializeLine(
          Rec, TempGenJournalLine."Line No.", TempGenJournalLine."Document No.", TempGenJournalLine."External Document No.");

        GraphMgtJournalLines.SetJournalLineValues(Rec, TempGenJournalLine);

        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.GetBySystemId(SystemId);

        if Rec."Journal Batch Id" <> GenJournalLine."Journal Batch Id" then
            Error(CannotEditBatchIdErr);

        if "Line No." = GenJournalLine."Line No." then
            Modify(true)
        else begin
            GenJournalLine.TransferFields(Rec, false);
            GenJournalLine.Rename("Journal Template Name", "Journal Batch Name", "Line No.");
            TransferFields(GenJournalLine, true);
        end;

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();

        "Document Type" := "Document Type"::" ";
        "Account Type" := "Account Type"::"G/L Account";
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("Document Type", Rec."Document Type"::" ");
        Rec.SetRange("Account Type", Rec."Account Type"::"G/L Account", Rec."Account Type"::"Bank Account");
    end;

    var
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        GraphMgtJournalLines: Codeunit "Graph Mgt - Journal Lines";
        LibraryAPIGeneralJournal: Codeunit "Library API - General Journal";
        FiltersNotSpecifiedErr: Label 'You must specify a journal batch ID or a journal ID to get a journal line.';
        CannotEditBatchNameErr: Label 'The Journal Batch Display Name isn''t editable.';
        CannotEditBatchIdErr: Label 'The Journal Batch Id isn''t editable.';
        AccountValuesDontMatchErr: Label 'The account values do not match to a specific Account.';
        AccountIdDoesNotMatchAnAccountErr: Label 'The "accountId" does not match to an Account.', Comment = 'accountId is a field name and should not be translated.';
        BalAccountIdDoesNotMatchAnAccountErr: Label 'The "balancingAccountId" does not match to an Account.', Comment = 'balancingAccountId is a field name and should not be translated.';
        AccountNumberDoesNotMatchAnAccountErr: Label 'The "accountNumber" does not match to an Account.', Comment = 'accountNumber is a field name and should not be translated.';
        GlobalJournalDisplayNameTxt: Code[10];
        TaxCode: Code[20];
        FiltersChecked: Boolean;
        BlankGUID: Guid;

    local procedure SetCalculatedFields()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GlobalJournalDisplayNameTxt := "Journal Batch Name";
        if GeneralLedgerSetup.UseVat() then
            TaxCode := "VAT Prod. Posting Group"
        else
            TaxCode := "Tax Group Code";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(GlobalJournalDisplayNameTxt);
        Clear(TaxCode);
    end;

    local procedure CheckFilters()
    begin
        if (GetFilter("Journal Batch Id") = '') and
           (GetFilter(SystemId) = '')
        then
            Error(FiltersNotSpecifiedErr);
    end;

    local procedure UpdateAccountIdForGLAccount();
    begin
        if GLAccount."No." <> '' then begin
            if GLAccount."No." <> "Account No." then
                Error(AccountValuesDontMatchErr);
            exit;
        end;

        if "Account No." = '' then begin
            "Account Id" := BlankGUID;
            exit;
        end;

        if not GLAccount.Get("Account No.") then
            Error(AccountNumberDoesNotMatchAnAccountErr);

        "Account Id" := GLAccount.SystemId;
    end;

    local procedure UpdateAccountIdForBankAccount();
    begin
        if BankAccount."No." <> '' then begin
            if BankAccount."No." <> "Account No." then
                Error(AccountValuesDontMatchErr);
            exit;
        end;

        if "Account No." = '' then begin
            "Account Id" := BlankGUID;
            exit;
        end;

        if not BankAccount.Get("Account No.") then
            Error(AccountNumberDoesNotMatchAnAccountErr);

        "Account Id" := BankAccount.SystemId;
    end;
}

