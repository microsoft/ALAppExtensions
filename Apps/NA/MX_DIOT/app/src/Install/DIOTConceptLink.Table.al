// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Setup;

table 27031 "DIOT Concept Link"
{
    Caption = 'DIOT Concept Link';

    fields
    {
        field(1; "DIOT Concept No."; Integer)
        {
            Caption = 'DIOT Concept No.';
            TableRelation = "DIOT Concept";
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            TableRelation = "VAT Product Posting Group";
        }

        field(3; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Business Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
    }
    keys
    {
        key(PK; "DIOT Concept No.", "VAT Prod. Posting Group", "VAT Bus. Posting Group")
        {
            Clustered = true;
        }
    }

    var
        ConceptDisabledErr: label 'The DIOT Concept is disabled. Do not add VAT Posting Setup links to it. If you need to add links, enable the concept first by changing the column type of the concept on "DIOT Concepts" page.';

    trigger OnInsert()
    var
        DIOTConcept: Record "DIOT Concept";
    begin
        if DIOTConcept.Get("DIOT Concept No.") then
            if DIOTConcept."Column Type" = DIOTConcept."Column Type"::None then
                Error(ConceptDisabledErr);
    end;
}
