// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Sustainability.Ledger;

page 6231 "Sustainability Ledg. Entries"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Sustainability Ledger Entry';
    EntitySetCaption = 'Sustainability Ledger Entries';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityLedgerEntry';
    EntitySetName = 'sustainabilityLedgerEntries';
    ODataKeyFields = SystemId;
    SourceTable = "Sustainability Ledger Entry";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(entryNumber; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(accountNumber; Rec."Account No.")
                {
                    Caption = 'Emission Account';
                }
                field(displayName; Rec."Account Name")
                {
                    Caption = 'Emission Account Name';
                }
                field(emissionScope; Rec."Emission Scope")
                {
                    Caption = 'Scope Type';
                }
                field(unitOfMeasure; Rec."Unit of Measure")
                {
                    Caption = 'Unit of Measure';
                }
                field(emissionCO2; Rec."Emission CO2")
                {
                    Caption = 'Emission CO2';
                }
                field(emissionCH4; Rec."Emission CH4")
                {
                    Caption = 'Emission CH4';
                }
                field(emissionN2O; Rec."Emission N2O")
                {
                    Caption = 'Emission N2O';
                }
                field(countryRegion; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center';
                }
                field(userID; Rec."User ID")
                {
                    Caption = 'User ID';
                }
                field(sourceCode; Rec."Source Code")
                {
                    Caption = 'Source Code';
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code';
                }
            }
        }
    }
}