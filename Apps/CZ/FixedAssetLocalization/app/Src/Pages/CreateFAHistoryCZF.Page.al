// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

page 31246 "Create FA History CZF"
{
    PageType = StandardDialog;
    UsageCategory = None;
    Caption = 'Create FA History Entry';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the posting date of the entry to be inserted.';
                }
                field(DocumentNo; DocumentNo)
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the document number of the entry to be inserted.';
                }
            }
        }
    }

    var
        PostingDate: Date;
        DocumentNo: Code[20];

    procedure SetValues(NewPostingDate: Date; NewDocumentNo: code[20])
    begin
        PostingDate := NewPostingDate;
        DocumentNo := NewDocumentNo;
    end;

    procedure GetValues(var NewPostingDate: Date; var NewDocumentNo: code[20])
    begin
        NewPostingDate := PostingDate;
        NewDocumentNo := DocumentNo;
    end;
}
