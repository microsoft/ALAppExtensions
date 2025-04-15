namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Threading;
using Microsoft.EServices.EDocument;

page 6246260 "ForNAV Incoming Docs Api"
{
    PageType = API;
    APIPublisher = 'forNav';
    APIGroup = 'peppol';
    APIVersion = 'v1.0';
    EntityName = 'peppolDoc';
    EntitySetName = 'peppolDocs';
    SourceTable = "ForNAV Incoming Doc";
    DelayedInsert = true;
    Caption = 'ForNavPeppolDoc', Locked = true;
    InsertAllowed = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Extensible = false;
    Permissions = TableData "Job Queue Entry" = rimd,
                  TableData "Job Queue Log Entry" = RIMD,
                  TableData "Job Queue Category" = rimd; //rm;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(iD; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field(docNo; Rec.DocNo)
                {
                    ApplicationArea = All;

                }
                field(docType; Rec.DocType)
                {
                    ApplicationArea = All;

                }
                field(docCode; Rec.DocCode)
                {
                    ApplicationArea = All;

                }
                field(doc; _Doc)
                {
                    ApplicationArea = All;
                }
                field(message; _Message)
                {
                    ApplicationArea = All;
                }
                field(status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(eDocumentType; Rec.EDocumentType)
                {
                    ApplicationArea = All;
                }
                field(schemeID; Rec.SchemeID)
                {
                    ApplicationArea = All;
                }
                field(endpointID; Rec.EndpointID)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        _Doc, _Message : BigText;

    [TryFunction]
    local procedure ScheduleJob(JobQueueCodeunit: Integer; RecId: RecordId)
    var
        QueueEntry: Record "Job Queue Entry";
        // Enqueue: Codeunit "Job Queue - Enqueue";
        PeppolJobQueue: Codeunit "ForNAV Peppol Job Queue";
    begin
        QueueEntry.ID := CreateGuid();
        QueueEntry."Record ID to Process" := RecId;
        QueueEntry."Object ID to Run" := JobQueueCodeunit;
        QueueEntry."Object Type to Run" := QueueEntry."Object Type to Run"::Codeunit;
        QueueEntry."Job Queue Category Code" := PeppolJobQueue.GetForNAVCategoryCode();
        QueueEntry.Description := 'Used by ForNAV to process incoming e-documents';
        QueueEntry.Status := QueueEntry.Status::"On Hold";
        QueueEntry.Insert();
        // Enqueue.Run(QueueEntry);
    end;

    local procedure SetErrorMessage(var NewMessage: BigText)
    var
        Error: ErrorInfo;
    begin
        Clear(NewMessage);
        NewMessage.AddText('Error\n');
        NewMessage.AddText(GetLastErrorText() + '\n');
        NewMessage.AddText(GetLastErrorCallStack() + '\n');
        foreach Error in GetCollectedErrors() do
            NewMessage.AddText(Error.Message + '\n');
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        EDocumentService: Record "E-Document Service";
        BlankRecordId: RecordId;
        DocOs, MessageOs : OutStream;
    begin
        case Rec.DocType of
            Rec.DocType::Evidence:
                if not ScheduleJob(Codeunit::"E-Document Get Response", BlankRecordId) then
                    SetErrorMessage(_Message);
            Rec.DocType::ApplicationResponse:
                if not ScheduleJob(Codeunit::"ForNAV App. Resp. Handler", Rec.RecordId()) then
                    SetErrorMessage(_Message);
            Rec.DocType::Invoice, Rec.DocType::CreditNote:
                begin
                    EDocumentService.Get('FORNAV');
                    if not ScheduleJob(6147, EDocumentService.RecordId()) then // Codeunit::"E-Document Import Job"
                        SetErrorMessage(_Message);
                end;
        end;

        Rec.Doc.CreateOutStream(DocOs, TextEncoding::UTF8);
        _Doc.Write(DocOs);
        Rec.Message.CreateOutStream(MessageOs, TextEncoding::UTF8);
        _Message.Write(MessageOs);
        exit(true);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(false);
    end;
}

