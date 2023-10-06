namespace Microsoft.API.V1;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Bank.BankAccount;
using Microsoft.Integration.Graph;
using Microsoft.Finance.Dimension;

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
                field(id; Rec.SystemId)
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
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'LineNumber', Locked = true;
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'AccountType', Locked = true;
                }
                field(accountId; Rec."Account Id")
                {
                    Caption = 'AccountId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Account Id" = BlankGUID then begin
                            Rec."Account No." := '';
                            exit;
                        end;
                        if Rec."Account Type" = Rec."Account Type"::"G/L Account" then begin
                            if not GLAccount.GetBySystemId(Rec."Account Id") then
                                Error(AccountIdDoesNotMatchAnAccountErr);
                            Rec."Account No." := GLAccount."No.";
                        end;
                        if Rec."Account Type" = Rec."Account Type"::"Bank Account" then
                            if BankAccount.GetBySystemId(Rec."Account Id") then
                                Rec."Account No." := BankAccount."No."
                            else
                                Error(AccountIdDoesNotMatchAnAccountErr);
                    end;
                }
                field(accountNumber; Rec."Account No.")
                {
                    Caption = 'AccountNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        case Rec."Account Type" of
                            Rec."Account Type"::"G/L Account":
                                UpdateAccountIdForGLAccount();
                            Rec."Account Type"::"Bank Account":
                                UpdateAccountIdForBankAccount();
                        end;
                    end;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'PostingDate', Locked = true;
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'DocumentNumber', Locked = true;
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'ExternalDocumentNumber', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(comment; Rec.Comment)
                {
                    Caption = 'Comment', Locked = true;
                }
                field(dimensions; DimensionsJSON)
                {
                    Caption = 'Dimensions', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'Collection(DIMENSION)';
#pragma warning restore
                    ToolTip = 'Specifies Journal Line Dimensions.';

                    trigger OnValidate()
                    begin
                        DimensionsSet := PreviousDimensionsJSON <> DimensionsJSON;
                    end;
                }
                field(lastModifiedDateTime; Rec."Last Modified DateTime")
                {
                    Caption = 'LastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                part(attachments; "APIV1 - Attachments")
                {
                    Caption = 'attachments', Locked = true;
                    EntityName = 'attachments';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(SystemId);
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
        GenJournalLine.GetBySystemId(Rec.SystemId);

        if Rec."Line No." = GenJournalLine."Line No." then
            Rec.Modify(true)
        else begin
            GenJournalLine.TransferFields(Rec, false);
            GenJournalLine.Rename(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.");
            Rec.TransferFields(GenJournalLine, true);
        end;

        UpdateDimensions(true);
        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CheckFilters();

        ClearCalculatedFields();

        Rec."Document Type" := Rec."Document Type"::" ";
        Rec."Account Type" := Rec."Account Type"::"G/L Account";
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
        GlobalJournalDisplayNameTxt := Rec."Journal Batch Name";
        DimensionsJSON := GraphMgtComplexTypes.GetDimensionsJSON(Rec."Dimension Set ID");
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
        if (Rec.GetFilter("Journal Batch Id") = '') and
           (Rec.GetFilter(SystemId) = '')
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

        GraphMgtComplexTypes.GetDimensionSetFromJSON(DimensionsJSON, Rec."Dimension Set ID", JSONDimensionSetId);
        DimSetIdArr[1] := Rec."Dimension Set ID";
        DimSetIdArr[2] := JSONDimensionSetId;
        NewDimensionSetId := DimensionManagement.GetCombinedDimensionSetID(DimSetIdArr, Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");

        if Rec."Dimension Set ID" <> NewDimensionSetId then begin
            Rec."Dimension Set ID" := NewDimensionSetId;
            DimensionManagement.UpdateGlobalDimFromDimSetID(NewDimensionSetId, Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");
            if LineExists then
                Rec.Modify();
        end;
    end;

    local procedure UpdateAccountIdForGLAccount();
    begin
        if GLAccount."No." <> '' then begin
            if GLAccount."No." <> Rec."Account No." then
                Error(AccountValuesDontMatchErr);
            exit;
        end;

        if Rec."Account No." = '' then begin
            Rec."Account Id" := BlankGUID;
            exit;
        end;

        if not GLAccount.Get(Rec."Account No.") then
            Error(AccountNumberDoesNotMatchAnAccountErr);

        Rec."Account Id" := GLAccount.SystemId;
    end;

    local procedure UpdateAccountIdForBankAccount();
    begin
        if BankAccount."No." <> '' then begin
            if BankAccount."No." <> Rec."Account No." then
                Error(AccountValuesDontMatchErr);
            exit;
        end;

        if Rec."Account No." = '' then begin
            Rec."Account Id" := BlankGUID;
            exit;
        end;

        if not BankAccount.Get(Rec."Account No.") then
            Error(AccountNumberDoesNotMatchAnAccountErr);

        Rec."Account Id" := BankAccount.SystemId;
    end;
}


