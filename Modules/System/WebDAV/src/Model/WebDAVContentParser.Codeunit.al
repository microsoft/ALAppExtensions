
codeunit 5682 "WebDAV Content Parser"
{

    Access = Internal;

    [NonDebuggable]
    procedure Initialize(InitBaseUrl: Text; InitOnlyFiles: Boolean; InitOnlyCollections: Boolean)
    begin
        BaseUrl := InitBaseUrl;
        OnlyFiles := InitOnlyFiles;
        OnlyCollections := InitOnlyCollections;
    end;

    [NonDebuggable]
    procedure Parse(Payload: Text; var WebDAVContent: Record "WebDAV Content")
    var
        XmlDoc: XmlDocument;
        ChildNodes: XmlNodeList;
        ResponseNode: XmlNode;
    begin
        XmlNamespaceManager.AddNamespace('dav', 'DAV:');

        XmlDocument.ReadFrom(Payload, XmlDoc);
        XmlDoc.SelectNodes('//dav:response', XmlNamespaceManager, ChildNodes);
        foreach ResponseNode in ChildNodes do
            ParseSingle(ResponseNode, WebDAVContent);
    end;

    [NonDebuggable]
    procedure ParseSingle(XmlNode: XmlNode; var WebDAVContent: Record "WebDAV Content")
    begin
        WebDAVContent."Is Collection" := HasNode(XmlNode, 'dav:propstat/dav:prop/dav:resourcetype/dav:collection');

        if OnlyCollections then
            if not WebDAVContent."Is Collection" then
                exit;
        if OnlyFiles then
            if WebDAVContent."Is Collection" then
                exit;

        WebDAVContent."Full Url" := GetValueAsText(XmlNode, 'dav:href');
        WebDAVContent."Relative Url" := GetRelativeUrl(WebDAVContent."Full Url");
        WebDAVContent.Level := GetLevelFromPath(WebDAVContent."Relative Url");

        WebDAVContent."Name" := GetValueAsText(XmlNode, 'dav:propstat/dav:prop/dav:displayname');
        WebDAVContent."Content Type" := GetValueAsText(XmlNode, 'dav:propstat/dav:prop/dav:getcontenttype');
        if Evaluate(WebDAVContent."Content Length", GetValueAsText(XmlNode, 'dav:propstat/dav:prop/dav:getcontentlength')) then;

        if Evaluate(WebDAVContent."Creation Date", GetValueAsText(XmlNode, 'dav:propstat/dav:prop/dav:creationdate')) then;
        if Evaluate(WebDAVContent."Last Modified Date", GetValueAsText(XmlNode, 'dav:propstat/dav:prop/dav:getlastmodified')) then;

        WebDAVContent."Entry No." := GetNextEntryNo();
        WebDAVContent.Insert();
    end;

    [NonDebuggable]
    procedure GetValueAsText(XmlNode: XmlNode; PropertyName: Text): Text
    var
        ChildNode: XmlNode;
        XmlElement: XmlElement;
    begin
        if XmlNode.SelectSingleNode(PropertyName, XmlNamespaceManager, ChildNode) then begin
            XmlElement := ChildNode.AsXmlElement();
            Exit(XmlElement.InnerText());
        end;
    end;

    [NonDebuggable]
    procedure HasNode(XmlNode: XmlNode; PropertyName: Text): Boolean
    var
        ChildNode: XmlNode;
        XmlElement: XmlElement;
    begin
        Exit(XmlNode.SelectSingleNode(PropertyName, XmlNamespaceManager, ChildNode));
    end;

    local procedure GetNextEntryNo(): Integer;
    begin
        NextEntryNo += 1;
        Exit(NextEntryNo);
    end;

    local procedure GetLevelFromPath(Path: Text): Integer
    begin
        Exit(Path.Split('/').Count);
    end;

    local procedure GetRelativeUrl(FullUrl: Text) RelativeUrl: Text
    begin
        if FullUrl.StartsWith(BaseUrl) then
            RelativeUrl := FullUrl.Replace(BaseUrl, '');
        RelativeUrl := RelativeUrl.TrimStart('/');
    end;

    var
        [NonDebuggable]
        XmlNameSpaceManager: XmlNamespaceManager;
        BaseUrl: Text;
        NextEntryNo: Integer;
        OnlyFiles: Boolean;
        OnlyCollections: Boolean;
}