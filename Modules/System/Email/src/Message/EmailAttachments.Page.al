// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 8889 "Email Attachments"
{
    PageType = ListPart;
    SourceTable = "Email Message Attachment";
    InsertAllowed = false;
    ShowFilter = false;
    Permissions = tabledata "Email Message Attachment" = rmd;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(FileName; Rec."Attachment Name")
                {
                    ApplicationArea = All;
                    Caption = 'Filename';
                    ToolTip = 'Specifies the name of the attachment';

                    trigger OnDrillDown()
                    var
                        Instream: Instream;
                        Filename: Text;
                    begin
                        Rec.Attachment.CreateInStream(Instream);
                        Filename := Rec."Attachment Name";
                        DownloadFromStream(Instream, '', '', '', Filename)
                    end;
                }
            }
        }
    }
}
