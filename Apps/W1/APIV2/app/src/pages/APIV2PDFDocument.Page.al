page 30056 "APIV2 - PDF Document"
{
    APIVersion = 'v2.0';
    EntityCaption = 'PDF Document';
    EntitySetCaption = 'PDF Document';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DelayedInsert = true;
    EntityName = 'pdfDocument';
    EntitySetName = 'pdfDocument';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Attachment Entity Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentId; "Document Id")
                {
                    Caption = 'Parent Id';
                    Editable = false;
                }
                field(parentType; "Document Type")
                {
                    Caption = 'Parent Type';
                    Editable = false;
                }
                field(pdfDocumentContent; Content)
                {
                    Caption = 'PDF Document Content';
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
        DocumentType: Enum "Attachment Entity Buffer Document Type";
        DocumentId: Guid;
        FilterView: Text;
        DocumentIdFilter: Text;
        DocumentTypeFilter: Text;
        IdFilter: Text;
    begin
        if not PdfGenerated then begin
            FilterView := GetView();
            DocumentIdFilter := GetFilter("Document Id");
            DocumentTypeFilter := GetFilter("Document Type");
            IdFilter := GetFilter(Id);
            if (DocumentIdFilter <> '') and (IdFilter <> '') and (LowerCase(DocumentIdFilter) <> LowerCase(IdFilter)) then
                Error(ConflictingIdsErr, DocumentIdFilter, IdFilter);
            if (DocumentTypeFilter = '') then
                Error(MissingParentTypeErr);
            if (DocumentIdFilter = '') then
                if (IdFilter = '') then
                    Error(MissingParentIdErr)
                else
                    DocumentIdFilter := IdFilter
            else
                IdFilter := DocumentIdFilter;

            DocumentId := Format(DocumentIdFilter);
            Evaluate(DocumentType, DocumentTypeFilter);
            SetView(FilterView);
            if IsNullGuid(DocumentId) then
                exit(false);
            PdfGenerated := PDFDocumentManagement.GeneratePdfWithDocumentType(DocumentId, DocumentType, Rec);
        end;
        exit(true);
    end;

    var
        PdfGenerated: Boolean;
        ConflictingIdsErr: Label 'You have specified conflicting identifiers: %1 and %2.', Comment = '%1 - a GUID, %2 - a GUID';
        MissingParentIdErr: Label 'You must specify a parentId in the request body.', Comment = 'parentId is a field name and should not be translated.';
        MissingParentTypeErr: Label 'You must specify a parentType in the request body.', Comment = 'parentType is a field name and should not be translated.';
}