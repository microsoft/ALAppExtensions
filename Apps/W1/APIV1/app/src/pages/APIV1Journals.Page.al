page 20016 "APIV1 - Journals"
{
    APIVersion = 'v1.0';
    Caption = 'journals', Locked = true;
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
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Name)
                {
                    Caption = 'code', Locked = true;
                    ShowMandatory = true;
                }
                field(displayName; Description)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(lastModifiedDateTime; "Last Modified DateTime")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                field(balancingAccountId; BalAccountId)
                {
                    Caption = 'balancingAccountId', Locked = true;
                }
                field(balancingAccountNumber; "Bal. Account No.")
                {
                    Caption = 'balancingAccountNumber', Locked = true;
                    Editable = false;
                }
            }
            part(journalLines; "APIV1 - JournalLines")
            {
                ApplicationArea = All;
                Caption = 'JournalLines', Locked = true;
                EntityName = 'journalLine';
                EntitySetName = 'journalLines';
                SubPageLink = "Journal Batch Id" = FIELD(SystemId);
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

    trigger OnOpenPage()
    begin
        SETRANGE("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
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
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch.Name);
        IF NOT GenJournalLine.FINDFIRST() THEN
            ERROR(ThereIsNothingToPostErr);

        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
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
        ActionContext.SetObjectId(Page::"APIV1 - Journals");
        ActionContext.AddEntityKey(FieldNo(SystemId), GenJournalBatchId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;
}
