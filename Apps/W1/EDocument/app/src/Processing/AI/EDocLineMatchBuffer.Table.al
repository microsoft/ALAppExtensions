// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Finance.Deferral;
using Microsoft.Finance.GeneralLedger.Account;

table 6111 "EDoc Line Match Buffer"
{
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = RIMDX;
    Caption = 'EDocument Line Match Buffer';
    Access = Internal;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            DataClassification = CustomerContent;
            TableRelation = "Deferral Template";
        }
        field(6; "Deferral Reason"; Text[1024])
        {
            Caption = 'Deferral Reason';
            DataClassification = CustomerContent;
        }
        field(7; "GL Account No."; Code[20])
        {
            Caption = 'GL Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(8; "GL Account Reason"; Text[1024])
        {
            Caption = 'GL Account Reason';
            DataClassification = CustomerContent;
        }
        field(9; "GL Account Candidate Count"; Integer)
        {
            Caption = 'GL Account Candidate Count';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    internal procedure SetSource(var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        Rec."E-Document Entry No." := EDocumentPurchaseLine."E-Document Entry No.";
        Rec."Line No." := EDocumentPurchaseLine."Line No.";
        Rec.Insert();
    end;

}