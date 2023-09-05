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

    var
        ViewLbl: Label 'View';
        EmptyLbl: Label '(empty)';
        HeadersTxt: Text;

    trigger OnAfterGetRecord()
    var
        TypeHelper: Codeunit "Type Helper";
        HeadersInStream: InStream;
    begin
        HeadersTxt := '';
        
        if TryViewHeaders() then begin
            Rec.Headers.CreateInStream(HeadersInStream, TextEncoding::UTF8);
            TypeHelper.TryReadAsTextWithSeparator(HeadersInStream, TypeHelper.CRLFSeparator(), HeadersTxt);
        end;        
    end;

    local procedure ViewBody()
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        FileName, BodyText : Text;
    begin
        if not Rec.Body.HasValue() then begin
            Message(EmptyLbl);
            exit;
        end;

        Rec.CalcFields(Body);
        Rec.Body.CreateInStream(InStream, TextEncoding::UTF8);

        if TypeHelper.TryReadAsTextWithSeparator(InStream, TypeHelper.CRLFSeparator(), BodyText) then 
            Message(BodyText)
        else begin
            FileName := 'BusQueueResponse_' + Format(CurrentDateTime(), 0, '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>');
            DownloadFromStream(InStream, '', '', '', FileName);
        end;
    end;

    [TryFunction]
    local procedure TryViewHeaders()
    begin
        Rec.CalcFields(Headers);
    end;
}