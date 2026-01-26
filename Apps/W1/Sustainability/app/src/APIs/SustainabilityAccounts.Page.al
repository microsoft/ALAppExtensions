// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Sustainability.Account;

page 6227 "Sustainability Accounts"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Sustainability Account';
    EntitySetCaption = 'Sustainability Accounts';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityAccount';
    EntitySetName = 'sustainabilityAccounts';
    ODataKeyFields = SystemId;
    SourceTable = "Sustainability Account";
    Extensible = false;

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
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(category; Rec.Category)
                {
                    Caption = 'Category';
                }
                field(subcategory; Rec.Subcategory)
                {
                    Caption = 'Subcategory';
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'Account Type';
                }
            }
        }
    }
}