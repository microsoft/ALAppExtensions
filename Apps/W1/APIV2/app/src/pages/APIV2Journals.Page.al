page 30016 "APIV2 - Journals"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Journal';
    EntitySetCaption = 'Journals';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'journal';
    EntitySetName = 'journals';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Gen. Journal Batch";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Name)
                {
                    Caption = 'Code';
                    ShowMandatory = true;
                }
                field(displayName; Description)
                {
                    Caption = 'Display Name';
                }
                field(templateDisplayName; "Journal Template Name")
                {
                    Caption = 'Template Display Name';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last  Modified Date Time';
                }
                field(balancingAccountId; BalAccountId)
                {
                    Caption = 'Balancing Account Id';
                }
                field(balancingAccountNumber; "Bal. Account No.")
                {
                    Caption = 'Balancing Account No.';
                    Editable = false;
                }
                part(journalLines; "APIV2 - JournalLines")
                {
                    Caption = 'Journal Lines';
                    EntityName = 'journalLine';
                    EntitySetName = 'journalLines';
                    SubPageLink = "Journal Batch Id" = Field(SystemId);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Journal Template Name" := GraphMgtJournal.GetDefaultJournalLinesTemplateName();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        TemplateNameFilter: Text[10];
        IdFilter: Text;
    begin
        TemplateNameFilter := CopyStr(GetFilter("Journal Template Name"), 1, 10);
        IdFilter := GetFilter(SystemId);
        if IdFilter <> '' then
            exit(Rec.GetBySystemId(IdFilter));

        if TemplateNameFilter = '' then
            TemplateNameFilter := GraphMgtJournal.GetDefaultJournalLinesTemplateName();
        Rec.SetRange("Journal Template Name", TemplateNameFilter);
        exit(Rec.FindSet());
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        ThereIsNothingToPostErr: Label 'There is nothing to post.';
        CannotFindBatchErr: Label 'The General Journal Batch with ID %1 cannot be found.', Comment = '%1 - the System ID of the general journal batch';

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure post(var ActionContext: WebServiceActionContext)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GetBatch(GenJournalBatch);
        PostBatch(GenJournalBatch);
        SetActionResponse(ActionContext, SystemId);
    end;

    local procedure PostBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if not GenJournalLine.FindFirst() then
            Error(ThereIsNothingToPostErr);

        Codeunit.RUN(Codeunit::"Gen. Jnl.-Post", GenJournalLine);
    end;

    local procedure GetBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        if not GenJournalBatch.GetBySystemId(SystemId) then
            Error(CannotFindBatchErr, SystemId);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; GenJournalBatchId: Guid)
    var
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Journals");
        ActionContext.AddEntityKey(FieldNo(SystemId), GenJournalBatchId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;
}
