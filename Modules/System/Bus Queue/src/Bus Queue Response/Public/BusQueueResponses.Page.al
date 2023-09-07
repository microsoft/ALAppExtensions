page 51752 "Bus Queue Responses"
{
    Caption = 'Bus Queue Responses';
    PageType = List;
    SourceTable = "Bus Queue Response";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Bus Queue Detailed Entry No."; Rec."Bus Queue Detailed Entry No.")
                {
                    Caption = 'Detailed Entry No.';
                    ToolTip = 'Specifies the detailed entry no.';                    
                }
                field("HTTP Code"; Rec."HTTP Code")
                {
                    ToolTip = 'Specifies the HTTP code.';
                }
                field("Reason Phrase"; Rec."Reason Phrase")
                {
                    ToolTip = 'Specifies the reason phrase.';
                }
                field(Headers; HeadersTxt)
                {
                    Caption = 'Headers';
                    ToolTip = 'Specifies the headers.';
                }
                field(BodyTxt; ViewLbl)
                {
                    Caption = 'Body';
                    ToolTip = 'Specifies the body.';

                    trigger OnDrillDown()
                    begin
                        ViewBody();
                    end;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the date and time of creation.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Download)
            {
                Caption = 'Download body';
                Image = Download;
                ToolTip = 'Allows to download the body.';

                trigger OnAction()
                var
                    InStream: InStream;
                    FileName: Text;
                begin
                    if not Rec.Body.HasValue() then begin
                        Message(EmptyLbl);
                        exit;
                    end;
                    
                    Rec.CalcFields(Body);
                    Rec.Body.CreateInStream(InStream, TextEncoding::UTF8);
                    FileName := 'BusQueueResponse_' + Format(CurrentDateTime(), 0, FormatFileTok);
                    DownloadFromStream(InStream, '', '', '', FileName);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Download_Promoted; Download)
            {
            }
        }
    }

    var
        ViewLbl: Label 'View';
        EmptyLbl: Label '(empty)';
        FormatFileTok: Label '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>', Locked = true;
        HeadersTxt: Text;

    trigger OnAfterGetRecord()
    var
        HeadersInStream: InStream;
    begin
        HeadersTxt := '';
        
        if TryViewHeaders() then begin
            Rec.Headers.CreateInStream(HeadersInStream, TextEncoding::UTF8);
            TryReadAsTextWithSeparator(HeadersInStream, CRLFSeparator(), HeadersTxt);
        end;
    end;

    local procedure ViewBody()
    var
        InStream: InStream;
        FileName, BodyText : Text;
    begin
        if not Rec.Body.HasValue() then begin
            Message(EmptyLbl);
            exit;
        end;

        Rec.CalcFields(Body);
        Rec.Body.CreateInStream(InStream, TextEncoding::UTF8);

        if TryReadAsTextWithSeparator(InStream, CRLFSeparator(), BodyText) then 
            Message(BodyText)
        else begin
            FileName := 'BusQueueResponse_' + Format(CurrentDateTime(), 0, FormatFileTok);
            DownloadFromStream(InStream, '', '', '', FileName);
        end;
    end;

    [TryFunction]
    local procedure TryReadAsTextWithSeparator(InStream: InStream; LineSeparator: Text; var Content: Text)
    begin
        Content := ReadAsTextWithSeparator(InStream, LineSeparator);
    end;

    local procedure ReadAsTextWithSeparator(InStream: InStream; LineSeparator: Text): Text
    var
        Tb: TextBuilder;
        ContentLine: Text;
    begin
        InStream.ReadText(ContentLine);
        Tb.Append(ContentLine);
        while not InStream.EOS() do begin
            InStream.ReadText(ContentLine);
            Tb.Append(LineSeparator);
            Tb.Append(ContentLine);
        end;

        exit(Tb.ToText());
    end;

    local procedure CRLFSeparator(): Text[2]
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        
        exit(CRLF);
    end;

    [TryFunction]
    local procedure TryViewHeaders()
    begin
        Rec.CalcFields(Headers);
    end;
}