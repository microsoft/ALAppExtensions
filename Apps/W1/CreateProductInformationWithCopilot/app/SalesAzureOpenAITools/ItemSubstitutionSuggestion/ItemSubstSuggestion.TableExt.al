// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

tableextension 7410 "Item Subst. Suggestion" extends "Item Substitution"
{
    fields
    {
        field(7330; Confidence; Enum "Search Confidence")
        {
            Caption = 'Confidence';
            DataClassification = SystemMetadata;
        }
        field(7331; Score; Decimal)
        {
            Caption = 'Score';
            DataClassification = SystemMetadata;
        }
        field(7332; "Primary Search Terms"; Blob)
        {
            Caption = 'Primary Search Terms';
            DataClassification = SystemMetadata;
        }
        field(7333; "Additional Search Terms"; Blob)
        {
            Caption = 'Secondary Search Terms';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key2; Score) { }
    }

    internal procedure SetPrimarySearchTerms(SearchTerms: List of [Text])
    var
        SearchTermOutStream: OutStream;
    begin
        Clear(Rec."Primary Search Terms");
        Rec."Primary Search Terms".CreateOutStream(SearchTermOutStream, TextEncoding::UTF8);
        SearchTermOutStream.WriteText(ListOfTextToText(SearchTerms));
    end;

    internal procedure SetAdditionalSearchTerms(SearchTerms: List of [Text])
    var
        SearchTermOutStream: OutStream;
    begin
        Clear(Rec."Additional Search Terms");
        Rec."Additional Search Terms".CreateOutStream(SearchTermOutStream, TextEncoding::UTF8);
        SearchTermOutStream.WriteText(ListOfTextToText(SearchTerms));
    end;

    local procedure ListOfTextToText(var TextList: List of [Text]) Result: Text
    var
        Txt: Text;
    begin
        foreach Txt in TextList do
            Result += Txt + ', ';
        Result := Result.TrimEnd(', ');
    end;

    internal procedure GetPrimarySearchTerms() Result: Text
    var
        SearchTermInStream: InStream;
    begin
        Rec.CalcFields("Primary Search Terms");
        Rec."Primary Search Terms".CreateInStream(SearchTermInStream, TextEncoding::UTF8);
        SearchTermInStream.ReadText(Result);
    end;

    internal procedure GetAdditionalSearchTerms() Result: Text
    var
        SearchTermInStream: InStream;
    begin
        Rec.CalcFields("Additional Search Terms");
        Rec."Additional Search Terms".CreateInStream(SearchTermInStream, TextEncoding::UTF8);
        SearchTermInStream.ReadText(Result);
    end;
}