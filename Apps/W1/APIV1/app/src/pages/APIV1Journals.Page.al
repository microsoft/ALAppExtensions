namespace Microsoft.API.V1;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Integration.Graph;
using Microsoft.Finance.GeneralLedger.Posting;

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
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Name)
                {
                    Caption = 'code', Locked = true;
                    ShowMandatory = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(lastModifiedDateTime; Rec."Last Modified DateTime")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                field(balancingAccountId; Rec.BalAccountId)
                {
                    Caption = 'balancingAccountId', Locked = true;
                }
                field(balancingAccountNumber; Rec."Bal. Account No.")
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
                SubPageLink = "Journal Batch Id" = field(SystemId);
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Journal Template Name" := GraphMgtJournal.GetDefaultJournalLinesTemplateName();
    end;

    trigger OnOpenPage()
    begin
        Rec.SETRANGE("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
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
        SetActionResponse(ActionContext, Rec.SystemId);
    end;

    local procedure PostBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch.Name);
        if not GenJournalLine.FINDFIRST() then
            error(ThereIsNothingToPostErr);

        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
    end;

    local procedure GetBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        if not GenJournalBatch.GetBySystemId(Rec.SystemId) then
            Error(CannotFindBatchErr, Rec.SystemId);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; GenJournalBatchId: Guid)
    begin

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Journals");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), GenJournalBatchId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;
}

