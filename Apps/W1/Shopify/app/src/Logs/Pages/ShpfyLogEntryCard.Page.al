namespace Microsoft.Integration.Shopify;

using System.Utilities;

/// <summary>
/// Page Shpfy Log Entry Card (ID 30120).
/// </summary>
page 30120 "Shpfy Log Entry Card"
{
    Caption = 'Shopify Log Entry';
    DeleteAllowed = false;
    Description = 'Details of a log entry of the Synchronization between your Shopify store and Dynamics 365 Business Central.';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Shpfy Log Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(EntryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specific number series when the entry was created.';
                }
                field(DateAndTime; Rec."Date and Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and the time when this entry was created.';
                }
                field("Time"; Rec.Time)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when this entry was created.';
                }
                field("UserId"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL with the data requested from.';
                }
                field(Method; Rec.Method)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the used method.';
                }
                field(StatusCode; Rec."Status Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HTTP result status of the entry in the log.';
                }
                field(StatusDescription; Rec."Status Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the HTTP result status of the entry in the log.';
                }
                field(HasError; Rec."Has Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the request has errors.';
                }
                field(RequestId; Rec."Shpfy Request Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the request ID.';
                }
                field(RetryCount; Rec."Retry Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies number of retries.';
                }
                field(QueryCost; Rec."Query Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the query cost.';
                }
            }
            group(RequestJsonData)
            {
                ShowCaption = false;

                field(RequestJson; Rec.GetRequest())
                {
                    ApplicationArea = All;
                    Caption = 'Request Data';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    ToolTip = 'Specifies the data that was send in the request.';
                }
            }
            group(ResponseJsonData)
            {
                ShowCaption = false;

                field(ResponseJson; Rec.GetResponse())
                {
                    ApplicationArea = All;
                    Caption = 'Response Data';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    ToolTip = 'Specifies the data that was received in the response.';
                }
            }
#if not CLEAN26
            group(JsonData)
            {
                Visible = false;
                ObsoleteReason = 'This group is obsolete and will be removed in a future version. Use the RequestJsonData and ResponseJsonData groups instead.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';

                field(RequestData; Rec.GetRequest())
                {
                    ApplicationArea = All;
                    Caption = 'Request Data';
                    MultiLine = true;
                    ToolTip = 'Specifies the data that was send in the request.';
                    ObsoleteReason = 'This field is obsolete and will be removed in a future version. Use the RequestJson field instead.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                }
                field(ResponseData; Rec.GetResponse())
                {
                    ApplicationArea = All;
                    Caption = 'Response Data';
                    MultiLine = true;
                    ToolTip = 'Specifies the data that was received in the response.';
                    ObsoleteReason = 'This field is obsolete and will be removed in a future version. Use the ResponseJson field instead.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                }
            }
#endif
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadRequestAction)
            {
                ApplicationArea = All;
                Caption = 'Download Request';
                Image = Download;
                ToolTip = 'Download the request that was made.';

                trigger OnAction()
                begin
                    DownloadRequest();
                end;
            }
            action(DownloadResponseAction)
            {
                ApplicationArea = All;
                Caption = 'Download Response';
                Image = Download;
                ToolTip = 'Download the response that was obtained.';

                trigger OnAction()
                begin
                    DownloadResponse();
                end;
            }
        }
    }

    local procedure DownloadRequest()
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        TitleLbl: Label 'Download Request file';
        OutStream: OutSTream;
        ToFile: Text;
    begin
        TempBlob.CreateInStream(InStream);
        TempBlob.CreateOutStream(OutStream);
        OutStream.Write(Rec.GetRequest());
        ToFile := 'Request_' + format(Rec."Entry No.") + '.json';
        File.DownloadFromStream(InStream, TitleLbl, '', '(*.*)|*.*', ToFile);
    end;

    local procedure DownloadResponse()
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        TitleLbl: Label 'Download Response file';
        OutStream: OutSTream;
        ToFile: Text;
    begin
        TempBlob.CreateInStream(InStream);
        TempBlob.CreateOutStream(OutStream);
        OutStream.Write(Rec.GetResponse());
        ToFile := 'Response_' + format(Rec."Entry No.") + '.json';
        File.DownloadFromStream(InStream, TitleLbl, '', '(*.*)|*.*', ToFile);
    end;
}

