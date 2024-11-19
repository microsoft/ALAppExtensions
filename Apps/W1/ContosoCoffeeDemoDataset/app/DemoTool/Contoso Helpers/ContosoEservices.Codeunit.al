codeunit 5462 "Contoso eServices"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Incoming Documents Setup" = rim,
        tabledata "Online Map Setup" = rim,
        tabledata "Online Map Parameter Setup" = rim,
        tabledata "Incoming Document" = rim,
        tabledata "Incoming Document Attachment" = rim;

    var
        OverwriteData: Boolean;

    procedure InsertEServicesIncomingDocumentSetup(GeneralTemplateName: Code[10]; GeneralBatchName: Code[10]; RequireApprovalToCreate: Boolean; RequireApprovalToPost: Boolean)
    var
        IncomingDocumentsSetup: Record "Incoming Documents Setup";
    begin
        if not IncomingDocumentsSetup.Get() then
            IncomingDocumentsSetup.Insert();

        IncomingDocumentsSetup.Validate("General Journal Template Name", GeneralTemplateName);
        IncomingDocumentsSetup.Validate("General Journal Batch Name", GeneralBatchName);
        IncomingDocumentsSetup.Validate("Require Approval To Create", RequireApprovalToCreate);
        IncomingDocumentsSetup.Validate("Require Approval To Post", RequireApprovalToPost);
        IncomingDocumentsSetup.Modify(true);
    end;

    procedure InsertEServicesOnlineMapSetup(MapParameterSetupCode: Code[10]; DistanceIn: Option Miles,Kilometers; Route: Integer; Enabled: Boolean)
    var
        OnlineMapSetup: Record "Online Map Setup";
    begin
        if not OnlineMapSetup.Get() then
            OnlineMapSetup.Insert();

        OnlineMapSetup.Validate("Map Parameter Setup Code", MapParameterSetupCode);
        OnlineMapSetup.Validate("Distance In", DistanceIn);
        OnlineMapSetup.Validate(Route, Route);
        OnlineMapSetup.Validate(Enabled, Enabled);
        OnlineMapSetup.Modify(true);
    end;

    procedure InsertEServiceOnlineMapParameter(Code: Code[10]; Name: Text[30]; MapService: Text[250]; DirectionsService: Text[250]; Comment: Text[250]; URLEncodeNonAsciiChars: Boolean; MilesKmOptionList: Text[250]; QuickestShortestOptionList: Text[250]; DirectionsfromLocationServ: Text[250])
    var
        OnlineMapParameterSetup: Record "Online Map Parameter Setup";
        Exists: Boolean;
    begin
        if OnlineMapParameterSetup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        OnlineMapParameterSetup.Validate(Code, Code);
        OnlineMapParameterSetup.Validate(Name, Name);
        OnlineMapParameterSetup.Validate("Map Service", MapService);
        OnlineMapParameterSetup.Validate("Directions Service", DirectionsService);
        OnlineMapParameterSetup.Validate(Comment, Comment);
        OnlineMapParameterSetup.Validate("URL Encode Non-ASCII Chars", URLEncodeNonAsciiChars);
        OnlineMapParameterSetup.Validate("Miles/Kilometers Option List", MilesKmOptionList);
        OnlineMapParameterSetup.Validate("Quickest/Shortest Option List", QuickestShortestOptionList);
        OnlineMapParameterSetup.Validate("Directions from Location Serv.", DirectionsfromLocationServ);

        if Exists then
            OnlineMapParameterSetup.Modify(true)
        else
            OnlineMapParameterSetup.Insert(true);
    end;

    procedure InsertIncomingDocument(EntryNo: Integer; Description: Text[100]; DocumentNo: Code[20]; PostingDate: Date): Record "Incoming Document"
    var
        IncomingDocument: Record "Incoming Document";
        Exists: Boolean;
    begin
        if IncomingDocument.Get(EntryNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        IncomingDocument.Validate("Entry No.", EntryNo);
        IncomingDocument.Validate(Description, Description);
        IncomingDocument.Validate("Document No.", DocumentNo);
        IncomingDocument.Validate("Posting Date", PostingDate);

        if Exists then
            IncomingDocument.Modify(true)
        else
            IncomingDocument.Insert(true);

        exit(IncomingDocument);
    end;

    procedure InsertEServicesIncomingDocumentAttachment(IncomingDocumentEntryNo: Integer; LineNo: Integer; Name: Text[100]; FileExtension: Text[30]; Content: Text; DocumentNo: Code[20]; PostingDate: Date; UseforOCR: Boolean; ExternalDocumentReference: Text[50])
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        Exists: Boolean;
    begin
        if IncomingDocumentAttachment.Get(IncomingDocumentEntryNo, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        IncomingDocumentAttachment.Validate("Incoming Document Entry No.", IncomingDocumentEntryNo);
        IncomingDocumentAttachment.Validate("Line No.", LineNo);
        IncomingDocumentAttachment.Validate(Name, Name);
        IncomingDocumentAttachment.Validate("File Extension", FileExtension);
        IncomingDocumentAttachment.Validate("Document No.", DocumentNo);
        IncomingDocumentAttachment.Validate("Posting Date", PostingDate);
        IncomingDocumentAttachment.Validate("External Document Reference", ExternalDocumentReference);

        if Exists then
            IncomingDocumentAttachment.Modify(true)
        else
            IncomingDocumentAttachment.Insert(true);
    end;

}
