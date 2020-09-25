codeunit 10674 "SAF-T XML Helper"
{
    var
        XMLDoc: XmlDocument;
        CurrXMLElement: array[100] of XmlElement;
        SavedXMLElement: XmlElement;
        Depth: Integer;
        NamespaceFullName: Text;
        SAFTNameSpaceTxt: Label 'urn:StandardAuditFile-Taxation-Financial:NO', Locked = true;
        NoFileGeneratedErr: Label 'No file generated';

    procedure Initialize()
    begin
        clear(XMLDoc);
        clear(CurrXMLElement);
        Depth := 0;
        SetNamespace(SAFTNameSpaceTxt);
        CreateRootWithNamespace('AuditFile', 'n1');
    end;

    procedure SetNamespace(NewNamespace: Text)
    begin
        NamespaceFullName := NewNamespace;
    end;

    procedure CreateRootWithNamespace(RootNodeName: Text; NamespaceShortName: Text)
    begin
        Depth += 1;
        CurrXMLElement[Depth] := XmlElement.Create(RootNodeName, NamespaceFullName);
        CurrXMLElement[Depth].Add(XmlAttribute.CreateNamespaceDeclaration(NamespaceShortName, NamespaceFullName));
        XMLDoc.Add(CurrXMLElement[Depth]);
        XMLDoc.GetRoot(CurrXMLElement[Depth]);
    end;

    procedure AddNewXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        InsertXMLNode(NewXMLElement, Name, NodeText);
        Depth += 1;
        CurrXMLElement[Depth] := NewXMLElement;
    end;

    procedure AppendXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        if NodeText = '' then
            exit;
        InsertXMLNode(NewXMLElement, Name, NodeText);
    end;

    procedure AppendToSavedXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        if NodeText = '' then
            exit;
        NewXMLElement := XmlElement.Create(Name, NamespaceFullName, NodeText);
        if (not SavedXMLElement.AddFirst(NewXMLElement)) then
            error(StrSubstNo('Not possible to insert element %1', NodeText));
    end;

    procedure SaveCurrXmlElement()
    begin
        SavedXMLElement := CurrXMLElement[Depth];
    end;

    procedure FinalizeXMLNode()
    begin
        Depth -= 1;
        if Depth < 0 then
            Error('Incorrect XML structure');
    end;

    local procedure InsertXMLNode(var NewXMLElement: XmlElement; Name: Text; NodeText: Text)
    begin
        NewXMLElement := XmlElement.Create(Name, NamespaceFullName, NodeText);
        if (not CurrXMLElement[Depth].Add(NewXMLElement)) then
            error(StrSubstNo('Not possible to insert element %1', NodeText));
    end;

    procedure ExportXMLDocument(var SAFTExportLine: Record "SAF-T Export Line"; SAFTExportHeader: Record "SAF-T Export Header")
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        FileOutStream: OutStream;
    begin
        if not SAFTExportMgt.SaveXMLDocToFolder(SAFTExportHeader, XMLDoc, SAFTExportLine."Line No.") then begin
            SAFTExportLine."SAF-T File".CreateOutStream(FileOutStream);
            XmlDoc.WriteTo(FileOutStream);
        end;
    end;

    procedure ExportSAFTExportLineBlobToFile(SAFTExportLine: Record "SAF-T Export Line"; FilePath: Text)
    var
        EntryTempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
    begin
        SAFTExportLine.CalcFields("SAF-T File");
        if not SAFTExportLine."SAF-T File".HasValue() then
            LogInternalError(NoFileGeneratedErr, DataClassification::SystemMetadata, Verbosity::Error);
        EntryTempBlob.FromRecord(SAFTExportLine, SAFTExportLine.FieldNo("SAF-T File"));
        FileManagement.BLOBExportToServerFile(EntryTempBlob, FilePath);
    end;

    procedure GetFilePath(ServerDestinationFolder: Text; VATRegistrationNo: Text[20]; CreatedDateTime: DateTime; NumberOfFile: Integer; TotalNumberOfFiles: Integer): Text;
    var
        FileName: Text;
    begin
        FileName := StrSubstNo('SAF-T Financial_%1_%2_%3_%4.xml', VATRegistrationNo, DateTimeOfFileCreation(CreatedDateTime), NumberOfFile, TotalNumberOfFiles);
        exit(ServerDestinationFolder + '\' + FileName);
    end;

    local procedure DateTimeOfFileCreation(CreatedDateTime: DateTime): Text
    begin
        exit(format(CreatedDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>'));
    end;
}
