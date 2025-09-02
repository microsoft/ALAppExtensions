// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10065 "Transmission Logs IRIS"
{
    PageType = List;
    ApplicationArea = BasicUS;
    Caption = 'Transmission History';
    SourceTable = "Transmission Log IRIS";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field(ID; Rec."Line ID")
                {
                }
                field("Period No."; Rec."Period No.")
                {
                }
                field("Unique Transmission ID"; Rec."Unique Transmission ID")
                {
                    trigger OnDrillDown()
                    var
                        TransmissionLogLine: Record "Transmission Log Line IRIS";
                        TransmissionLogLinesPage: Page "Transmission Log Lines IRIS";
                    begin
                        TransmissionLogLine.SetRange("Transmission Log ID", Rec."Line ID");
                        TransmissionLogLinesPage.SetTableView(TransmissionLogLine);
                        TransmissionLogLinesPage.LookupMode(true);
                        TransmissionLogLinesPage.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                field("Transmission Type"; Rec."Transmission Type")
                {
                }
                field("Transmission Date/Time"; Rec."Transmission Date/Time")
                {
                }
                field("Transmission Size"; Rec."Transmission Size")
                {
                }
                field("Receipt ID"; Rec."Receipt ID")
                {
                }
                field("Transmission Status"; Rec."Transmission Status")
                {
                }
                field("Acknowledgement Date/Time"; Rec."Acknowledgement Date/Time")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadTransmContent)
            {
                ApplicationArea = BasicUS;
                Caption = 'Download Transmission Content';
                Image = Download;
                ToolTip = 'Downloads the transmission content as an XML file.';
                trigger OnAction()
                begin
                    DownloadTransmissionContent();
                end;
            }
            action(DownloadRespContent)
            {
                ApplicationArea = BasicUS;
                Caption = 'Download Response Content';
                Image = Download;
                ToolTip = 'Downloads the response content as an XML or JSON file.';
                trigger OnAction()
                begin
                    DownloadResponseContent();
                end;
            }
            action(DownloadAcknowledgContent)
            {
                ApplicationArea = BasicUS;
                Caption = 'Download Acknowledgement Content';
                Image = Download;
                ToolTip = 'Downloads the acknowledgement content as an XML or JSON file.';
                trigger OnAction()
                begin
                    DownloadAcknowledgementContent();
                end;
            }
        }
    }

    var
        SaveFileDialogTxt: Label 'Save File As';
        TransmissionNoContentErr: Label 'The transmission does not have any content.';
        ResponseNoContentErr: Label 'The response is empty.';
        AcknowledgementNoContentErr: Label 'The acknowledgement is empty.';
        TransmissionContentTxt: Label 'Transmission';
        ResponseContentTxt: Label 'Response';
        AcknowledgementContentTxt: Label 'Acknowledgement';
        FileNameTxt: Label '%1_%2.%3', Comment = '%1 - content type - transmission/response/acknowledgement; %2 - unique transmission ID; %3 - file extension';

    local procedure DownloadTransmissionContent()
    var
        FileInStream: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("Transmission Content");
        if not Rec."Transmission Content".HasValue() then
            Error(TransmissionNoContentErr);
        FileName := StrSubstNo(FileNameTxt, TransmissionContentTxt, Rec."Unique Transmission ID", 'xml');
        Rec."Transmission Content".CreateInStream(FileInStream, TextEncoding::UTF8);
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', FileName);
    end;

    local procedure DownloadResponseContent()
    var
        FileInStream: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("Acceptance Response Content");
        if not Rec."Acceptance Response Content".HasValue() then
            Error(ResponseNoContentErr);

        Rec."Acceptance Response Content".CreateInStream(FileInStream, TextEncoding::UTF8);
        FileName := StrSubstNo(FileNameTxt, ResponseContentTxt, Rec."Unique Transmission ID", GetFileExtension(FileInStream));
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', FileName);
    end;

    local procedure DownloadAcknowledgementContent()
    var
        FileInStream: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("Acknowledgement Content");
        if not Rec."Acknowledgement Content".HasValue() then
            Error(AcknowledgementNoContentErr);

        Rec."Acknowledgement Content".CreateInStream(FileInStream, TextEncoding::UTF8);
        FileName := StrSubstNo(FileNameTxt, AcknowledgementContentTxt, Rec."Unique Transmission ID", GetFileExtension(FileInStream));
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', FileName);
    end;

    local procedure GetFileExtension(var ContentInStream: InStream): Text
    var
        ContentStart: Text;
    begin
        ContentInStream.ReadText(ContentStart, 10);
        ContentInStream.ResetPosition();

        if ContentStart.Contains('<') then
            exit('xml');
        if ContentStart.Contains('{') then
            exit('json');

        exit('txt');
    end;
}