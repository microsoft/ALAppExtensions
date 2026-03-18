// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;
using Microsoft.eServices.EDocument;
table 10771 "Verifactu Document"
{
    Caption = 'Verifactu Document';
    LookupPageID = "Verifactu Document List";
    DataClassification = CustomerContent;
    InherentPermissions = X;
    Access = Internal;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'E-Document Entry No.';
            ToolTip = 'Specifies the entry number of the related E-Document.';
            TableRelation = "E-Document";
            Editable = false;
        }
        field(2; "Source Document Type"; Enum "E-Document Type")
        {
            Caption = 'Source Document Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of the Verifactu document.';
            Editable = false;
        }
        field(3; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the document number of the Verifactu document.';
            Editable = false;
        }
        field(4; "Verifactu Hash"; Text[64])
        {
            Caption = 'Verifactu Hash';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the Verifactu hash of the e-document received when the document is cleared.';
        }
        field(5; "Verifactu Posting Date"; Date)
        {
            Caption = 'Verifactu Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the Verifactu posting date of the e-document received when the document is cleared.';
        }
        field(6; "Submission Id"; Text[100])
        {
            Caption = 'Submission Id';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the Submission Id of the e-document received when the document is cleared.';
        }
        field(7; "Submission Status"; Text[50])
        {
            Caption = 'Submission Status';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the Submission Status of the e-document received when the document is cleared.';
        }
    }
    keys
    {
        key(Key1; "E-Document Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Verifactu Hash")
        {
        }
        key(Ke3; "Source Document Type", "Source Document No.")
        {
        }
        key(Key4; "Submission Id")
        {
        }
    }

}