// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

tableextension 6383 EDocServiceSupportedTypeExt extends "E-Doc. Service Supported Type"
{
    fields
    {
        field(6381; "Profile Id"; Integer)
        {
            Caption = 'Profile Id';
            ToolTip = 'The unique identifier for the metadata profile.';
            DataClassification = CustomerContent;
            TableRelation = MetadataProfile;
            BlankZero = true;

            trigger OnValidate()
            begin
                Rec.CalcFields("Profile Name");
            end;
        }
        field(6382; "Profile Name"; Text[250])
        {
            Caption = 'Profile Name';
            ToolTip = 'The common name of the metadata profile.';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(MetadataProfile."Profile Name" where("Profile ID" = field("Profile Id")));
        }
    }
}