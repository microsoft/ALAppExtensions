// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.PostingHandler;

table 20337 "Tax Posting Keys Buffer"
{
    Caption = 'Tax Posting Keys Buffer';
    DataClassification = EndUserIdentifiableInformation;
    Access = Internal;
    Extensible = false;
    fields
    {

        field(1; "Key"; Text[2000])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Key';
        }
        field(2; "Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
        }
    }
    keys
    {
        key(PK; "Key", "Record ID")
        {
            Clustered = true;
        }
    }

}
