page 51750 "Bus Queues"
{
    Caption = 'Bus Queues';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Bus Queue";
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry no. of the record';
                }
                field(URL; Rec.URL)
                {
                    ToolTip = 'Specifies the URL.';
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
                field("HTTP Verb"; Rec."HTTP Request Type")
                {
                    ToolTip = 'Specifies the http verb of the request.';
                }
                field("Max. No. Of Tries";Rec."Max. No. Of Tries")
                {
                    ToolTip = 'Specifies the maximum number of tries.';
                }
                field("No. Of Tries"; Rec."No. Of Tries")
                {
                    ToolTip = 'Specifies the number of tries.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status.';

                    trigger OnDrillDown()
                    var
                        BusQueueDetailed: Record "Bus Queue Detailed";
                    begin
                        BusQueueDetailed.SetRange("Parent Entry No.", Rec."Entry No.");
                        Page.Run(Page::"Bus Queues Detailed", BusQueueDetailed);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Reenqueue)
            {
                Caption = 'Reenqueue';
                Image = SendApprovalRequest;
                ToolTip = 'Allows to re-enqueue one or multiple bus queues.';

                trigger OnAction()               
                begin
                    if Confirm(ConfirmToReenqueueLbl, false) then
                        ReenqueueBusQueues();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Reenqueue_Promoted; Reenqueue)
            {
            }
        }
    }

    var
        ViewLbl: Label 'View';
        EmptyLbl: Label '(empty)';
        ConfirmToReenqueueLbl: Label '¿Do you confirm to reenqueue?';
        HeadersTxt: Text;
    
    trigger OnAfterGetRecord()
    begin
        MergeHeadersAndContentHeaders();
    end;

    local procedure ViewBody()
    var
        DotNetEncoding: Codeunit DotNet_Encoding;
        DotNetStreamReader: Codeunit DotNet_StreamReader;
        InStream: InStream;
        FileName, BodyText : Text;
    begin
        if not Rec.Body.HasValue() then begin
            Message(EmptyLbl);
            exit;
        end;

        Rec.CalcFields(Body);
        Rec.Body.CreateInStream(InStream);

        if Rec."Is Text" then begin
            DotNetEncoding.Encoding(Rec.Codepage);
            DotNetStreamReader.StreamReader(InStream, DotNetEncoding);
            BodyText := DotNetStreamReader.ReadToEnd();

            Message(BodyText);
        end else begin
            FileName := 'BusQueue_' + Format(CurrentDateTime(), 0, '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>');
            DownloadFromStream(InStream, '', '', '', FileName);
        end;
    end;

    local procedure ReenqueueBusQueues()
    var
        BusQueue: Record "Bus Queue";
        BusQueueHandler: Codeunit "Bus Queue Handler";
    begin
        CurrPage.SetSelectionFilter(BusQueue);

        BusQueue.SetAutoCalcFields(Body);
        BusQueue.FindSet();
        repeat
            BusQueueHandler.Handle(BusQueue);
        until BusQueue.Next() = 0;
    end;

    local procedure MergeHeadersAndContentHeaders()
    var
        JsonHeaders, JsonContentHeaders: JsonObject;
        JsonContentHeadersTxt: Text;
    begin
        HeadersTxt := '';

        if (Rec.Headers = '') and (Rec."Content Headers" = '') then
            exit;
        
        if JsonHeaders.ReadFrom(Rec.Headers) then
            JsonHeaders.WriteTo(HeadersTxt);
        if JsonContentHeaders.ReadFrom(Rec."Content Headers") then        
            JsonContentHeaders.WriteTo(JsonContentHeadersTxt);

        case true of
            (Rec.Headers <> '') and (Rec."Content Headers" <> ''):
                begin
                    HeadersTxt := HeadersTxt.TrimEnd('}');
                    JsonContentHeadersTxt := JsonContentHeadersTxt.TrimStart('{');
                    JsonContentHeadersTxt := ',' + JsonContentHeadersTxt;
                    HeadersTxt += JsonContentHeadersTxt;
                end;
            (Rec.Headers <> '') and (Rec."Content Headers" = ''):
                HeadersTxt := Rec.Headers;
            (Rec.Headers = '') and (Rec."Content Headers" <> ''):
                HeadersTxt := Rec."Content Headers";
        end;
    end;
}