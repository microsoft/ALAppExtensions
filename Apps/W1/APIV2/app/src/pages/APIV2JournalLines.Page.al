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
                    Editable = false;
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
                    SubPageLink = "Document Id" = Field(SystemId), "Document Type" = const(1);
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const(1);
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
        TempGenJournalLine.Reset();
        TempGenJournalLine.Copy(Rec);

        Clear(Rec);
        GraphMgtJournalLines.SetJournalLineTemplateAndBatch(
          Rec, LibraryAPIGeneralJournal.GetBatchNameFromId(TempGenJournalLine.GetFilter("Journal Batch Id")));
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
        CheckFilters();

        ClearCalculatedFields();

        "Document Type" := "Document Type"::" ";
        "Account Type" := "Account Type"::"G/L Account";
    end;

    trigger OnOpenPage()
    begin
        GraphMgtJournalLines.SetJournalLineFiltersV1(Rec);
    end;

    var
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        GraphMgtJournalLines: Codeunit "Graph Mgt - Journal Lines";
        LibraryAPIGeneralJournal: Codeunit "Library API - General Journal";
        FiltersNotSpecifiedErr: Label 'You must specify a journal batch ID or a journal ID to get a journal line.';
        CannotEditBatchNameErr: Label 'The Journal Batch Display Name isn''t editable.';
        AccountValuesDontMatchErr: Label 'The account values do not match to a specific Account.';
        AccountIdDoesNotMatchAnAccountErr: Label 'The "accountId" does not match to an Account.';
        AccountNumberDoesNotMatchAnAccountErr: Label 'The "accountNumber" does not match to an Account.';
        GlobalJournalDisplayNameTxt: Code[10];
        FiltersChecked: Boolean;
        BlankGUID: Guid;

    local procedure SetCalculatedFields()
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        GlobalJournalDisplayNameTxt := "Journal Batch Name";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(GlobalJournalDisplayNameTxt);
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

