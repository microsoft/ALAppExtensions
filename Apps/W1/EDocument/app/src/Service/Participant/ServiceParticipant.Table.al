// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Service.Participant;

using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.eServices.EDocument;

/// <summary>
/// Represents the service participant. 
/// Table allows a participant (Customer/Vendor/Etc.) to be associated with multiple services.
/// </summary>
table 6104 "Service Participant"
{
    Access = Public;
    Extensible = true;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Service; Code[20])
        {
            TableRelation = "E-Document Service";
            Caption = 'Service';
            ToolTip = 'Specifies the E-Document service for which the participant is associated.';
        }
        field(2; "Participant Type"; Enum "E-Document Source Type")
        {
            Caption = 'Participant Type';
            ToolTip = 'Specifies the type of participant associated with the E-Document service.';
        }
        field(3; Participant; Code[20])
        {
            TableRelation = if ("Participant Type" = const(Customer)) Customer
            else
            if ("Participant Type" = const(Vendor)) Vendor;
            Caption = 'Participant';
            ToolTip = 'Specifies the participant associated with the E-Document service.';
        }
        field(4; "Participant Identifier"; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Participant Identifier';
            ToolTip = 'Specifies the identifier of the participant associated with the E-Document service.';
        }

    }

    keys
    {
        key(PK; Service, "Participant Type", Participant)
        {
            Clustered = true;
        }
    }

}