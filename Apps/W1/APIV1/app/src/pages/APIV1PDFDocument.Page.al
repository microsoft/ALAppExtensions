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
                field(content; Content)
                {
                    ApplicationArea = All;
                    Caption = 'content', Locked = true;
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
        TypeHelper: Codeunit "Type Helper";
        DocumentId: Guid;
        FilterView: Text;
        DocumentIdFilter: Text;
        IdFilter: Text;
    begin
        if not PdfGenerated then begin
            FilterView := GetView();
            DocumentIdFilter := GetFilter("Document Id");
            IdFilter := GetFilter(Id);
            if (DocumentIdFilter <> '') and (IdFilter <> '') and (LowerCase(DocumentIdFilter) <> LowerCase(IdFilter)) then
                Error(ConflictingIdsErr, DocumentIdFilter, IdFilter);
            if DocumentIdFilter <> '' then
                DocumentId := TypeHelper.GetGuidAsString(DocumentIdFilter)
            else
                if IdFilter <> '' then
                    DocumentId := TypeHelper.GetGuidAsString(IdFilter);
            SetView(FilterView);
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

