// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Ledger;
using System.Utilities;

tableextension 31031 "Inventory Posting Setup CZL" extends "Inventory Posting Setup"
{
    fields
    {
        field(11765; "Consumption Account CZL"; Code[20])
        {
            Caption = 'Consumption Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.LookupGLAccountWithoutCategory("Consumption Account CZL")
                else
                    GLAccountCategoryMgt.LookupGLAccount(
                      "Consumption Account CZL", GLAccountCategory."Account Category"::Expense,
                      A2_MaterialandEnergyConsumptionTxt);

                Validate("Consumption Account CZL");
            end;

            trigger OnValidate()
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.CheckGLAccountWithoutCategory("Consumption Account CZL", false, false)
                else
                    GLAccountCategoryMgt.CheckGLAccount(
                      "Consumption Account CZL", false, false, GLAccountCategory."Account Category"::Expense,
                      A2_MaterialandEnergyConsumptionTxt);
            end;
        }

        field(11766; "Change In Inv.Of WIP Acc. CZL"; Code[20])
        {
            Caption = 'Change In Inv.Of WIP Acc.';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckValueEntriesCZL(FieldCaption("Change In Inv.Of WIP Acc. CZL"));
            end;
        }

        field(11767; "Change In Inv.OfProd. Acc. CZL"; Code[20])
        {
            Caption = 'Change In Inv.Of Product Acc.';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
    }
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        A2_MaterialandEnergyConsumptionTxt: Label 'A.2. Material and Energy Consumption';

    procedure CheckValueEntriesCZL(FieldCaption: Text)
    var
        ValueEntry: Record "Value Entry";
        TextChangeQst: Label 'Do you really want to change %1 although value entries exist?', Comment = '%1 = FieldCaption';
    begin
        ValueEntry.SetCurrentKey("Item No.", "Valuation Date", "Location Code", "Variant Code");
        ValueEntry.SetRange("Location Code", "Location Code");
        ValueEntry.SetRange("Inventory Posting Group", "Invt. Posting Group Code");
        if not ValueEntry.IsEmpty() then
            if not ConfirmManagement.GetResponseOrDefault(StrSubStno(TextChangeQst, FieldCaption), false) then
                Error('');
    end;
}
