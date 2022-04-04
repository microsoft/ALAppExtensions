// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page which will host the document service share ux
/// </summary>
page 9560 "Document Sharing"
{
    PageType = Card;
    Extensible = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "Document Sharing";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            field(DocumentUri; Rec.DocumentUri)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the location of where the document has been uploaded. Navigating here will allow the user to download the file.';
            }

            field(DocumentRootUri; Rec.DocumentRootUri)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the root location of the document. This is typically the store used by the Document Service.';
            }

            field(SharingToken; SharingToken)
            {
                ApplicationArea = All;
                Caption = 'Sharing Token';
                ToolTip = 'Specifies the sharing token.';
            }

            field(Extension; Rec.Extension)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the filename extension (e.g. .pdf). This is required to display the share experience.';
            }

            field(Name; Rec.Name)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the filename of the document (with file extension). This will be used for uploading and also displayed in the share experience.';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        InStr: InStream;
    begin
        Rec.CalcFields(Rec.Token);
        Rec.Token.CreateInStream(InStr);

        InStr.ReadText(SharingToken);
    end;

    var
        SharingToken: Text;
}