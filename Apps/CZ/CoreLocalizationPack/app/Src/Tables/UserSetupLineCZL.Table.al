// Copyright (c) Microsoft Corporation. All rights reserved.
// ------------------------------------------------------------------------------------------------
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.FixedAssets.Insurance;
using Microsoft.FixedAssets.Journal;
#if not CLEAN22
using Microsoft.Inventory.Intrastat;
#endif
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Resources.Journal;
using Microsoft.Warehouse.Journal;
using Microsoft.Warehouse.Worksheet;

table 11797 "User Setup Line CZL"
{
    Caption = 'User Setup Line (Obsolete)';
    DataCaptionFields = "User ID", Type;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup";
        }
        field(10; Type; Enum "User Setup Line Type CZL")
        {
            Caption = 'Type';
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(30; "Code / Name"; Code[20])
        {
            Caption = 'Code / Name';
            TableRelation = if (Type = const("Location (quantity increase)")) Location
            else
            if (Type = const("Location (quantity decrease)")) Location
            else
            if (Type = const("Release Location (quantity increase)")) Location
            else
            if (Type = const("Release Location (quantity decrease)")) Location
            else
            if (Type = const("Bank Account")) "Bank Account"
            else
            if (Type = const("Payment Order")) "Bank Account"
            else
            if (Type = const("Bank Statement")) "Bank Account"
            else
            if (Type = const("General Journal")) "Gen. Journal Template"
            else
            if (Type = const("Item Journal")) "Item Journal Template"
            else
            if (Type = const("Resource Journal")) "Res. Journal Template"
            else
            if (Type = const("Job Journal")) "Job Journal Template"
            else
#if not CLEAN22
#pragma warning disable AL0432
            if (Type = const("Intrastat Journal")) "Intrastat Jnl. Template"
            else
#pragma warning restore AL0432
#endif
            if (Type = const("FA Journal")) "FA Journal Template"
            else
            if (Type = const("Insurance Journal")) "Insurance Journal Template"
            else
            if (Type = const("FA Reclass. Journal")) "FA Reclass. Journal Template"
            else
            if (Type = const("Req. Worksheet")) "Req. Wksh. Template"
            else
            if (Type = const("VAT Statement")) "VAT Statement Template"
            else
            if (Type = const("Whse. Journal")) "Warehouse Journal Template"
            else
            if (Type = const("Whse. Worksheet")) "Whse. Worksheet Template"
            else
            if (Type = const("Invt. Movement Templates")) "Invt. Movement Template CZL";
        }
    }

    keys
    {
        key(Key1; "User ID", Type, "Line No.")
        {
            Clustered = true;
        }
    }
}

