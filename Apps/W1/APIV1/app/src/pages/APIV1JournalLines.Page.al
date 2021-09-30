page 20049 "APIV1 - JournalLines"
{
    APIVersion = 'v1.0';
    Caption = 'journalLines', Locked = true;
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
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(journalDisplayName; GlobalJournalDisplayNameTxt)
                {
                    Caption = 'JournalDisplayName', Locked = true;
                    ToolTip = 'Specifies the Journal Batch Name of the Journal Line';

                    trigger OnValidate()
                    begin
                        Error(CannotEditBatchNameErr);
                    end;
                }
                field(lineNumber; "Line No.")
                {
                    Caption = 'LineNumber', Locked = true;
                }
                field(accountType; "Account Type")
                {
                    Caption = 'AccountType', Locked = true;
                }
                field(accountId; "Account Id")
                {
                    Caption = 'AccountId', Locked = true;

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
                    Caption = 'AccountNumber', Locked = true;

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
                    Caption = 'PostingDate', Locked = true;
                }
                field(documentNumber; "Document No.")
                {
                    Caption = 'DocumentNumber', Locked = true;
                }
                field(externalDocumentNumber; "External Document No.")
                {
                    Caption = 'ExternalDocumentNumber', Locked = true;
                }
                field(amount; Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(description; Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(comment; Comment)
                {
                    Caption = 'Comment', Locked = true;
                }
                field(dimensions; DimensionsJSON)
                {
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
                    Caption = 'LastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                part(attachments; "APIV1 - Attachments")
                {
                    Caption = 'attachments', Locked = true;
                    EntityName = 'attachments';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = FIELD(SystemId);
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

        UpdateDimensions(false);
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

        UpdateDimensions(true);
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
        FiltersNotSpecifiedErr: Label 'You must specify a journal batch ID or a journal ID to get a journal line.', Locked = true;
        CannotEditBatchNameErr: Label 'The Journal Batch Display Name isn''t editable.', Locked = true;
        AccountValuesDontMatchErr: Label 'The account values do not match to a specific Account.', Locked = true;
        AccountIdDoesNotMatchAnAccountErr: Label 'The "accountId" does not match to an Account.', Locked = true;
        AccountNumberDoesNotMatchAnAccountErr: Label 'The "accountNumber" does not match to an Account.', Locked = true;
        DimensionsJSON: Text;
        PreviousDimensionsJSON: Text;
        GlobalJournalDisplayNameTxt: Code[10];
        FiltersChecked: Boolean;
        DimensionsSet: Boolean;
        BlankGUID: Guid;

    local procedure SetCalculatedFields()
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        GlobalJournalDisplayNameTxt := "Journal Batch Name";
        DimensionsJSON := GraphMgtComplexTypes.GetDimensionsJSON("Dimension Set ID");
        PreviousDimensionsJSON := DimensionsJSON;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(GlobalJournalDisplayNameTxt);
        Clear(DimensionsJSON);
        Clear(PreviousDimensionsJSON);
        Clear(DimensionsSet);
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
        JSONDimensionSetId: Integer;
        DimSetIdArr: array[10] of Integer;
    begin
        if not DimensionsSet then
            exit;

        GraphMgtComplexTypes.GetDimensionSetFromJSON(DimensionsJSON, "Dimension Set ID", JSONDimensionSetId);
        DimSetIdArr[1] := "Dimension Set ID";
        DimSetIdArr[2] := JSONDimensionSetId;
        NewDimensionSetId := DimensionManagement.GetCombinedDimensionSetID(DimSetIdArr, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if "Dimension Set ID" <> NewDimensionSetId then begin
            "Dimension Set ID" := NewDimensionSetId;
            DimensionManagement.UpdateGlobalDimFromDimSetID(NewDimensionSetId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            if LineExists then
                Modify();
        end;
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

