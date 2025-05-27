namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Threading;
using Microsoft.EServices.EDocument;


/// <summary>
/// Processes the FORNAV Incoming Documents
/// </summary>
codeunit 6410 "ForNAV App. Resp. Handler"
{
    Permissions =
        tabledata Microsoft.eServices.EDocument."E-Document Service Status" = RIMD;
    Access = internal;
    TableNo = "Job Queue Entry";

    local procedure UpdateServiceStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentStatus: Enum "E-Document Service Status")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocument.Get(EDocument."Entry No");
        if EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code) then begin
            EDocumentServiceStatus.Validate(Status, EDocumentStatus);
            EDocumentServiceStatus.Modify()
        end else begin
            EDocumentServiceStatus.Validate("E-Document Entry No", EDocument."Entry No");
            EDocumentServiceStatus.Validate("E-Document Service Code", EDocumentService.Code);
            EDocumentServiceStatus.Validate(Status, EDocumentStatus);
            EDocumentServiceStatus.Insert();
        end;
    end;

    procedure ProcessApplicationResponse(DocumentType: Enum "E-Document Type"; DocNo: Text; Status: Enum "E-Document Service Status"): Boolean
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocLogHelper: Codeunit "E-Document Log Helper";
    begin
        if not EDocumentService.Get('FORNAV') then
            exit(false);

        EDocument.SetRange("Document No.", DocNo);
        EDocument.SetRange("Document Type", DocumentType);
        EDocument.SetRange(Direction, "E-Document Direction"::Outgoing);
        if EDocument.FindFirst() then begin
            EDocLogHelper.InsertLog(EDocument, EDocumentService, Status);
            UpdateServiceStatus(EDocument, EDocumentService, Status);
            exit(true);
        end;
    end;

    trigger OnRun()
    var
        IncomingDoc: Record "ForNAV Incoming E-Document";
    begin
        IncomingDoc.Get(rec."Record ID to Process");
        if IncomingDoc.DocType = IncomingDoc.DocType::ApplicationResponse then
            if IncomingDoc.EDocumentType <> "E-Document Type"::None then
                if ProcessApplicationResponse(IncomingDoc.EDocumentType, IncomingDoc.DocNo, IncomingDoc.Status = IncomingDoc.Status::Approved ? "E-Document Service Status"::Approved : "E-Document Service Status"::Rejected) then begin
                    IncomingDoc.Status := IncomingDoc.Status::Processed;
                    IncomingDoc.Modify();
                end;
    end;
}