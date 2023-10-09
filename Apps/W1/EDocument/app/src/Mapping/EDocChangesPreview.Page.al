// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6120 "E-Doc. Changes Preview"
{
    ApplicationArea = Basic, Suite;
    Caption = 'E-Document Changes Preview';
    PageType = Card;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTable = "E-Doc. Mapping";
    UsageCategory = None;
    Extensible = false;

    layout
    {
        area(Content)
        {
            part("Applied Mapping"; "E-Doc. Mapping Part")
            {
                Caption = 'Applied Mapping Rules';
                SubPageView = where(Used = const(true));
                SubPageLink = Code = field(Code);
            }
            part("Document Header Changes"; "E-Doc. Changes Part")
            {
                Caption = 'Document Header Changes';
            }
            part("Document Lines Changes"; "E-Doc. Changes Part")
            {
                Caption = 'Document Line Changes';
                SubPageView = sorting("Line No.");
            }
        }
    }

    internal procedure SetHeaderChanges(var DocumentMapping: Record "E-Doc. Mapping" temporary)
    begin
        CurrPage."Document Header Changes".Page.SetChanges(DocumentMapping);
    end;

    internal procedure SetLineChanges(var DocumentMapping: Record "E-Doc. Mapping" temporary)
    begin
        CurrPage."Document Lines Changes".Page.ShowLines();
        CurrPage."Document Lines Changes".Page.SetChanges(DocumentMapping);
    end;
}
