// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

table 18002 "GST Claim Setoff"
{
    Caption = 'GST Claim Setoff';
    DataCaptionFields = "GST Component Code", "Set Off Component Code";

    fields
    {
        field(1; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Set Off Component Code"; code[30])
        {
            Caption = 'Set Off Component Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Priority"; Integer)
        {
            Caption = 'Priority';
            NotBlank = true;
            MinValue = 1;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "GST Component Code", "Set Off Component Code")
        {
            Clustered = true;
        }
        key(Fk; Priority)
        {
        }
    }
}
