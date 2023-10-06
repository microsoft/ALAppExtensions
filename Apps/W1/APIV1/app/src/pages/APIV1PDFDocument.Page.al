namespace Microsoft.API.V1;

using Microsoft.EServices.EDocument;
using Microsoft.Integration.Graph;

page 20057 "APIV1 - PDF Document"
{
    Caption = 'pdfDocument', Locked = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Attachment Entity Buffer";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
#pragma warning disable AW0009
#pragma warning disable AL0273
                field(content; Rec.Content)
#pragma warning restore
                {
                    ApplicationArea = All;
                    Caption = 'content', Locked = true;
                    ToolTip = 'Specifies the content.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        PDFDocumentManagement: Codeunit "PDF Document Management";
        DocumentId: Guid;
        FilterView: Text;
        DocumentIdFilter: Text;
        IdFilter: Text;
    begin
        if not PdfGenerated then begin
            FilterView := Rec.GetView();
            DocumentIdFilter := Rec.GetFilter("Document Id");
            IdFilter := Rec.GetFilter(Id);
            if (DocumentIdFilter <> '') and (IdFilter <> '') and (LowerCase(DocumentIdFilter) <> LowerCase(IdFilter)) then
                Error(ConflictingIdsErr, DocumentIdFilter, IdFilter);
            if DocumentIdFilter <> '' then
                DocumentId := DocumentIdFilter
            else
                if IdFilter <> '' then
                    DocumentId := IdFilter;
            Rec.SetView(FilterView);
            if IsNullGuid(DocumentId) then
                exit(false);
            PdfGenerated := PDFDocumentManagement.GeneratePdf(DocumentId, Rec);
        end;
        exit(true);
    end;

    var
        PdfGenerated: Boolean;
        ConflictingIdsErr: Label 'You have specified conflicting identifiers: %1 and %2.', Comment = '%1 - a GUID, %2 - a GUID';
}


